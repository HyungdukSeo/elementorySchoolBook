package com.hdseo.elementaryschoolbook.service

import android.util.Base64
import com.hdseo.elementaryschoolbook.data.Book
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.sync.Semaphore
import kotlinx.coroutines.sync.withPermit
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.net.HttpURLConnection
import java.net.URL

class JihaksaCatalogService {

    private val downloadableSections = setOf("교과서", "수학익힘", "실험관찰")

    suspend fun fetchCatalogBooks(): List<Book> = withContext(Dispatchers.IO) {
        coroutineScope {
            val dataRequestLimiter = Semaphore(6)
            val textbooks = (3..6).flatMap { grade ->
                (1..2).map { term ->
                    async {
                        runCatching {
                            fetchTextbookList(grade, term).map { textbook -> grade to textbook }
                        }.getOrDefault(emptyList())
                    }
                }
            }.awaitAll().flatten()

            textbooks.map { (grade, textbook) ->
                async {
                    dataRequestLimiter.withPermit {
                        runCatching { fetchBooksForTextbook(grade, textbook) }.getOrDefault(emptyList())
                    }
                }
            }.awaitAll()
                .flatten()
                .distinctBy { it.catalogKey }
        }
    }

    suspend fun downloadPdf(
        fileSeq: String,
        destination: File,
        onProgress: (Float) -> Unit
    ) = withContext(Dispatchers.IO) {
        val connection = URL("https://tsol.jihak.co.kr/file/download.ez").openConnection() as HttpURLConnection
        connection.requestMethod = "POST"
        connection.doOutput = true
        connection.connectTimeout = 15000
        connection.readTimeout = 60000
        connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded")
        connection.setRequestProperty("User-Agent", "Mozilla/5.0")
        connection.outputStream.use { it.write("seq=$fileSeq".toByteArray(Charsets.UTF_8)) }

        val tmp = File(destination.parent, "${destination.name}.tmp")
        try {
            if (connection.responseCode != 200) {
                throw Exception("지학사 다운로드 서버 오류 (${connection.responseCode})")
            }

            val total = connection.contentLengthLong
            var downloaded = 0L
            connection.inputStream.use { input ->
                tmp.outputStream().use { output ->
                    val buffer = ByteArray(16_384)
                    var read: Int
                    while (input.read(buffer).also { read = it } != -1) {
                        output.write(buffer, 0, read)
                        downloaded += read
                        if (total > 0) onProgress(downloaded.toFloat() / total)
                    }
                }
            }

            if (destination.exists()) destination.delete()
            if (!tmp.renameTo(destination)) {
                throw Exception("PDF 파일 저장에 실패했습니다.")
            }
            onProgress(1.0f)
        } catch (e: Exception) {
            tmp.delete()
            throw e
        } finally {
            connection.disconnect()
        }
    }

    private fun fetchTextbookList(grade: Int, term: Int): List<JSONObject> {
        val body = get("https://tsol.jihak.co.kr/api/v1/textbook/ele/SNB/list.ez?grade=$grade&term=$term")
        val decoded = String(Base64.decode(body, Base64.DEFAULT), Charsets.UTF_8)
        val list = JSONObject(decoded).optJSONArray("list") ?: JSONArray()
        return jsonArrayItems(list)
    }

    private fun fetchDataList(textbookSeq: String): List<JSONObject> {
        val payload = JSONObject().apply {
            put("textbookSeq", textbookSeq)
            put("schoolTypeSeq", "SUBJECT_SCHOOLTYPE_ELEMENTARY")
        }.toString()
        val encoded = Base64.encodeToString(payload.toByteArray(Charsets.UTF_8), Base64.NO_WRAP)
        val body = postText("https://tsol.jihak.co.kr/api/v1/textbook/data/list.ez", encoded)
        val decoded = String(Base64.decode(body, Base64.DEFAULT), Charsets.UTF_8)
        val list = JSONObject(decoded).optJSONArray("dataList") ?: JSONArray()
        return jsonArrayItems(list)
    }

    private fun fetchBooksForTextbook(grade: Int, textbook: JSONObject): List<Book> {
        val textbookSeq = textbook.optString("textbookSeq")
        val subjectName = textbook.optString("subjectName").trim()
        val textbookName = normalizeTitle(textbook.optString("textbookName"))
        if (textbookSeq.isBlank() || subjectName.isBlank() || textbookName.isBlank()) return emptyList()

        return fetchDataList(textbookSeq).mapNotNull { data ->
            val dataName = data.optString("dataName").trim()
            if (dataName !in downloadableSections) return@mapNotNull null

            val fileSeq = data.optString("dataFileSeq")
            if (fileSeq.isBlank()) return@mapNotNull null

            val subject = when (dataName) {
                "수학익힘" -> "수학익힘"
                "실험관찰" -> "실험관찰"
                else -> subjectName
            }
            val title = when (dataName) {
                "수학익힘" -> textbookName.replace("수학", "수학익힘")
                "실험관찰" -> textbookName.replace("과학", "실험관찰")
                else -> textbookName
            }
            val key = "jh-${titleKey(title)}-$dataName"

            Book(
                id = key,
                title = title,
                linkTitle = "",
                grade = grade,
                subject = subject,
                viewPageId = fileSeq,
                viewSection = dataName,
                publisher = "지학사",
                catalogKey = key
            )
        }
    }

    private fun jsonArrayItems(array: JSONArray): List<JSONObject> =
        buildList {
            for (i in 0 until array.length()) {
                add(array.getJSONObject(i))
            }
        }

    private fun titleKey(title: String): String =
        title.replace(Regex("""\s+"""), "-").replace(Regex("""[^0-9A-Za-z가-힣-]"""), "")

    private fun normalizeTitle(title: String): String =
        title.replace(Regex("""\s+"""), " ")
            .replace(Regex("""([가-힣])(\d)"""), "$1 $2")
            .trim()

    private fun get(url: String): String {
        val connection = URL(url).openConnection() as HttpURLConnection
        connection.requestMethod = "GET"
        connection.connectTimeout = 10000
        connection.readTimeout = 15000
        connection.setRequestProperty("User-Agent", "Mozilla/5.0")

        return try {
            if (connection.responseCode != 200) {
                throw Exception("지학사 서버 오류 (${connection.responseCode})")
            }
            connection.inputStream.bufferedReader().use { it.readText() }
        } finally {
            connection.disconnect()
        }
    }

    private fun postText(url: String, body: String): String {
        val connection = URL(url).openConnection() as HttpURLConnection
        connection.requestMethod = "POST"
        connection.doOutput = true
        connection.connectTimeout = 10000
        connection.readTimeout = 15000
        connection.setRequestProperty("Content-Type", "text/plain;charset=UTF-8")
        connection.setRequestProperty("User-Agent", "Mozilla/5.0")
        connection.outputStream.use { it.write(body.toByteArray(Charsets.UTF_8)) }

        return try {
            if (connection.responseCode != 200) {
                throw Exception("지학사 서버 오류 (${connection.responseCode})")
            }
            connection.inputStream.bufferedReader().use { it.readText() }
        } finally {
            connection.disconnect()
        }
    }
}
