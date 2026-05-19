package com.hdseo.elementaryschoolbook.service

import com.hdseo.elementaryschoolbook.data.Book
import java.net.URLEncoder
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject

class YbmCatalogService {

    /**
     * YBM 책 정보로부터 PDF 다운로드 URL 추출.
     *
     * viewPageId는 두 형식을 지원한다.
     * - C...: 기존 contentId 직접 지정
     * - book03|3학년 1학기|교과서: 홍보관 JSON/API에서 contentId 조회
     */
    suspend fun resolvePdfUrl(book: Book): String = withContext(Dispatchers.IO) {
        try {
            val contentId = if (book.viewPageId.startsWith("C")) {
                book.viewPageId
            } else {
                resolveContentId(book.viewPageId)
            }
            return@withContext resolvePdfUrlByContentId(contentId)
        } catch (e: Exception) {
            throw Exception("YBM PDF URL 조회 실패: ${e.message}")
        }
    }

    /**
     * 기존 호출부 호환용: contentId 직접 지정.
     */
    suspend fun resolvePdfUrl(contentId: String): String = withContext(Dispatchers.IO) {
        try {
            return@withContext resolvePdfUrlByContentId(contentId)
        } catch (e: Exception) {
            throw Exception("YBM PDF URL 조회 실패: ${e.message}")
        }
    }

    suspend fun fetchCatalogBooks(): List<Book> = withContext(Dispatchers.IO) {
        val bookCodes = listOf(
            "book01", "book02", "book03", "book04", "book05", "book06",
            "book07", "book08", "book11", "book12", "book13", "book14",
            "book15", "book16"
        )

        bookCodes.flatMap { bookCode ->
            runCatching { fetchCatalogBooks(bookCode) }.getOrDefault(emptyList())
        }
    }

    private fun fetchCatalogBooks(bookCode: String): List<Book> {
        val bookJson = getJsonObject("https://www.ybmcloud.com/prcenter/book/ele/$bookCode.json")
        val textbookInfo = bookJson.optJSONArray("TEXTBOOK_INFO") ?: return emptyList()
        val titleInfo = parseTitleInfo(bookJson.optString("title"))

        val ids = buildList {
            for (i in 0 until textbookInfo.length()) {
                val id = textbookInfo.getJSONObject(i).optString("TEXTBOOK_ID")
                if (id.isNotBlank()) add(id)
            }
        }
        if (ids.isEmpty()) return emptyList()

        val query = ids.joinToString("&") {
            "textbookIds=${URLEncoder.encode(it, Charsets.UTF_8.name())}"
        }
        val materials = getJsonArray("https://www.ybmcloud.com/rest/prcenter/textbooks?$query")

        val semesterByTextbookId = mutableMapOf<String, String>()
        for (i in 0 until textbookInfo.length()) {
            val item = textbookInfo.getJSONObject(i)
            semesterByTextbookId[item.optString("TEXTBOOK_ID")] = item.optString("SEMESTER")
        }

        val books = mutableListOf<Book>()
        for (i in 0 until materials.length()) {
            val item = materials.getJSONObject(i)
            if (item.optString("mtrlTitle") != "교과서") continue

            val textbookId = item.optString("textbookId")
            val contentId = item.optString("contentid")
            val semester = semesterByTextbookId[textbookId].orEmpty()
            if (textbookId.isBlank() || contentId.isBlank() || semester.isBlank()) continue

            val grade = semester.firstOrNull { it.isDigit() }?.digitToIntOrNull() ?: continue
            if (grade !in 3..6) continue

            val title = buildDisplayTitle(titleInfo.subject, semester, titleInfo.author)
            val key = "ybm-$bookCode-$semester-교과서"
            books += Book(
                id = "$key-${contentId.takeLast(6)}",
                title = title,
                linkTitle = "",
                grade = grade,
                subject = titleInfo.subject,
                viewPageId = contentId,
                viewSection = "교과서",
                publisher = "YBM",
                catalogKey = key
            )
        }
        return books
    }

