package com.hdseo.elementaryschoolbook.service

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.pdf.PdfDocument
import com.hdseo.elementaryschoolbook.data.Book
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.io.File
import java.net.HttpURLConnection
import java.net.URL

class DongaCatalogService {

    private data class SubjectSource(
        val code: String,
        val groups: List<String>,
        val subject: String,
        val idPrefix: String,
        val fallbackGrades: List<Int> = emptyList()
    )

    private val sources = listOf(
        SubjectSource("P_EL_MAT", listOf("EL_3_4", "EL_5_6"), "수학", "math"),
        SubjectSource("P_EL_SOC", listOf("EL_3_4", "EL_5_6"), "사회", "social"),
        SubjectSource("P_EL_ATL", listOf("EL_5_6"), "사회과 부도", "atlas", fallbackGrades = listOf(5, 6)),
        SubjectSource("P_EL_SCI", listOf(""), "과학", "sci"),
        SubjectSource("P_EL_ENG", listOf("EL_3_4", "EL_5_6"), "영어", "eng"),
        SubjectSource("P_EL_MUS", listOf("EL_3_4", "EL_5_6"), "음악", "music"),
        SubjectSource("P_EL_ART", listOf("EL_3_4", "EL_5_6"), "미술", "art"),
        SubjectSource("P_EL_ATH", listOf("EL_3_4", "EL_5_6"), "체육", "pe"),
        SubjectSource("P_EL_PRA", listOf("EL_5_6"), "실과", "practical")
    )

    suspend fun fetchCatalogBooks(): List<Book> = withContext(Dispatchers.IO) {
        coroutineScope {
            sources.flatMap { source ->
                source.groups.map { group ->
                    async {
                        runCatching { fetchSubjectBooks(source, group) }.getOrDefault(emptyList())
                    }
                }
            }.awaitAll().flatten().distinctBy { it.catalogKey }
        }
    }

    /**
     * 동아출판 교과서: 페이지별 JPG → PDF 병합
     *
     * 이미지 URL 규칙:
     *   https://ebook.dongapublishing.com/ebook/catImage/{dirCode}/{pageNum}.jpg
     *   (pageNum은 001~maxPage로 3자리 0 패딩)
     */
    suspend fun downloadAndMerge(
        dirCode: String,
        maxPage: Int,
        destination: File,
        onProgress: (Float) -> Unit
    ) = withContext(Dispatchers.IO) {
        val resolvedMaxPage = if (maxPage > 0) maxPage else {
            fetchMaxPage(dirCode) ?: throw Exception("동아출판 페이지 수 확인 실패")
        }
        val tempDir = File(destination.parent, "donga_temp_$dirCode")
        val tmpPdf = File(destination.parent, "${destination.name}.tmp")
        try {
            tempDir.deleteRecursively()
            tempDir.mkdirs()
            if (tmpPdf.exists()) tmpPdf.delete()

            val imageFiles = mutableListOf<File>()

            // 다운로드 단계: 0~80%
            for (pageNum in 1..resolvedMaxPage) {
                val paddedNum = String.format("%03d", pageNum)
                val imageUrl = "https://ebook.dongapublishing.com/ebook/catImage/$dirCode/$paddedNum.jpg"
                val imageFile = File(tempDir, "$paddedNum.jpg")

                downloadImage(imageUrl, imageFile)
                imageFiles.add(imageFile)

                val progress = (pageNum.toFloat() / resolvedMaxPage) * 0.8f
                onProgress(progress)
            }

            if (imageFiles.size != resolvedMaxPage) {
                throw Exception("페이지 다운로드가 완료되지 않았습니다. (${imageFiles.size}/$resolvedMaxPage)")
            }

            // PDF 병합 단계: 80~100%
            mergeToPdf(imageFiles, tmpPdf)
            if (destination.exists()) destination.delete()
            if (!tmpPdf.renameTo(destination)) {
                throw Exception("PDF 파일 저장에 실패했습니다.")
            }
            onProgress(1.0f)
        } catch (e: Exception) {
            tmpPdf.delete()
            throw Exception("동아출판 PDF 생성 실패: ${e.message}")
        } finally {
            tempDir.deleteRecursively()
        }
    }

    private fun downloadImage(urlString: String, destination: File) {
        val url = URL(urlString)
        val connection = url.openConnection() as HttpURLConnection
        connection.connectTimeout = 10000
        connection.readTimeout = 10000

        try {
            if (connection.responseCode != 200) {
                throw Exception("HTTP ${connection.responseCode}: $urlString")
            }

            destination.outputStream().use { output ->
                connection.inputStream.use { input ->
                    input.copyTo(output)
                }
            }
        } finally {
            connection.disconnect()
        }
    }

