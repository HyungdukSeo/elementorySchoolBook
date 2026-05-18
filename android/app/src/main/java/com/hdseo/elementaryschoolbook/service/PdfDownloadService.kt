package com.hdseo.elementaryschoolbook.service

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.net.HttpURLConnection
import java.net.URL

class PdfDownloadService {

    suspend fun downloadPdf(
        url: String,
        destination: File,
        isDirectUrl: Boolean = false,
        onProgress: (Float) -> Unit
    ) = withContext(Dispatchers.IO) {
        val finalUrl = if (isDirectUrl) url else resolvePdfUrl(url)
        downloadFile(finalUrl, destination, onProgress)
    }

    /**
     * q.mirae-n.com 단축 URL → 302 Location 헤더에서 file= 파라미터 raw 추출
     */
    private fun resolvePdfUrl(shortUrl: String): String {
        val conn = URL(shortUrl).openConnection() as HttpURLConnection
        conn.instanceFollowRedirects = false
        conn.connectTimeout = 15_000
        conn.readTimeout = 15_000
        conn.connect()

        val location = conn.getHeaderField("Location")
        conn.disconnect()

        if (location.isNullOrEmpty()) throw Exception("다운로드 링크를 가져오지 못했습니다.")

        val fileStart = location.indexOf("file=")
        if (fileStart == -1) throw Exception("PDF URL을 찾을 수 없습니다.")

        var rawPdfUrl = location.substring(fileStart + 5) // "file=" 이후
        for (delim in listOf("&thumbnail_url=", "&down_url=")) {
            val idx = rawPdfUrl.indexOf(delim)
            if (idx != -1) { rawPdfUrl = rawPdfUrl.substring(0, idx); break }
        }
        return rawPdfUrl
    }

    private fun downloadFile(url: String, dest: File, onProgress: (Float) -> Unit) {
        val conn = URL(url).openConnection() as HttpURLConnection
        conn.connectTimeout = 30_000
        conn.readTimeout = 60_000
        conn.connect()

        val total = conn.contentLengthLong
        var downloaded = 0L

        val tmp = File(dest.parent, "${dest.name}.tmp")
        try {
            conn.inputStream.use { input ->
                tmp.outputStream().use { output ->
                    val buf = ByteArray(16_384)
                    var n: Int
                    while (input.read(buf).also { n = it } != -1) {
                        output.write(buf, 0, n)
                        downloaded += n
                        if (total > 0) onProgress(downloaded.toFloat() / total)
                    }
                }
            }
            if (dest.exists()) dest.delete()
            tmp.renameTo(dest)
        } catch (e: Exception) {
            tmp.delete()
            throw e
        } finally {
            conn.disconnect()
        }
    }
}