    private fun resolveContentId(selector: String): String {
        val parts = selector.split("|")
        if (parts.size != 3) {
            throw Exception("YBM 데이터 형식 오류")
        }

        val bookCode = parts[0]
        val semester = parts[1]
        val materialTitle = parts[2]

        val bookJson = getJsonObject("https://www.ybmcloud.com/prcenter/book/ele/$bookCode.json")
        val textbookInfo = bookJson.optJSONArray("TEXTBOOK_INFO")
            ?: throw Exception("YBM TEXTBOOK_INFO 없음: $bookCode")

        val textbookId = findTextbookId(textbookInfo, semester)
            ?: throw Exception("YBM 학기 정보를 찾을 수 없습니다: $semester")

        val encodedTextbookId = URLEncoder.encode(textbookId, Charsets.UTF_8.name())
        val materials = getJsonArray(
            "https://www.ybmcloud.com/rest/prcenter/textbooks?textbookIds=$encodedTextbookId"
        )

        for (i in 0 until materials.length()) {
            val item = materials.getJSONObject(i)
            if (item.optString("textbookId") == textbookId &&
                item.optString("mtrlTitle") == materialTitle
            ) {
                return item.optString("contentid")
                    .takeIf { it.isNotBlank() }
                    ?: throw Exception("YBM contentId 없음: $materialTitle")
            }
        }

        throw Exception("YBM 자료를 찾을 수 없습니다: $semester $materialTitle")
    }

    private data class TitleInfo(val subject: String, val author: String)

    private fun parseTitleInfo(rawTitle: String): TitleInfo {
        val author = Regex("""\(([^)]+)\)""").find(rawTitle)?.groupValues?.getOrNull(1).orEmpty()
        val subject = rawTitle
            .replace(Regex("""\([^)]*\)"""), "")
            .replace(Regex("""\d+\s*~\s*\d+학년군"""), "")
            .trim()
            .ifBlank { "교과서" }
        return TitleInfo(subject, author)
    }

    private fun buildDisplayTitle(subject: String, semester: String, author: String): String {
        val numbers = Regex("""(\d+)학년(?:\s*(\d+)학기)?""").find(semester)?.groupValues
        val grade = numbers?.getOrNull(1).orEmpty()
        val term = numbers?.getOrNull(2).orEmpty()
        val gradeLabel = if (grade.isBlank()) semester else if (term.isBlank()) grade else "$grade-$term"
        return if (author.isBlank()) "$subject $gradeLabel" else "$subject $gradeLabel ($author)"
    }

    private fun findTextbookId(textbookInfo: JSONArray, semester: String): String? {
        for (i in 0 until textbookInfo.length()) {
            val item = textbookInfo.getJSONObject(i)
            if (item.optString("SEMESTER") == semester) {
                return item.optString("TEXTBOOK_ID").takeIf { it.isNotBlank() }
            }
        }
        return null
    }

    private fun resolvePdfUrlByContentId(contentId: String): String {
        val url = "https://www.ybmcloud.com/rest/viewer/getContents?contentsId=$contentId"
        val json = getJsonObject(url)

        return json.optString("viewFilePath", "")
            .takeIf { it.isNotEmpty() }
            ?: json.optString("uploadFilePath", "")
                .takeIf { it.isNotEmpty() }
            ?: throw Exception("YBM API: PDF URL not found in response")
    }

    private fun getJsonObject(url: String): JSONObject {
        val responseBody = get(url)
        return JSONObject(responseBody)
    }

    private fun getJsonArray(url: String): JSONArray {
        val responseBody = get(url)
        return JSONArray(responseBody)
    }

    private fun get(url: String): String {
        val connection = java.net.URL(url).openConnection() as java.net.HttpURLConnection
        connection.requestMethod = "GET"
        connection.connectTimeout = 10000
        connection.readTimeout = 10000

        return try {
            val responseCode = connection.responseCode
            if (responseCode != 200) {
                throw Exception("YBM API error: HTTP $responseCode")
            }
            connection.inputStream.bufferedReader().readText()
        } finally {
            connection.disconnect()
        }
    }
}
