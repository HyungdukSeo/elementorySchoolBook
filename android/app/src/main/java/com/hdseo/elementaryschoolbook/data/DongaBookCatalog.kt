package com.hdseo.elementaryschoolbook.data

/**
 * 동아출판(Dong-A) 초등 교과서 카탈로그
 *
 * 동아출판은 PDF 직접 다운로드를 제공하지 않고
 * 웹 기반 이북 뷰어(ecatalog5) 만 제공.
 * viewPageId 에 뷰어 URL 을 저장하여 외부 브라우저로 열기.
 *
 * 3~4학년 전 과목 + 5~6학년 일부 과목 제공.
 */
object DongaBookCatalog {

    private const val BASE = "https://ebook.dongapublishing.com/ebook/ecatalog5.asp?Dir="

    private fun da(
        id: String, title: String, grade: Int, subject: String,
        dirCode: String, section: String = "교과서"
    ) = Book(
        id = id, title = title, linkTitle = "", grade = grade,
        subject = subject, viewPageId = "$BASE$dirCode",
        viewSection = section, publisher = "동아출판"
    )

    // ─────────────────────────── 수학 3~4 ────────────────────────────────
    private val math = listOf(
        da("da-math-3-1",    "수학 3-1",    3, "수학", "2203"),
        da("da-math-3-2",    "수학 3-2",    3, "수학", "2206"),
        da("da-math-4-1",    "수학 4-1",    4, "수학", "2209"),
        da("da-math-4-2",    "수학 4-2",    4, "수학", "2213"),
    )

    // ─────────────────────────── 사회 3~4 ────────────────────────────────
    private val social = listOf(
        da("da-social-3-1",  "사회 3-1",    3, "사회", "2397"),
        da("da-social-3-2",  "사회 3-2",    3, "사회", "2443"),
        da("da-social-4-1",  "사회 4-1",    4, "사회", "2440"),
        da("da-social-4-2",  "사회 4-2",    4, "사회", "2441"),
    )

    // ─────────────────────────── 과학 3~4 ────────────────────────────────
    private val science = listOf(
        da("da-sci-3-1",     "과학 3-1",    3, "과학", "2268"),
        da("da-sci-3-2",     "과학 3-2",    3, "과학", "2272"),
        da("da-sci-4-1",     "과학 4-1",    4, "과학", "2444"),
        da("da-sci-4-2",     "과학 4-2",    4, "과학", "2445"),
    )

    // ─────────────────────────── 영어 3~4 ────────────────────────────────
    private val english = listOf(
        da("da-eng-3-1",     "영어 3-1",    3, "영어", "2224"),
        da("da-eng-3-2",     "영어 3-2",    3, "영어", "2228"),
    )

    // ─────────────────────────── 음악 3~4 ────────────────────────────────
    private val music = listOf(
        da("da-music-3",     "음악 3",      3, "음악", "2410"),
        da("da-music-4",     "음악 4",      4, "음악", "2411"),
    )

    // ─────────────────────────── 미술 3~4 ────────────────────────────────
    private val art = listOf(
        da("da-art-3",       "미술 3",      3, "미술", "2178"),
        da("da-art-4",       "미술 4",      4, "미술", "2190"),
    )

    // ─────────────────────────── 체육 3~4 ────────────────────────────────
    private val pe = listOf(
        da("da-pe-3",        "체육 3",      3, "체육", "2421"),
        da("da-pe-4",        "체육 4",      4, "체육", "2425"),
    )

    val all: List<Book> = math + social + science + english + music + art + pe
}
