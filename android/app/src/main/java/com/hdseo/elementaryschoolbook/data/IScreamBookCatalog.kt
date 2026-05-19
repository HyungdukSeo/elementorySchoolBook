package com.hdseo.elementaryschoolbook.data

/**
 * 아이스크림미디어(i-Scream Media) 초등 교과서 카탈로그
 *
 * viewPageId 에 직접 PDF 다운로드 URL 을 저장.
 * 전 학년(3~6) 전 과목 교과서 PDF 가 공개되어 있음.
 *
 * 저자: 수학–김성여, 과학–박일우, 사회–한춘희, 영어–박유미
 *       음악–조순이, 미술–손지현, 체육–김명숙, 실과–정영식
 *
 * URL 패턴: https://download.i-scream.co.kr/textbook/introduce/{fileName}.pdf
 */
object IScreamBookCatalog {

    private const val BASE = "https://download.i-scream.co.kr/textbook/introduce"

    private fun ic(
        id: String, title: String, grade: Int, subject: String,
        fileName: String, section: String = "교과서"
    ) = Book(
        id = id, title = title, linkTitle = "", grade = grade,
        subject = subject, viewPageId = "$BASE/$fileName.pdf",
        viewSection = section, publisher = "아이스크림미디어"
    )

    // ─────────────────────────── 수학 (김성여) ───────────────────────────
    private val math = listOf(
        ic("ic-math-3-1",    "수학 3-1 (김성여)",    3, "수학", "math_3-1_2022"),
        ic("ic-math-3-2",    "수학 3-2 (김성여)",    3, "수학", "math_3-2_2022"),
        ic("ic-math-4-1",    "수학 4-1 (김성여)",    4, "수학", "math_4-1_2022"),
        ic("ic-math-4-2",    "수학 4-2 (김성여)",    4, "수학", "math_4-2_2022"),
        ic("ic-math-5-1",    "수학 5-1 (김성여)",    5, "수학", "math_5-1_2022"),
        ic("ic-math-5-2",    "수학 5-2 (김성여)",    5, "수학", "math_5-2_2022"),
        ic("ic-math-6-1",    "수학 6-1 (김성여)",    6, "수학", "math_6-1_2022"),
        ic("ic-math-6-2",    "수학 6-2 (김성여)",    6, "수학", "math_6-2_2022"),
    )

    // ─────────────────────────── 수학익힘 (김성여) ────────────────────────
    private val mathWb = listOf(
        ic("ic-mathwb-3-1",  "수학익힘 3-1 (김성여)", 3, "수학익힘", "math_ikhim_3-1_2022", "수학익힘"),
        ic("ic-mathwb-3-2",  "수학익힘 3-2 (김성여)", 3, "수학익힘", "math_ikhim_3-2_2022", "수학익힘"),
        ic("ic-mathwb-4-1",  "수학익힘 4-1 (김성여)", 4, "수학익힘", "math_ikhim_4-1_2022", "수학익힘"),
        ic("ic-mathwb-4-2",  "수학익힘 4-2 (김성여)", 4, "수학익힘", "math_ikhim_4-2_2022", "수학익힘"),
        ic("ic-mathwb-5-1",  "수학익힘 5-1 (김성여)", 5, "수학익힘", "math_ikhim_5-1_2022", "수학익힘"),
        ic("ic-mathwb-5-2",  "수학익힘 5-2 (김성여)", 5, "수학익힘", "math_ikhim_5-2_2022", "수학익힘"),
        ic("ic-mathwb-6-1",  "수학익힘 6-1 (김성여)", 6, "수학익힘", "math_ikhim_6-1_2022", "수학익힘"),
        ic("ic-mathwb-6-2",  "수학익힘 6-2 (김성여)", 6, "수학익힘", "math_ikhim_6-2_2022", "수학익힘"),
    )

    // ─────────────────────────── 과학 (박일우) ───────────────────────────
    private val science = listOf(
        ic("ic-sci-3-1",     "과학 3-1 (박일우)",    3, "과학", "science_3-1_2022"),
        ic("ic-sci-3-2",     "과학 3-2 (박일우)",    3, "과학", "science_3-2_2022"),
        ic("ic-sci-4-1",     "과학 4-1 (박일우)",    4, "과학", "science_4-1_2022"),
        ic("ic-sci-4-2",     "과학 4-2 (박일우)",    4, "과학", "science_4-2_2022"),
        ic("ic-sci-5-1",     "과학 5-1 (박일우)",    5, "과학", "science_5-1_2022"),
        ic("ic-sci-5-2",     "과학 5-2 (박일우)",    5, "과학", "science_5-2_2022"),
        ic("ic-sci-6-1",     "과학 6-1 (박일우)",    6, "과학", "science_6-1_2022"),
        ic("ic-sci-6-2",     "과학 6-2 (박일우)",    6, "과학", "science_6-2_2022"),
    )

