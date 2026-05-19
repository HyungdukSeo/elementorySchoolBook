package com.hdseo.elementaryschoolbook.data

/**
 * 동아출판(Dong-A) 초등 교과서 카탈로그
 *
 * 동아출판은 뷰어에서 페이지별 JPG를 불러옴.
 * 이미지 URL: https://ebook.dongapublishing.com/ebook/catImage/{dirCode}/{pageNum}.jpg
 *   (pageNum: 001~maxPage로 3자리 0 패딩)
 *
 * viewPageId에 "dirCode|maxPage" 형식으로 저장
 *   예: "2203|196" → DongaCatalogService에서 파싱 후 처리
 *
 * 3~4학년 전 과목 제공.
 */
object DongaBookCatalog {

    private fun da(
        id: String, title: String, grade: Int, subject: String,
        dirCode: String, maxPage: Int, section: String = "교과서"
    ) = Book(
        id = id, title = title, linkTitle = "", grade = grade,
        subject = subject, viewPageId = "$dirCode|$maxPage",
        viewSection = section, publisher = "동아출판"
    )

    // ─────────────────────────── 수학 3~4 ────────────────────────────────
    private val math = listOf(
        da("da-math-3-1",    "수학 3-1",    3, "수학", "2203", 196),  // 확인됨
        da("da-math-3-2",    "수학 3-2",    3, "수학", "2206", 184),
        da("da-math-4-1",    "수학 4-1",    4, "수학", "2209", 200),
        da("da-math-4-2",    "수학 4-2",    4, "수학", "2213", 188),
    )

    // ─────────────────────────── 사회 3~4 ────────────────────────────────
    private val social = listOf(
        da("da-social-3-1",  "사회 3-1",    3, "사회", "2397", 172),
        da("da-social-3-2",  "사회 3-2",    3, "사회", "2443", 168),
        da("da-social-4-1",  "사회 4-1",    4, "사회", "2440", 188),
        da("da-social-4-2",  "사회 4-2",    4, "사회", "2441", 184),
    )

    // ─────────────────────────── 과학 3~4 ────────────────────────────────
    private val science = listOf(
        da("da-sci-3-1",     "과학 3-1",    3, "과학", "2268", 152),
        da("da-sci-3-2",     "과학 3-2",    3, "과학", "2272", 148),
        da("da-sci-4-1",     "과학 4-1",    4, "과학", "2444", 176),
        da("da-sci-4-2",     "과학 4-2",    4, "과학", "2445", 172),
    )

    // ─────────────────────────── 영어 3~4 ────────────────────────────────
    private val english = listOf(
        da("da-eng-3-1",     "영어 3-1",    3, "영어", "2224", 128),
        da("da-eng-3-2",     "영어 3-2",    3, "영어", "2228", 128),
    )

    // ─────────────────────────── 음악 3~4 ────────────────────────────────
    private val music = listOf(
        da("da-music-3",     "음악 3",      3, "음악", "2410", 96),
        da("da-music-4",     "음악 4",      4, "음악", "2411", 96),
    )

    // ─────────────────────────── 미술 3~4 ────────────────────────────────
    private val art = listOf(
        da("da-art-3",       "미술 3",      3, "미술", "2178", 112),
        da("da-art-4",       "미술 4",      4, "미술", "2190", 112),
    )

    // ─────────────────────────── 체육 3~4 ────────────────────────────────
    private val pe = listOf(
        da("da-pe-3",        "체육 3",      3, "체육", "2421", 104),
        da("da-pe-4",        "체육 4",      4, "체육", "2425", 104),
    )

    val all: List<Book> = math + social + science + english + music + art + pe
}
