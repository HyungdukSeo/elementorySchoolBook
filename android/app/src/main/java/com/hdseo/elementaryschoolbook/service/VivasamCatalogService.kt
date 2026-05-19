package com.hdseo.elementaryschoolbook.service

import android.graphics.Bitmap
import android.graphics.pdf.PdfDocument
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.net.HttpURLConnection
import java.net.URL

/**
 * 비상교육(Visang) iBook PDF 다운로드 서비스.
 *
 * 비상교육 iBook 은 페이지별 개별 PDF 로 구성되어 있다.
 * 흐름:
 *  1. iBook ID 로 config.js 를 가져와 페이지 이름 배열(e_arrPageName) 파싱
 *  2. 각 페이지 PDF 를 다운로드
 *  3. PdfRenderer → PdfDocument 로 병합하여 단일 PDF 생성
 */
class VivasamCatalogService {

    private val configUrlTemplate =
        "https://ibook.vivasam.com/CBS_iBook/%s/contents/config/config.js"
    private val pageUrlTemplate =
        "https://ibook.vivasam.com/CBS_iBook/%s/contents/data/%s.pdf"

    /**
     * iBook ID → 단일 PDF 파일로 다운로드 및 병합
     */
    suspend fun downloadAndMerge(
        ibookId: String,
        destination: File,
        onProgress: (Float) -> Unit
    ) = withContext(Dispatchers.IO) {
        // 1. config.js 에서 페이지 이름 목록 파싱
        val pageNames = fetchPageNames(ibookId)
        if (pageNames.isEmpty()) throw Exception("비상교육 교과서 페이지 정보를 가져오지 못했습니다.")

        val totalPages = pageNames.size
        val tmpDir = File(destination.parent, "${destination.nameWithoutExtension}_tmp")
        tmpDir.mkdirs()

        try {
            // 2. 각 페이지 PDF 다운로드
            val pageFiles = mutableListOf<File>()
            for ((index, pageName) in pageNames.withIndex()) {
                val pageFile = File(tmpDir, "$index.pdf")
                val pageUrl = pageUrlTemplate.format(ibookId, pageName)
                downloadSinglePage(pageUrl, pageFile)
                pageFiles.add(pageFile)
                onProgress((index + 1).toFloat() / totalPages * 0.8f) // 80% 는 다운로드
            }

            // 3. 병합
            onProgress(0.85f)
            mergePdfPages(pageFiles, destination)
            onProgress(1.0f)
        } finally {
            // 임시 폴더 정리
            tmpDir.listFiles()?.forEach { it.delete() }
            tmpDir.delete()
        }
    }

    /**
     * config.js 에서 e_arrPageName 배열 파싱
     */
    private fun fetchPageNames(ibookId: String): List<String> {
        val url = configUrlTemplate.format(ibookId)
        val conn = URL(url).openConnection() as HttpURLConnection
        conn.connectTimeout = 15_000
        conn.readTimeout = 15_000
        conn.connect()

        val text = conn.inputStream.bufferedReader().use { it.readText() }
        conn.disconnect()

        // e_arrPageName = ["abc","def",...];
        val regex = Regex("""e_arrPageName\s*=\s*\[([^\]]+)]""")
        val match = regex.find(text) ?: return emptyList()

        return match.groupValues[1]
            .split(",")
            .map { it.trim().removeSurrounding("\"") }
            .filter { it.isNotEmpty() }
    }

    private fun downloadSinglePage(url: String, dest: File) {
        val conn = URL(url).openConnection() as HttpURLConnection
        conn.connectTimeout = 15_000
        conn.readTimeout = 30_000
        conn.connect()

        if (conn.responseCode != 200) {
            conn.disconnect()
            throw Exception("페이지 다운로드 실패: ${conn.responseCode}")
        }

        try {
            conn.inputStream.use { input ->
                dest.outputStream().use { output ->
                    input.copyTo(output, bufferSize = 16_384)
                }
            }
        } finally {
            conn.disconnect()
        }
    }

    /**
     * 개별 페이지 PDF 를 PdfRenderer 로 읽어 PdfDocument 로 합쳐 단일 PDF 생성.
     * 원본 해상도 그대로 Bitmap → PdfDocument Page 에 그린다.
     */
    private fun mergePdfPages(pageFiles: List<File>, destination: File) {
        val document = PdfDocument()
        var pageNumber = 1

        for (pageFile in pageFiles) {
            if (!pageFile.exists() || pageFile.length() == 0L) continue

            val fd = ParcelFileDescriptor.open(pageFile, ParcelFileDescriptor.MODE_READ_ONLY)
            try {
                val renderer = PdfRenderer(fd)
                for (i in 0 until renderer.pageCount) {
                    val pdfPage = renderer.openPage(i)
                    // 2x 스케일 for crisp rendering on mobile
                    val width = pdfPage.width * 2
                    val height = pdfPage.height * 2
                    val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                    bitmap.eraseColor(android.graphics.Color.WHITE)
                    pdfPage.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                    pdfPage.close()

                    val pageInfo = PdfDocument.PageInfo.Builder(width, height, pageNumber++).create()
                    val page = document.startPage(pageInfo)
                    page.canvas.drawBitmap(bitmap, 0f, 0f, null)
                    document.finishPage(page)
                    bitmap.recycle()
                }
                renderer.close()
            } finally {
                fd.close()
            }
        }

        val tmp = File(destination.parent, "${destination.name}.tmp")
        try {
            tmp.outputStream().use { document.writeTo(it) }
            document.close()
            if (destination.exists()) destination.delete()
            tmp.renameTo(destination)
        } catch (e: Exception) {
            tmp.delete()
            document.close()
            throw e
        }
    }
}
