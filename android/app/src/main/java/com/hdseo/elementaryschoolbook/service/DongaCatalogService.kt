package com.hdseo.elementaryschoolbook.service

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.pdf.PdfDocument
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.net.URL

class DongaCatalogService {

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
        val tempDir = File(destination.parent, "donga_temp_$dirCode")
        val tmpPdf = File(destination.parent, "${destination.name}.tmp")
        try {
            tempDir.deleteRecursively()
            tempDir.mkdirs()
            if (tmpPdf.exists()) tmpPdf.delete()

            val imageFiles = mutableListOf<File>()

            // 다운로드 단계: 0~80%
            for (pageNum in 1..maxPage) {
                val paddedNum = String.format("%03d", pageNum)
                val imageUrl = "https://ebook.dongapublishing.com/ebook/catImage/$dirCode/$paddedNum.jpg"
                val imageFile = File(tempDir, "$paddedNum.jpg")

                downloadImage(imageUrl, imageFile)
                imageFiles.add(imageFile)

                val progress = (pageNum.toFloat() / maxPage) * 0.8f
                onProgress(progress)
            }

            if (imageFiles.size != maxPage) {
                throw Exception("페이지 다운로드가 완료되지 않았습니다. (${imageFiles.size}/$maxPage)")
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
        val connection = url.openConnection() as java.net.HttpURLConnection
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
}