    // ─────────────────────────── 실험관찰 (박일우) ────────────────────────
    private val sciLab = listOf(
        ic("ic-lab-3-1",     "실험관찰 3-1 (박일우)", 3, "실험관찰", "science_silhum_3-1_2022", "실험관찰"),
        ic("ic-lab-3-2",     "실험관찰 3-2 (박일우)", 3, "실험관찰", "science_silhum_3-2_2022", "실험관찰"),
        ic("ic-lab-4-1",     "실험관찰 4-1 (박일우)", 4, "실험관찰", "science_silhum_4-1_2022", "실험관찰"),
        ic("ic-lab-4-2",     "실험관찰 4-2 (박일우)", 4, "실험관찰", "science_silhum_4-2_2022", "실험관찰"),
        ic("ic-lab-5-1",     "실험관찰 5-1 (박일우)", 5, "실험관찰", "science_silhum_5-1_2022", "실험관찰"),
        ic("ic-lab-5-2",     "실험관찰 5-2 (박일우)", 5, "실험관찰", "science_silhum_5-2_2022", "실험관찰"),
        ic("ic-lab-6-1",     "실험관찰 6-1 (박일우)", 6, "실험관찰", "science_silhum_6-1_2022", "실험관찰"),
        ic("ic-lab-6-2",     "실험관찰 6-2 (박일우)", 6, "실험관찰", "science_silhum_6-2_2022", "실험관찰"),
    )

    // ─────────────────────────── 사회 (한춘희) ───────────────────────────
    private val social = listOf(
        ic("ic-social-3-1",  "사회 3-1 (한춘희)",    3, "사회", "society_3-1_2022"),
        ic("ic-social-3-2",  "사회 3-2 (한춘희)",    3, "사회", "society_3-2_2022"),
        ic("ic-social-4-1",  "사회 4-1 (한춘희)",    4, "사회", "society_4-1_2022"),
        ic("ic-social-4-2",  "사회 4-2 (한춘희)",    4, "사회", "society_4-2_2022"),
        ic("ic-social-5-1",  "사회 5-1 (한춘희)",    5, "사회", "society_5-1_2022"),
        ic("ic-social-5-2",  "사회 5-2 (한춘희)",    5, "사회", "society_5-2_2022"),
        ic("ic-social-6-1",  "사회 6-1 (한춘희)",    6, "사회", "society_6-1_2022"),
        ic("ic-social-6-2",  "사회 6-2 (한춘희)",    6, "사회", "society_6-2_2022"),
    )

    // ─────────────────────────── 영어 (박유미) ───────────────────────────
    private val english = listOf(
        ic("ic-eng-3",       "영어 3 (박유미)",      3, "영어", "english_3_2022"),
        ic("ic-eng-4",       "영어 4 (박유미)",      4, "영어", "english_4_2022"),
        ic("ic-eng-5",       "영어 5 (박유미)",      5, "영어", "english_5_2022"),
        ic("ic-eng-6",       "영어 6 (박유미)",      6, "영어", "english_6_2022"),
    )

    // ─────────────────────────── 음악 (조순이) ───────────────────────────
    private val music = listOf(
        ic("ic-music-3",     "음악 3 (조순이)",      3, "음악", "music_3_2022"),
        ic("ic-music-4",     "음악 4 (조순이)",      4, "음악", "music_4_2022"),
        ic("ic-music-5",     "음악 5 (조순이)",      5, "음악", "music_5_2022"),
        ic("ic-music-6",     "음악 6 (조순이)",      6, "음악", "music_6_2022"),
    )

    // ─────────────────────────── 미술 (손지현) ───────────────────────────
    private val art = listOf(
        ic("ic-art-3",       "미술 3 (손지현)",      3, "미술", "art_3_2022"),
        ic("ic-art-4",       "미술 4 (손지현)",      4, "미술", "art_4_2022"),
        ic("ic-art-5",       "미술 5 (손지현)",      5, "미술", "art_5_2022"),
        ic("ic-art-6",       "미술 6 (손지현)",      6, "미술", "art_6_2022"),
    )

    // ─────────────────────────── 체육 (김명숙) ───────────────────────────
    private val pe = listOf(
        ic("ic-pe-3",        "체육 3 (김명숙)",      3, "체육", "physicaledu_3_2022"),
        ic("ic-pe-4",        "체육 4 (김명숙)",      4, "체육", "physicaledu_4_2022"),
        ic("ic-pe-5",        "체육 5 (김명숙)",      5, "체육", "physicaledu_5_2022"),
        ic("ic-pe-6",        "체육 6 (김명숙)",      6, "체육", "physicaledu_6_2022"),
    )

    // ─────────────────────────── 실과 (정영식) 5~6학년 ─────────────────────
    private val practical = listOf(
        ic("ic-practical-5", "실과 5 (정영식)",      5, "실과", "practice_5_2022"),
        ic("ic-practical-6", "실과 6 (정영식)",      6, "실과", "practice_6_2022"),
    )

    val all: List<Book> = math + mathWb + science + sciLab +
            social + english + music + art + pe + practical
}
