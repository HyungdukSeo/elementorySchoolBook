package com.hdseo.elementaryschoolbook.data

object BookCatalog {
    // ── 미래엔 (Mirae-N)
    private val miraeN = listOf(
        // 3학년
        Book("math-3-1",     "수학 3-1",     "수학3-1",      3, "수학",    "1",       publisher = "미래엔"),
        Book("math-3-2",     "수학 3-2",     "수학3-2",      3, "수학",    "1",       publisher = "미래엔"),
        Book("social-3-1",   "사회 3-1",     "사회3-1",      3, "사회",    "5",       publisher = "미래엔"),
        Book("social-3-2",   "사회 3-2",     "사회3-2",      3, "사회",    "5",       publisher = "미래엔"),
        Book("science-3-1",  "과학 3-1",     "과학3-1",      3, "과학",    "9",       publisher = "미래엔"),
        Book("science-3-2",  "과학 3-2",     "과학3-2",      3, "과학",    "9",       publisher = "미래엔"),
        Book("english-3",    "영어 3",        "영어3",         3, "영어",    "13",      publisher = "미래엔"),
        Book("art-3",        "미술 3",        "미술3",         3, "미술",    "15",      publisher = "미래엔"),
        Book("music-3",      "음악 3",        "음악3",         3, "음악",    "10022",   publisher = "미래엔"),
        Book("pe-3",         "체육 3",        "체육3",         3, "체육",    "17",      publisher = "미래엔"),
        Book("math-wb-3-1",  "수학익힘 3-1", "수학익힘3-1", 3, "수학익힘", "1",  "수학익힘", publisher = "미래엔"),
        Book("math-wb-3-2",  "수학익힘 3-2", "수학익힘3-2", 3, "수학익힘", "1",  "수학익힘", publisher = "미래엔"),
        Book("sci-lab-3-1",  "실험관찰 3-1", "실험관찰3-1", 3, "실험관찰", "9",  "실험관찰", publisher = "미래엔"),
        Book("sci-lab-3-2",  "실험관찰 3-2", "실험관찰3-2", 3, "실험관찰", "9",  "실험관찰", publisher = "미래엔"),

        // 4학년
        Book("math-4-1",     "수학 4-1",     "수학4-1",      4, "수학",    "1",       publisher = "미래엔"),
        Book("math-4-2",     "수학 4-2",     "수학4-2",      4, "수학",    "1",       publisher = "미래엔"),
        Book("social-4-1",   "사회 4-1",     "사회4-1",      4, "사회",    "5",       publisher = "미래엔"),
        Book("social-4-2",   "사회 4-2",     "사회4-2",      4, "사회",    "5",       publisher = "미래엔"),
        Book("science-4-1",  "과학 4-1",     "과학4-1",      4, "과학",    "9",       publisher = "미래엔"),
        Book("science-4-2",  "과학 4-2",     "과학4-2",      4, "과학",    "9",       publisher = "미래엔"),
        Book("english-4",    "영어 4",        "영어4",         4, "영어",    "14",      publisher = "미래엔"),
        Book("art-4",        "미술 4",        "미술4",         4, "미술",    "15",      publisher = "미래엔"),
        Book("music-4",      "음악 4",        "음악4",         4, "음악",    "10022",   publisher = "미래엔"),
        Book("pe-4",         "체육 4",        "체육4",         4, "체육",    "17",      publisher = "미래엔"),
        Book("math-wb-4-1",  "수학익힘 4-1", "수학익힘4-1", 4, "수학익힘", "1",  "수학익힘", publisher = "미래엔"),
        Book("math-wb-4-2",  "수학익힘 4-2", "수학익힘4-2", 4, "수학익힘", "1",  "수학익힘", publisher = "미래엔"),
        Book("sci-lab-4-1",  "실험관찰 4-1", "실험관찰4-1", 4, "실험관찰", "9",  "실험관찰", publisher = "미래엔"),
        Book("sci-lab-4-2",  "실험관찰 4-2", "실험관찰4-2", 4, "실험관찰", "9",  "실험관찰", publisher = "미래엔"),

        // 5학년
        Book("math-5-1",     "수학 5-1",     "수학5-1",        5, "수학",    "10004",   publisher = "미래엔"),
        Book("math-5-2",     "수학 5-2",     "수학5-2",        5, "수학",    "10004",   publisher = "미래엔"),
        Book("social-5-1",   "사회 5-1",     "사회5-1",        5, "사회",    "10008",   publisher = "미래엔"),
        Book("social-5-2",   "사회 5-2",     "사회5-2",        5, "사회",    "10008",   publisher = "미래엔"),
        Book("science-5-1",  "과학 5-1",     "과학5-1",        5, "과학",    "10012",   publisher = "미래엔"),
        Book("science-5-2",  "과학 5-2",     "과학5-2",        5, "과학",    "10012",   publisher = "미래엔"),
        Book("english-5",    "영어 5",        "영어5",           5, "영어",    "10016",   publisher = "미래엔"),
        Book("art-5",        "미술 5",        "미술5",           5, "미술",    "10018",   publisher = "미래엔"),
        Book("music-5",      "음악 5",        "음악5",           5, "음악",    "10022",   publisher = "미래엔"),
        Book("pe-5",         "체육 5",        "체육5",           5, "체육",    "10020",   publisher = "미래엔"),
        Book("practical-5",  "실과 5",        "실과5",           5, "실과",    "10026",   publisher = "미래엔"),
        Book("math-wb-5-1",  "수학익힘 5-1", "수학익힘 5-1", 5, "수학익힘", "10004", "수학익힘", publisher = "미래엔"),
        Book("math-wb-5-2",  "수학익힘 5-2", "수학익힘 5-2", 5, "수학익힘", "10004", "수학익힘", publisher = "미래엔"),
        Book("sci-lab-5-1",  "실험관찰 5-1", "실험관찰 5-1", 5, "실험관찰", "10012", "실험관찰", publisher = "미래엔"),
        Book("sci-lab-5-2",  "실험관찰 5-2", "실험관찰 5-2", 5, "실험관찰", "10012", "실험관찰", publisher = "미래엔"),

        // 6학년
        Book("math-6-1",     "수학 6-1",     "수학6-1",        6, "수학",    "10004",   publisher = "미래엔"),
        Book("math-6-2",     "수학 6-2",     "수학6-2",        6, "수학",    "10004",   publisher = "미래엔"),
        Book("social-6-1",   "사회 6-1",     "사회6-1",        6, "사회",    "10008",   publisher = "미래엔"),
        Book("social-6-2",   "사회 6-2",     "사회6-2",        6, "사회",    "10008",   publisher = "미래엔"),
        Book("science-6-1",  "과학 6-1",     "과학6-1",        6, "과학",    "10012",   publisher = "미래엔"),
        Book("science-6-2",  "과학 6-2",     "과학6-2",        6, "과학",    "10012",   publisher = "미래엔"),
        Book("english-6",    "영어 6",        "영어6",           6, "영어",    "10017",   publisher = "미래엔"),
        Book("art-6",        "미술 6",        "미술6",           6, "미술",    "10018",   publisher = "미래엔"),
        Book("music-6",      "음악 6",        "음악6",           6, "음악",    "10022",   publisher = "미래엔"),
        Book("pe-6",         "체육 6",        "체육6",           6, "체육",    "10020",   publisher = "미래엔"),
        Book("practical-6",  "실과 6",        "실과6",           6, "실과",    "10026",   publisher = "미래엔"),
        Book("math-wb-6-1",  "수학익힘 6-1", "수학익힘 6-1", 6, "수학익힘", "10004", "수학익힘", publisher = "미래엔"),
        Book("math-wb-6-2",  "수학익힘 6-2", "수학익힘 6-2", 6, "수학익힘", "10004", "수학익힘", publisher = "미래엔"),
        Book("sci-lab-6-1",  "실험관찰 6-1", "실험관찰 6-1", 6, "실험관찰", "10012", "실험관찰", publisher = "미래엔"),
        Book("sci-lab-6-2",  "실험관찰 6-2", "실험관찰 6-2", 6, "실험관찰", "10012", "실험관찰", publisher = "미래엔"),
    )

