package com.hdseo.elementaryschoolbook.data

/**
 * YBM 초등 교과서 카탈로그
 *
 * YBM은 홍보관 JSON/API에서 contentId를 찾고,
 * REST API를 통해 PDF URL을 조회한 후 다운로드한다.
 *
 * viewPageId에는 contentId 또는 "book03|3학년 1학기|교과서" 형식의
 * 홍보관 선택자를 저장한다.
 *
 * 저자: 영어–김혜리/최희경, 수학–류희찬, 사회–남상준,
 *       음악–양소영, 체육–이기청, 보건–우옥영, 실과–이상원
 */
object YbmBookCatalog {

    private fun ybm(
        id: String, title: String, grade: Int, subject: String,
        contentId: String, section: String = "교과서"
    ) = Book(
        id = id, title = title, linkTitle = "", grade = grade,
        subject = subject, viewPageId = contentId,  // contentId 저장
        viewSection = section, publisher = "YBM"
    )

    private fun ybmPrcenter(
        id: String, title: String, grade: Int, subject: String,
        bookCode: String, semester: String, materialTitle: String = "교과서",
        section: String = "교과서"
    ) = ybm(
        id = id,
        title = title,
        grade = grade,
        subject = subject,
        contentId = "$bookCode|$semester|$materialTitle",
        section = section
    )

    // ─────────────────────────── 영어 (김혜리) 3~6 ──────────────────────────
    private val engKim = listOf(
        ybm("ybm-engK-3", "영어 3 (김혜리)", 3, "영어", "C20240816120059rPrQi"),
        ybm("ybm-engK-4", "영어 4 (김혜리)", 4, "영어", "C20240816120135GIwrj"),
        ybm("ybm-engK-5", "영어 5 (김혜리)", 5, "영어", "C20250807032906aheKd"),
        ybm("ybm-engK-6", "영어 6 (김혜리)", 6, "영어", "C202508070329066tlhB"),
    )

    // ─────────────────────────── 영어 (최희경) 3~6 ──────────────────────────
    private val engChoi = listOf(
        ybm("ybm-engC-3", "영어 3 (최희경)", 3, "영어", "C20240816121740R1Ekt"),
        ybm("ybm-engC-4", "영어 4 (최희경)", 4, "영어", "C20240816121804wj9fM"),
        ybm("ybm-engC-5", "영어 5 (최희경)", 5, "영어", "C202508070329062f4mo"),
        ybm("ybm-engC-6", "영어 6 (최희경)", 6, "영어", "C20250807032906ZC9fM"),
    )

    // ─────────────────────────── 수학 (류희찬) 3~6 ──────────────────────────
    private val math = listOf(
        ybmPrcenter("ybm-math-3-1", "수학 3-1 (류희찬)", 3, "수학", "book03", "3학년 1학기"),
        ybmPrcenter("ybm-math-3-2", "수학 3-2 (류희찬)", 3, "수학", "book03", "3학년 2학기"),
        ybmPrcenter("ybm-math-4-1", "수학 4-1 (류희찬)", 4, "수학", "book03", "4학년 1학기"),
        ybmPrcenter("ybm-math-4-2", "수학 4-2 (류희찬)", 4, "수학", "book03", "4학년 2학기"),
        ybmPrcenter("ybm-math-5-1", "수학 5-1 (류희찬)", 5, "수학", "book13", "5학년 1학기"),
        ybmPrcenter("ybm-math-5-2", "수학 5-2 (류희찬)", 5, "수학", "book13", "5학년 2학기"),
        ybmPrcenter("ybm-math-6-1", "수학 6-1 (류희찬)", 6, "수학", "book13", "6학년 1학기"),
        ybmPrcenter("ybm-math-6-2", "수학 6-2 (류희찬)", 6, "수학", "book13", "6학년 2학기"),
    )

    // ─────────────────────────── 사회 (남상준) 3~6 ──────────────────────────
    private val social = listOf(
        ybm("ybm-social-3-1", "사회 3-1 (남상준)", 3, "사회", "C20240902045856wp31r"),
        ybm("ybm-social-3-2", "사회 3-2 (남상준)", 3, "사회", "C20240816015542gknll"),
        ybm("ybm-social-4-1", "사회 4-1 (남상준)", 4, "사회", "C202408160156093zUWr"),
        ybm("ybm-social-4-2", "사회 4-2 (남상준)", 4, "사회", "C20240816015639uHIWr"),
        ybm("ybm-social-5-1", "사회 5-1 (남상준)", 5, "사회", "C202508070329030jaH0"),
        ybm("ybm-social-5-2", "사회 5-2 (남상준)", 5, "사회", "C20250807032904RCP5C"),
        ybm("ybm-social-6-1", "사회 6-1 (남상준)", 6, "사회", "C20250807032904iUgi9"),
        ybm("ybm-social-6-2", "사회 6-2 (남상준)", 6, "사회", "C20250807032904zKLBD"),
    )

    // ─────────────────────────── 음악 (양소영) 3~6 ──────────────────────────
    private val music = listOf(
        ybm("ybm-music-3", "음악 3 (양소영)", 3, "음악", "C20240816021257k42bR"),
        ybm("ybm-music-4", "음악 4 (양소영)", 4, "음악", "C20240816021909GRGRI"),
        ybm("ybm-music-5", "음악 5 (양소영)", 5, "음악", "C20250807032906VQt38"),
        ybm("ybm-music-6", "음악 6 (양소영)", 6, "음악", "C20250807032906w7eZR"),
    )

    // ─────────────────────────── 체육 (이기청) 3~6 ──────────────────────────
    private val pe = listOf(
        ybm("ybm-pe-3", "체육 3 (이기청)", 3, "체육", "C20240816023640zAPQb"),
        ybm("ybm-pe-4", "체육 4 (이기청)", 4, "체육", "C20240816023757mZPB0"),
        ybm("ybm-pe-5", "체육 5 (이기청)", 5, "체육", "C20250807032907Nwz2H"),
        ybm("ybm-pe-6", "체육 6 (이기청)", 6, "체육", "C20250807032907WlLiT"),
    )

    // ─────────────────────────── 보건 (우옥영) 5~6 ──────────────────────────
    private val health = listOf(
        ybm("ybm-health-5", "보건 5 (우옥영)", 5, "보건", "C20250807032904uOjVd"),
        ybm("ybm-health-6", "보건 6 (우옥영)", 6, "보건", "C20250807032904JBBDE"),
    )

    // ─────────────────────────── 실과 (이상원) 5~6 ──────────────────────────
    private val practical = listOf(
        ybm("ybm-practical-5", "실과 5 (이상원)", 5, "실과", "C20250807032905LHJ0N"),
        ybm("ybm-practical-6", "실과 6 (이상원)", 6, "실과", "C2025080703290591FwH"),
    )

    val all: List<Book> = engKim + engChoi + math + social + music + pe + health + practical
}
