package com.hdseo.elementaryschoolbook.service

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

/**
 * 천재교육(tsherpa) 교과서 PDF 다운로드 서비스.
 *
 * 흐름:
 *  1. filePath(서버 내부 경로)를 받아
 *  2. streamdocs API 에 POST 로 문서 뷰어 URL 을 요청
 *  3. 응답의 alink 에서 streamdocsId 를 추출
 *  4. /v4/documents/{id} GET 으로 PDF 를 직접 다운로드
 */
class TsherpaCatalogService {

    private val apiUrl = "https://view.chunjae.co.kr/streamdocs/v4/custom/documents/view"
    private val pdfBaseUrl = "https://view.chunjae.co.kr/streamdocs/v4/documents"

    /**
     * filePath → 직접 다운로드 가능한 PDF URL 반환
     */
    suspend fun resolvePdfUrl(filePath: String): String = withContext(Dispatchers.IO) {
        val streamdocsId = fetchStreamdocsId(filePath)
        "$pdfBaseUrl/$streamdocsId"
    }

    private fun fetchStreamdocsId(filePath: String): String {
        val body = JSONObject().apply {
            put("srcFilePath", JSONArray().put("T:/tsherpa$filePath"))
            put("isLogin", "true")
            put("userType", "S")
            put("pageNumber", "pageNumber")
            put("isExternal", "y")
        }

        val conn = URL(apiUrl).openConnection() as HttpURLConnection
        conn.requestMethod = "POST"
        conn.doOutput = true
        conn.setRequestProperty("Content-Type", "application/json; charset=utf-8")
        conn.connectTimeout = 15_000
        conn.readTimeout = 15_000

        conn.outputStream.use { it.write(body.toString().toByteArray(Charsets.UTF_8)) }

        val responseCode = conn.responseCode
        if (responseCode != 200) {
            conn.disconnect()
            throw Exception("천재교육 서버 오류 ($responseCode)")
        }

        val json = conn.inputStream.bufferedReader().use { it.readText() }
        conn.disconnect()

        val alink = JSONObject(json).optString("alink", "")
        if (alink.isEmpty()) throw Exception("천재교육 문서 링크를 받지 못했습니다.")

        // alink 예: https://view.chunjae.co.kr/streamdocs/view/sd;streamdocsId=XXXX;isExternal=...
        val prefix = "streamdocsId="
        val start = alink.indexOf(prefix)
        if (start == -1) throw Exception("streamdocsId를 찾을 수 없습니다.")

        val idStart = start + prefix.length
        val idEnd = alink.indexOf(';', idStart).let { if (it == -1) alink.length else it }
        return alink.substring(idStart, idEnd)
    }
}