    private fun mergeToPdf(imageFiles: List<File>, destination: File) {
        if (imageFiles.isEmpty()) {
            throw Exception("PDF로 변환할 페이지가 없습니다.")
        }

        val pdfDocument = PdfDocument()

        try {
            for ((index, imageFile) in imageFiles.withIndex()) {
                val bitmap = BitmapFactory.decodeFile(imageFile.absolutePath)
                    ?: throw Exception("${imageFile.name} 이미지를 읽을 수 없습니다.")

                // 스케일링: A4 크기 (1000x1414) 맞춤
                val scaledBitmap = Bitmap.createScaledBitmap(bitmap, 1000, 1414, true)

                val pageInfo = PdfDocument.PageInfo.Builder(1000, 1414, index + 1).create()
                val page = pdfDocument.startPage(pageInfo)

                page.canvas.drawBitmap(scaledBitmap, 0f, 0f, null)
                pdfDocument.finishPage(page)

                bitmap.recycle()
                scaledBitmap.recycle()
            }

            destination.outputStream().use { output ->
                pdfDocument.writeTo(output)
            }
        } finally {
            pdfDocument.close()
        }
    }

    private suspend fun fetchSubjectBooks(source: SubjectSource, group: String): List<Book> = coroutineScope {
        val infoUrl = "https://api.douclass.com/api/promotion/info" +
            "?subj_code=${source.code}&subj_group_code=&school_grade=$group"
        val info = getJsonObject(infoUrl)
        if (info.optInt("ret_code") != 200) return@coroutineScope emptyList()

        val list = info.optJSONObject("ret_data")
            ?.optJSONArray("promotionTextbookList")
            ?: return@coroutineScope emptyList()

        (0 until list.length()).map { index ->
            val item = list.getJSONObject(index)
            async {
                runCatching { fetchTextbookBooks(source, item) }.getOrDefault(emptyList())
            }
        }.awaitAll().flatten()
    }

    private fun fetchTextbookBooks(source: SubjectSource, item: JSONObject): List<Book> {
        val textbookId = item.optInt("textbook_id")
        if (textbookId <= 0) return emptyList()

        val title = item.optJSONObject("textBookInfo")
            ?.optString("txbook_title")
            ?.replace(Regex("""\s+"""), " ")
            ?.trim()
            .orEmpty()
        val grades = Regex("""(\d)""").find(title)
            ?.groupValues
            ?.getOrNull(1)
            ?.toIntOrNull()
            ?.let { listOf(it) }
            ?: source.fallbackGrades
        if (grades.isEmpty()) return emptyList()

        val textbookData = item.optJSONObject("promotionTextbookData")
            ?: fetchTextbookData(textbookId)
            ?: return emptyList()
        if (textbookData.optString("textbook_file_show") != "Y") return emptyList()

        val fileUrl = textbookData.optString("textbook_file_url")
        val dirCode = Regex("""[?&]Dir=(\d+)""").find(fileUrl)
            ?.groupValues
            ?.getOrNull(1)
            ?: return emptyList()

        return grades.map { grade ->
            val key = "da-${source.idPrefix}-${titleKey(title)}-$grade"
            Book(
                id = key,
                title = title,
                linkTitle = "",
                grade = grade,
                subject = source.subject,
                viewPageId = "$dirCode|0",
                viewSection = "교과서",
                publisher = "동아출판",
                catalogKey = key
            )
        }
    }

    private fun fetchTextbookData(textbookId: Int): JSONObject? {
        val data = getJsonObject(
            "https://api.douclass.com/api/promotion/textbook_data" +
                "?textbook_id=$textbookId&useLoading=false"
        )
        if (data.optInt("ret_code") != 200) return null

        return data.optJSONObject("ret_data")
            ?.optJSONObject("promotionTextbookData")
    }

    private fun fetchMaxPage(dirCode: String): Int? {
        val html = get("https://ebook.dongapublishing.com/ebook/ecatalog5.asp?Dir=$dirCode")
        return Regex("""set_pageinfo\('[^']*','\d+',\d+,(\d+),""")
            .find(html)
            ?.groupValues
            ?.getOrNull(1)
            ?.toIntOrNull()
    }

    private fun titleKey(title: String): String =
        title.replace(Regex("""\s+"""), "-").replace(Regex("""[^0-9A-Za-z가-힣-]"""), "")

    private fun getJsonObject(url: String): JSONObject = JSONObject(get(url))

    private fun get(url: String): String {
        val connection = URL(url).openConnection() as HttpURLConnection
        connection.requestMethod = "GET"
        connection.connectTimeout = 10000
        connection.readTimeout = 15000
        connection.setRequestProperty("Accept", "application/json")
        connection.setRequestProperty("Content-Type", "application/json")
        connection.setRequestProperty("Channel-Type", "CHN_MID_HI")
        connection.setRequestProperty("User-Agent", "Mozilla/5.0")

        return try {
            if (connection.responseCode != 200) {
                throw Exception("동아출판 서버 오류 (${connection.responseCode})")
            }
            connection.inputStream.bufferedReader().use { it.readText() }
        } finally {
            connection.disconnect()
        }
    }
}
