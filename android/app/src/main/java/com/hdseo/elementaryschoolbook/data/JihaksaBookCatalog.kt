package com.hdseo.elementaryschoolbook.data

/**
 * 지학사(Jihaksa) 초등 교과서 카탈로그
 *
 * viewPageId 에 S3 PDF 직접 다운로드 URL 을 저장.
 * 현재 3~4학년 교과서만 공개되어 있음.
 *
 * 저자 정보는 별도 표기 없음(출판사 대표 집필).
 * URL 패턴: https://s3.ap-northeast-2.amazonaws.com/tsol.jihak.co.kr/tsol/22tp/e/{subject}/JIHAKSA_{한글명}_{grade}_{type}.pdf
 */
object JihaksaBookCatalog {

    private const val BASE = "https://s3.ap-northeast-2.amazonaws.com/tsol.jihak.co.kr/tsol/22tp/e"

    private fun jh(
        id: String, title: String, grade: Int, subject: String,
        pdfUrl: String, section: String = "교과서"
    ) = Book(
        id = id, title = title, linkTitle = "", grade = grade,
        subject = subject, viewPageId = pdfUrl,
        viewSection = section, publisher = "지학사"
    )

    // ─────────────────────────── 수학 3~4 ────────────────────────────────
    private val math = listOf(
        jh("jh-math-3-1",    "수학 3-1",    3, "수학", "$BASE/mat/JIHAKSA_%EC%88%98%ED%95%99_%EC%B4%88_3-1_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
        jh("jh-math-3-2",    "수학 3-2",    3, "수학", "$BASE/mat/JIHAKSA_%EC%88%98%ED%95%99_%EC%B4%88_3-2_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
        jh("jh-math-4-1",    "수학 4-1",    4, "수학", "$BASE/mat/JIHAKSA_%EC%88%98%ED%95%99_%EC%B4%88_4-1_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
        jh("jh-math-4-2",    "수학 4-2",    4, "수학", "$BASE/mat/JIHAKSA_%EC%88%98%ED%95%99_%EC%B4%88_4-2_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
    )

    // ─────────────────────────── 수학익힘 3~4 ───────────────────────────
    private val mathWb = listOf(
        jh("jh-mathwb-3-1",  "수학익힘 3-1", 3, "수학익힘", "$BASE/mat/JIHAKSA_%EC%88%98%ED%95%99%EC%9D%B5%ED%9E%98_%EC%B4%88_3-1_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf", "수학익힘"),
        jh("jh-mathwb-3-2",  "수학익힘 3-2", 3, "수학익힘", "$BASE/mat/JIHAKSA_%EC%88%98%ED%95%99%EC%9D%B5%ED%9E%98_%EC%B4%88_3-2_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf", "수학익힘"),
        jh("jh-mathwb-4-1",  "수학익힘 4-1", 4, "수학익힘", "$BASE/mat/JIHAKSA_%EC%88%98%ED%95%99%EC%9D%B5%ED%9E%98_%EC%B4%88_4-1_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf", "수학익힘"),
        jh("jh-mathwb-4-2",  "수학익힘 4-2", 4, "수학익힘", "$BASE/mat/JIHAKSA_%EC%88%98%ED%95%99%EC%9D%B5%ED%9E%98_%EC%B4%88_4-2_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf", "수학익힘"),
    )

    // ─────────────────────────── 사회 3~4 ────────────────────────────────
    private val social = listOf(
        jh("jh-social-3-1",  "사회 3-1",    3, "사회", "$BASE/soc/JIHAKSA_%EC%82%AC%ED%9A%8C_%EC%B4%88_3-1_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
        jh("jh-social-3-2",  "사회 3-2",    3, "사회", "$BASE/soc/JIHAKSA_%EC%82%AC%ED%9A%8C_%EC%B4%88_3-2_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
        jh("jh-social-4-1",  "사회 4-1",    4, "사회", "$BASE/soc/JIHAKSA_%EC%82%AC%ED%9A%8C_%EC%B4%88_4-1_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
    )

    // ─────────────────────────── 과학 3~4 ────────────────────────────────
    private val science = listOf(
        jh("jh-sci-3-1",     "과학 3-1",    3, "과학", "$BASE/sci/JIHAKSA_%EA%B3%BC%ED%95%99_%EC%B4%88_3-1_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
        jh("jh-sci-3-2",     "과학 3-2",    3, "과학", "$BASE/sci/JIHAKSA_%EA%B3%BC%ED%95%99_%EC%B4%88_3-2_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
        jh("jh-sci-4-1",     "과학 4-1",    4, "과학", "$BASE/sci/JIHAKSA_%EA%B3%BC%ED%95%99_%EC%B4%88_4-1_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
        jh("jh-sci-4-2",     "과학 4-2",    4, "과학", "$BASE/sci/JIHAKSA_%EA%B3%BC%ED%95%99_%EC%B4%88_4-2_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
    )

    // ─────────────────────────── 실험관찰 3~4 ───────────────────────────
    private val sciLab = listOf(
        jh("jh-lab-3-1",     "실험관찰 3-1", 3, "실험관찰", "$BASE/sci/JIHAKSA_%EA%B3%BC%ED%95%99_%EC%B4%88_3-1_%EC%8B%A4%ED%97%98%EA%B4%80%EC%B0%B0.pdf", "실험관찰"),
        jh("jh-lab-3-2",     "실험관찰 3-2", 3, "실험관찰", "$BASE/sci/JIHAKSA_%EA%B3%BC%ED%95%99_%EC%B4%88_3-2_%EC%8B%A4%ED%97%98%EA%B4%80%EC%B0%B0.pdf", "실험관찰"),
        jh("jh-lab-4-1",     "실험관찰 4-1", 4, "실험관찰", "$BASE/sci/JIHAKSA_%EA%B3%BC%ED%95%99_%EC%B4%88_4-1_%EC%8B%A4%ED%97%98%EA%B4%80%EC%B0%B0.pdf", "실험관찰"),
        jh("jh-lab-4-2",     "실험관찰 4-2", 4, "실험관찰", "$BASE/sci/JIHAKSA_%EA%B3%BC%ED%95%99_%EC%B4%88_4-2_%EC%8B%A4%ED%97%98%EA%B4%80%EC%B0%B0.pdf", "실험관찰"),
    )

    // ─────────────────────────── 음악 3~4 ────────────────────────────────
    private val music = listOf(
        jh("jh-music-3",     "음악 3",      3, "음악", "$BASE/mus/JIHAKSA_%EC%9D%8C%EC%95%85_%EC%B4%88_3_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
        jh("jh-music-4",     "음악 4",      4, "음악", "$BASE/mus/JIHAKSA_%EC%9D%8C%EC%95%85_%EC%B4%88_4_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
    )

    // ─────────────────────────── 미술 3~4 ────────────────────────────────
    private val art = listOf(
        jh("jh-art-3",       "미술 3",      3, "미술", "$BASE/art/JIHAKSA_%EB%AF%B8%EC%88%A0_%EC%B4%88_3_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
        jh("jh-art-4",       "미술 4",      4, "미술", "$BASE/art/JIHAKSA_%EB%AF%B8%EC%88%A0_%EC%B4%88_4_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
    )

    // ─────────────────────────── 체육 3~4 ────────────────────────────────
    private val pe = listOf(
        jh("jh-pe-3",        "체육 3",      3, "체육", "$BASE/phy/JIHAKSA_%EC%B2%B4%EC%9C%A1_%EC%B4%88_3_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
        jh("jh-pe-4",        "체육 4",      4, "체육", "$BASE/phy/JIHAKSA_%EC%B2%B4%EC%9C%A1_%EC%B4%88_4_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
    )

    val all: List<Book> = math + mathWb + social + science + sciLab + music + art + pe
}
