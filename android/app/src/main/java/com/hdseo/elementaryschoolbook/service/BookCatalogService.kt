package com.hdseo.elementaryschoolbook.service

import com.hdseo.elementaryschoolbook.data.Book
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.net.URL

class BookCatalogService {
    private val baseUrl = "https://22txbook.m-teacher.co.kr/book"

    suspend fun fetchShortUrl(book: Book): String = withContext(Dispatchers.IO) {
        val html = URL("$baseUrl/view.mrn?id=${book.viewPageId}").readText()
        parseShortUrl(html, book.linkTitle, book.viewSection)
            ?: throw Exception("${book.title} 다운로드 링크를 찾을 수 없습니다.")
    }

    private fun parseShortUrl(html: String, linkTitle: String, section: String): String? {
        val sectionMarker = ">$section</a>"
        var searchIndex = 0

        while (true) {
            val markerIndex = html.indexOf(sectionMarker, searchIndex)
            if (markerIndex == -1) break

            // 교과서 섹션 → 교사용 교과서 제외
            if (section == "교과서") {
                val preceding = html.substring(maxOf(0, markerIndex - 10), markerIndex)
                if ("교사용" in preceding) {
                    searchIndex = markerIndex + sectionMarker.length
                    continue
                }
            }

            val afterMarker = html.substring(markerIndex + sectionMarker.length)
            val endIndex = afterMarker.indexOf("viewSub")
            val sectionContent = if (endIndex != -1) afterMarker.substring(0, endIndex) else afterMarker

            val url = extractUrl(sectionContent, linkTitle) ?: firstShortUrl(sectionContent)
            if (url != null) return url

            searchIndex = markerIndex + sectionMarker.length
        }
        return null
    }

    private fun extractUrl(sectionHtml: String, title: String): String? {
        val regex = Regex("""href="(https://q\.mirae-n\.com/[A-Za-z0-9]+)"[^>]*>\s*([^<]+?)\s*<""")
        for (match in regex.findAll(sectionHtml)) {
            if (match.groupValues[2].trim() == title) return match.groupValues[1]
        }
        return null
    }

    private fun firstShortUrl(sectionHtml: String): String? =
        Regex("""href="(https://q\.mirae-n\.com/[A-Za-z0-9]+)"""")
            .find(sectionHtml)?.groupValues?.get(1)
}