    // ── 천재교육 (Chunjae)
    private val chunjae = listOf(
        Book("cj-math-3-1-p", "수학 3-1 (박만구)", "", 3, "수학", "https://view.chunjae.co.kr/streamdocs/view/sd;streamdocsId=ID_MATH_3_1_P", publisher = "천재교육"),
        Book("cj-math-3-1-h", "수학 3-1 (한대희)", "", 3, "수학", "https://view.chunjae.co.kr/streamdocs/view/sd;streamdocsId=ID_MATH_3_1_H", publisher = "천재교육"),
        Book("cj-social-3-1", "사회 3-1 (김정인)", "", 3, "사회", "https://view.chunjae.co.kr/streamdocs/view/sd;streamdocsId=ID_SOCIAL_3_1", publisher = "천재교육"),
        Book("cj-science-3-1", "과학 3-1", "", 3, "과학", "https://view.chunjae.co.kr/streamdocs/view/sd;streamdocsId=ID_SCIENCE_3_1", publisher = "천재교육"),
        
        Book("cj-math-4-1-p", "수학 4-1 (박만구)", "", 4, "수학", "https://view.chunjae.co.kr/streamdocs/view/sd;streamdocsId=ID_MATH_4_1_P", publisher = "천재교육"),
        Book("cj-social-4-1", "사회 4-1", "", 4, "사회", "https://view.chunjae.co.kr/streamdocs/view/sd;streamdocsId=ID_SOCIAL_4_1", publisher = "천재교육"),
        
        Book("cj-math-5-1", "수학 5-1", "", 5, "수학", "https://view.chunjae.co.kr/streamdocs/view/sd;streamdocsId=ID_MATH_5_1", publisher = "천재교육"),
        Book("cj-social-5-1", "사회 5-1", "", 5, "사회", "https://view.chunjae.co.kr/streamdocs/view/sd;streamdocsId=ID_SOCIAL_5_1", publisher = "천재교육"),
        
        Book("cj-math-6-1", "수학 6-1", "", 6, "수학", "https://view.chunjae.co.kr/streamdocs/view/sd;streamdocsId=ID_MATH_6_1", publisher = "천재교육"),
        Book("cj-social-6-1", "사회 6-1", "", 6, "사회", "https://view.chunjae.co.kr/streamdocs/view/sd;streamdocsId=ID_SOCIAL_6_1", publisher = "천재교육"),
    )

    val all: List<Book> = miraeN + chunjae
}
