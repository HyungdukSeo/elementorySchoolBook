import Foundation

// 모든 출판사 카탈로그를 한 파일에 모아 둠 (Xcode 프로젝트 파일 편집 회피).
// 안드로이드 카탈로그와 동일한 책 목록 — 각 출판사별 enum.

enum BookCatalog {
    static var all: [Book] {
        MiraeN.all + IScream.all + Jihaksa.all
            + Chunjae.all + Visang.all + Donga.all + Ybm.all
    }
}

// MARK: - 미래엔

extension BookCatalog {
    enum MiraeN {
        static let all: [Book] = grade3 + grade4 + grade5 + grade6

        static let grade3: [Book] = [
            Book(id: "math-3-1",     title: "수학 3-1",     linkTitle: "수학3-1",     grade: 3, subject: "수학",    viewPageID: "1"),
            Book(id: "math-3-2",     title: "수학 3-2",     linkTitle: "수학3-2",     grade: 3, subject: "수학",    viewPageID: "1"),
            Book(id: "social-3-1",   title: "사회 3-1",     linkTitle: "사회3-1",     grade: 3, subject: "사회",    viewPageID: "5"),
            Book(id: "social-3-2",   title: "사회 3-2",     linkTitle: "사회3-2",     grade: 3, subject: "사회",    viewPageID: "5"),
            Book(id: "science-3-1",  title: "과학 3-1",     linkTitle: "과학3-1",     grade: 3, subject: "과학",    viewPageID: "9"),
            Book(id: "science-3-2",  title: "과학 3-2",     linkTitle: "과학3-2",     grade: 3, subject: "과학",    viewPageID: "9"),
            Book(id: "english-3",    title: "영어 3",        linkTitle: "영어3",        grade: 3, subject: "영어",    viewPageID: "13"),
            Book(id: "art-3",        title: "미술 3",        linkTitle: "미술3",        grade: 3, subject: "미술",    viewPageID: "15"),
            Book(id: "music-3",      title: "음악 3",        linkTitle: "음악3",        grade: 3, subject: "음악",    viewPageID: "10022"),
            Book(id: "pe-3",         title: "체육 3",        linkTitle: "체육3",        grade: 3, subject: "체육",    viewPageID: "17"),
            Book(id: "math-wb-3-1",  title: "수학익힘 3-1", linkTitle: "수학익힘3-1", grade: 3, subject: "수학익힘", viewPageID: "1",     viewSection: "수학익힘"),
            Book(id: "math-wb-3-2",  title: "수학익힘 3-2", linkTitle: "수학익힘3-2", grade: 3, subject: "수학익힘", viewPageID: "1",     viewSection: "수학익힘"),
            Book(id: "sci-lab-3-1",  title: "실험관찰 3-1", linkTitle: "실험관찰3-1", grade: 3, subject: "실험관찰", viewPageID: "9",     viewSection: "실험관찰"),
            Book(id: "sci-lab-3-2",  title: "실험관찰 3-2", linkTitle: "실험관찰3-2", grade: 3, subject: "실험관찰", viewPageID: "9",     viewSection: "실험관찰"),
        ]

        static let grade4: [Book] = [
            Book(id: "math-4-1",     title: "수학 4-1",     linkTitle: "수학4-1",     grade: 4, subject: "수학",    viewPageID: "1"),
            Book(id: "math-4-2",     title: "수학 4-2",     linkTitle: "수학4-2",     grade: 4, subject: "수학",    viewPageID: "1"),
            Book(id: "social-4-1",   title: "사회 4-1",     linkTitle: "사회4-1",     grade: 4, subject: "사회",    viewPageID: "5"),
            Book(id: "social-4-2",   title: "사회 4-2",     linkTitle: "사회4-2",     grade: 4, subject: "사회",    viewPageID: "5"),
            Book(id: "science-4-1",  title: "과학 4-1",     linkTitle: "과학4-1",     grade: 4, subject: "과학",    viewPageID: "9"),
            Book(id: "science-4-2",  title: "과학 4-2",     linkTitle: "과학4-2",     grade: 4, subject: "과학",    viewPageID: "9"),
            Book(id: "english-4",    title: "영어 4",        linkTitle: "영어4",        grade: 4, subject: "영어",    viewPageID: "14"),
            Book(id: "art-4",        title: "미술 4",        linkTitle: "미술4",        grade: 4, subject: "미술",    viewPageID: "15"),
            Book(id: "music-4",      title: "음악 4",        linkTitle: "음악4",        grade: 4, subject: "음악",    viewPageID: "10022"),
            Book(id: "pe-4",         title: "체육 4",        linkTitle: "체육4",        grade: 4, subject: "체육",    viewPageID: "17"),
            Book(id: "math-wb-4-1",  title: "수학익힘 4-1", linkTitle: "수학익힘4-1", grade: 4, subject: "수학익힘", viewPageID: "1",     viewSection: "수학익힘"),
            Book(id: "math-wb-4-2",  title: "수학익힘 4-2", linkTitle: "수학익힘4-2", grade: 4, subject: "수학익힘", viewPageID: "1",     viewSection: "수학익힘"),
            Book(id: "sci-lab-4-1",  title: "실험관찰 4-1", linkTitle: "실험관찰4-1", grade: 4, subject: "실험관찰", viewPageID: "9",     viewSection: "실험관찰"),
            Book(id: "sci-lab-4-2",  title: "실험관찰 4-2", linkTitle: "실험관찰4-2", grade: 4, subject: "실험관찰", viewPageID: "9",     viewSection: "실험관찰"),
        ]

        static let grade5: [Book] = [
            Book(id: "math-5-1",     title: "수학 5-1",     linkTitle: "수학5-1",      grade: 5, subject: "수학",    viewPageID: "10004"),
            Book(id: "math-5-2",     title: "수학 5-2",     linkTitle: "수학5-2",      grade: 5, subject: "수학",    viewPageID: "10004"),
            Book(id: "social-5-1",   title: "사회 5-1",     linkTitle: "사회5-1",      grade: 5, subject: "사회",    viewPageID: "10008"),
            Book(id: "social-5-2",   title: "사회 5-2",     linkTitle: "사회5-2",      grade: 5, subject: "사회",    viewPageID: "10008"),
            Book(id: "science-5-1",  title: "과학 5-1",     linkTitle: "과학5-1",      grade: 5, subject: "과학",    viewPageID: "10012"),
            Book(id: "science-5-2",  title: "과학 5-2",     linkTitle: "과학5-2",      grade: 5, subject: "과학",    viewPageID: "10012"),
            Book(id: "english-5",    title: "영어 5",        linkTitle: "영어5",         grade: 5, subject: "영어",    viewPageID: "10016"),
            Book(id: "art-5",        title: "미술 5",        linkTitle: "미술5",         grade: 5, subject: "미술",    viewPageID: "10018"),
            Book(id: "music-5",      title: "음악 5",        linkTitle: "음악5",         grade: 5, subject: "음악",    viewPageID: "10022"),
            Book(id: "pe-5",         title: "체육 5",        linkTitle: "체육5",         grade: 5, subject: "체육",    viewPageID: "10020"),
            Book(id: "practical-5",  title: "실과 5",        linkTitle: "실과5",         grade: 5, subject: "실과",    viewPageID: "10026"),
            Book(id: "math-wb-5-1",  title: "수학익힘 5-1", linkTitle: "수학익힘 5-1", grade: 5, subject: "수학익힘", viewPageID: "10004", viewSection: "수학익힘"),
            Book(id: "math-wb-5-2",  title: "수학익힘 5-2", linkTitle: "수학익힘 5-2", grade: 5, subject: "수학익힘", viewPageID: "10004", viewSection: "수학익힘"),
            Book(id: "sci-lab-5-1",  title: "실험관찰 5-1", linkTitle: "실험관찰 5-1", grade: 5, subject: "실험관찰", viewPageID: "10012", viewSection: "실험관찰"),
            Book(id: "sci-lab-5-2",  title: "실험관찰 5-2", linkTitle: "실험관찰 5-2", grade: 5, subject: "실험관찰", viewPageID: "10012", viewSection: "실험관찰"),
        ]

        static let grade6: [Book] = [
            Book(id: "math-6-1",     title: "수학 6-1",     linkTitle: "수학6-1",      grade: 6, subject: "수학",    viewPageID: "10004"),
            Book(id: "math-6-2",     title: "수학 6-2",     linkTitle: "수학6-2",      grade: 6, subject: "수학",    viewPageID: "10004"),
            Book(id: "social-6-1",   title: "사회 6-1",     linkTitle: "사회6-1",      grade: 6, subject: "사회",    viewPageID: "10008"),
            Book(id: "social-6-2",   title: "사회 6-2",     linkTitle: "사회6-2",      grade: 6, subject: "사회",    viewPageID: "10008"),
            Book(id: "science-6-1",  title: "과학 6-1",     linkTitle: "과학6-1",      grade: 6, subject: "과학",    viewPageID: "10012"),
            Book(id: "science-6-2",  title: "과학 6-2",     linkTitle: "과학6-2",      grade: 6, subject: "과학",    viewPageID: "10012"),
            Book(id: "english-6",    title: "영어 6",        linkTitle: "영어6",         grade: 6, subject: "영어",    viewPageID: "10017"),
            Book(id: "art-6",        title: "미술 6",        linkTitle: "미술6",         grade: 6, subject: "미술",    viewPageID: "10018"),
            Book(id: "music-6",      title: "음악 6",        linkTitle: "음악6",         grade: 6, subject: "음악",    viewPageID: "10022"),
            Book(id: "pe-6",         title: "체육 6",        linkTitle: "체육6",         grade: 6, subject: "체육",    viewPageID: "10020"),
            Book(id: "practical-6",  title: "실과 6",        linkTitle: "실과6",         grade: 6, subject: "실과",    viewPageID: "10026"),
            Book(id: "math-wb-6-1",  title: "수학익힘 6-1", linkTitle: "수학익힘 6-1", grade: 6, subject: "수학익힘", viewPageID: "10004", viewSection: "수학익힘"),
            Book(id: "math-wb-6-2",  title: "수학익힘 6-2", linkTitle: "수학익힘 6-2", grade: 6, subject: "수학익힘", viewPageID: "10004", viewSection: "수학익힘"),
            Book(id: "sci-lab-6-1",  title: "실험관찰 6-1", linkTitle: "실험관찰 6-1", grade: 6, subject: "실험관찰", viewPageID: "10012", viewSection: "실험관찰"),
            Book(id: "sci-lab-6-2",  title: "실험관찰 6-2", linkTitle: "실험관찰 6-2", grade: 6, subject: "실험관찰", viewPageID: "10012", viewSection: "실험관찰"),
        ]
    }
}

// MARK: - 아이스크림미디어 (직접 URL)

extension BookCatalog {
    enum IScream {
        private static let base = "https://download.i-scream.co.kr/textbook/introduce"
        private static func ic(_ id: String, _ title: String, _ grade: Int, _ subject: String, _ fileName: String, _ section: String = "교과서") -> Book {
            Book(id: id, title: title, grade: grade, subject: subject,
                 viewPageID: "\(base)/\(fileName).pdf",
                 viewSection: section, publisher: .iscream)
        }

        static let all: [Book] =
            math + mathWb + science + sciLab + social + english + music + art + pe + practical

        private static let math: [Book] = [
            ic("ic-math-3-1", "수학 3-1 (김성여)", 3, "수학", "math_3-1_2022"),
            ic("ic-math-3-2", "수학 3-2 (김성여)", 3, "수학", "math_3-2_2022"),
            ic("ic-math-4-1", "수학 4-1 (김성여)", 4, "수학", "math_4-1_2022"),
            ic("ic-math-4-2", "수학 4-2 (김성여)", 4, "수학", "math_4-2_2022"),
            ic("ic-math-5-1", "수학 5-1 (김성여)", 5, "수학", "math_5-1_2022"),
            ic("ic-math-5-2", "수학 5-2 (김성여)", 5, "수학", "math_5-2_2022"),
            ic("ic-math-6-1", "수학 6-1 (김성여)", 6, "수학", "math_6-1_2022"),
            ic("ic-math-6-2", "수학 6-2 (김성여)", 6, "수학", "math_6-2_2022"),
        ]
        private static let mathWb: [Book] = [
            ic("ic-mathwb-3-1", "수학익힘 3-1 (김성여)", 3, "수학익힘", "math_ikhim_3-1_2022", "수학익힘"),
            ic("ic-mathwb-3-2", "수학익힘 3-2 (김성여)", 3, "수학익힘", "math_ikhim_3-2_2022", "수학익힘"),
            ic("ic-mathwb-4-1", "수학익힘 4-1 (김성여)", 4, "수학익힘", "math_ikhim_4-1_2022", "수학익힘"),
            ic("ic-mathwb-4-2", "수학익힘 4-2 (김성여)", 4, "수학익힘", "math_ikhim_4-2_2022", "수학익힘"),
            ic("ic-mathwb-5-1", "수학익힘 5-1 (김성여)", 5, "수학익힘", "math_ikhim_5-1_2022", "수학익힘"),
            ic("ic-mathwb-5-2", "수학익힘 5-2 (김성여)", 5, "수학익힘", "math_ikhim_5-2_2022", "수학익힘"),
            ic("ic-mathwb-6-1", "수학익힘 6-1 (김성여)", 6, "수학익힘", "math_ikhim_6-1_2022", "수학익힘"),
            ic("ic-mathwb-6-2", "수학익힘 6-2 (김성여)", 6, "수학익힘", "math_ikhim_6-2_2022", "수학익힘"),
        ]
        private static let science: [Book] = [
            ic("ic-sci-3-1", "과학 3-1 (박일우)", 3, "과학", "science_3-1_2022"),
            ic("ic-sci-3-2", "과학 3-2 (박일우)", 3, "과학", "science_3-2_2022"),
            ic("ic-sci-4-1", "과학 4-1 (박일우)", 4, "과학", "science_4-1_2022"),
            ic("ic-sci-4-2", "과학 4-2 (박일우)", 4, "과학", "science_4-2_2022"),
            ic("ic-sci-5-1", "과학 5-1 (박일우)", 5, "과학", "science_5-1_2022"),
            ic("ic-sci-5-2", "과학 5-2 (박일우)", 5, "과학", "science_5-2_2022"),
            ic("ic-sci-6-1", "과학 6-1 (박일우)", 6, "과학", "science_6-1_2022"),
            ic("ic-sci-6-2", "과학 6-2 (박일우)", 6, "과학", "science_6-2_2022"),
        ]
        private static let sciLab: [Book] = [
            ic("ic-lab-3-1", "실험관찰 3-1 (박일우)", 3, "실험관찰", "science_silhum_3-1_2022", "실험관찰"),
            ic("ic-lab-3-2", "실험관찰 3-2 (박일우)", 3, "실험관찰", "science_silhum_3-2_2022", "실험관찰"),
            ic("ic-lab-4-1", "실험관찰 4-1 (박일우)", 4, "실험관찰", "science_silhum_4-1_2022", "실험관찰"),
            ic("ic-lab-4-2", "실험관찰 4-2 (박일우)", 4, "실험관찰", "science_silhum_4-2_2022", "실험관찰"),
            ic("ic-lab-5-1", "실험관찰 5-1 (박일우)", 5, "실험관찰", "science_silhum_5-1_2022", "실험관찰"),
            ic("ic-lab-5-2", "실험관찰 5-2 (박일우)", 5, "실험관찰", "science_silhum_5-2_2022", "실험관찰"),
            ic("ic-lab-6-1", "실험관찰 6-1 (박일우)", 6, "실험관찰", "science_silhum_6-1_2022", "실험관찰"),
            ic("ic-lab-6-2", "실험관찰 6-2 (박일우)", 6, "실험관찰", "science_silhum_6-2_2022", "실험관찰"),
        ]
        private static let social: [Book] = [
            ic("ic-social-3-1", "사회 3-1 (한춘희)", 3, "사회", "society_3-1_2022"),
            ic("ic-social-3-2", "사회 3-2 (한춘희)", 3, "사회", "society_3-2_2022"),
            ic("ic-social-4-1", "사회 4-1 (한춘희)", 4, "사회", "society_4-1_2022"),
            ic("ic-social-4-2", "사회 4-2 (한춘희)", 4, "사회", "society_4-2_2022"),
            ic("ic-social-5-1", "사회 5-1 (한춘희)", 5, "사회", "society_5-1_2022"),
            ic("ic-social-5-2", "사회 5-2 (한춘희)", 5, "사회", "society_5-2_2022"),
            ic("ic-social-6-1", "사회 6-1 (한춘희)", 6, "사회", "society_6-1_2022"),
            ic("ic-social-6-2", "사회 6-2 (한춘희)", 6, "사회", "society_6-2_2022"),
        ]
        private static let english: [Book] = [
            ic("ic-eng-3", "영어 3 (박유미)", 3, "영어", "english_3_2022"),
            ic("ic-eng-4", "영어 4 (박유미)", 4, "영어", "english_4_2022"),
            ic("ic-eng-5", "영어 5 (박유미)", 5, "영어", "english_5_2022"),
            ic("ic-eng-6", "영어 6 (박유미)", 6, "영어", "english_6_2022"),
        ]
        private static let music: [Book] = [
            ic("ic-music-3", "음악 3 (조순이)", 3, "음악", "music_3_2022"),
            ic("ic-music-4", "음악 4 (조순이)", 4, "음악", "music_4_2022"),
            ic("ic-music-5", "음악 5 (조순이)", 5, "음악", "music_5_2022"),
            ic("ic-music-6", "음악 6 (조순이)", 6, "음악", "music_6_2022"),
        ]
        private static let art: [Book] = [
            ic("ic-art-3", "미술 3 (손지현)", 3, "미술", "art_3_2022"),
            ic("ic-art-4", "미술 4 (손지현)", 4, "미술", "art_4_2022"),
            ic("ic-art-5", "미술 5 (손지현)", 5, "미술", "art_5_2022"),
            ic("ic-art-6", "미술 6 (손지현)", 6, "미술", "art_6_2022"),
        ]
        private static let pe: [Book] = [
            ic("ic-pe-3", "체육 3 (김명숙)", 3, "체육", "physicaledu_3_2022"),
            ic("ic-pe-4", "체육 4 (김명숙)", 4, "체육", "physicaledu_4_2022"),
            ic("ic-pe-5", "체육 5 (김명숙)", 5, "체육", "physicaledu_5_2022"),
            ic("ic-pe-6", "체육 6 (김명숙)", 6, "체육", "physicaledu_6_2022"),
        ]
        private static let practical: [Book] = [
            ic("ic-practical-5", "실과 5 (정영식)", 5, "실과", "practice_5_2022"),
            ic("ic-practical-6", "실과 6 (정영식)", 6, "실과", "practice_6_2022"),
        ]
    }
}

// MARK: - 지학사 (직접 URL, 3~4학년만)

extension BookCatalog {
    enum Jihaksa {
        private static let base = "https://s3.ap-northeast-2.amazonaws.com/tsol.jihak.co.kr/tsol/22tp/e"
        private static func jh(_ id: String, _ title: String, _ grade: Int, _ subject: String, _ url: String, _ section: String = "교과서") -> Book {
            Book(id: id, title: title, grade: grade, subject: subject,
                 viewPageID: url, viewSection: section, publisher: .jihaksa)
        }

        static let all: [Book] = math + mathWb + social + science + sciLab + music + art + pe

        private static let math: [Book] = [
            jh("jh-math-3-1", "수학 3-1", 3, "수학", "\(base)/mat/JIHAKSA_%EC%88%98%ED%95%99_%EC%B4%88_3-1_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
            jh("jh-math-3-2", "수학 3-2", 3, "수학", "\(base)/mat/JIHAKSA_%EC%88%98%ED%95%99_%EC%B4%88_3-2_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
            jh("jh-math-4-1", "수학 4-1", 4, "수학", "\(base)/mat/JIHAKSA_%EC%88%98%ED%95%99_%EC%B4%88_4-1_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
            jh("jh-math-4-2", "수학 4-2", 4, "수학", "\(base)/mat/JIHAKSA_%EC%88%98%ED%95%99_%EC%B4%88_4-2_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
        ]
        private static let mathWb: [Book] = [
            jh("jh-mathwb-3-1", "수학익힘 3-1", 3, "수학익힘", "\(base)/mat/JIHAKSA_%EC%88%98%ED%95%99%EC%9D%B5%ED%9E%98_%EC%B4%88_3-1_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf", "수학익힘"),
            jh("jh-mathwb-3-2", "수학익힘 3-2", 3, "수학익힘", "\(base)/mat/JIHAKSA_%EC%88%98%ED%95%99%EC%9D%B5%ED%9E%98_%EC%B4%88_3-2_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf", "수학익힘"),
            jh("jh-mathwb-4-1", "수학익힘 4-1", 4, "수학익힘", "\(base)/mat/JIHAKSA_%EC%88%98%ED%95%99%EC%9D%B5%ED%9E%98_%EC%B4%88_4-1_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf", "수학익힘"),
            jh("jh-mathwb-4-2", "수학익힘 4-2", 4, "수학익힘", "\(base)/mat/JIHAKSA_%EC%88%98%ED%95%99%EC%9D%B5%ED%9E%98_%EC%B4%88_4-2_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf", "수학익힘"),
        ]
        private static let social: [Book] = [
            jh("jh-social-3-1", "사회 3-1", 3, "사회", "\(base)/soc/JIHAKSA_%EC%82%AC%ED%9A%8C_%EC%B4%88_3-1_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
            jh("jh-social-3-2", "사회 3-2", 3, "사회", "\(base)/soc/JIHAKSA_%EC%82%AC%ED%9A%8C_%EC%B4%88_3-2_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
            jh("jh-social-4-1", "사회 4-1", 4, "사회", "\(base)/soc/JIHAKSA_%EC%82%AC%ED%9A%8C_%EC%B4%88_4-1_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
        ]
        private static let science: [Book] = [
            jh("jh-sci-3-1", "과학 3-1", 3, "과학", "\(base)/sci/JIHAKSA_%EA%B3%BC%ED%95%99_%EC%B4%88_3-1_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
            jh("jh-sci-3-2", "과학 3-2", 3, "과학", "\(base)/sci/JIHAKSA_%EA%B3%BC%ED%95%99_%EC%B4%88_3-2_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
            jh("jh-sci-4-1", "과학 4-1", 4, "과학", "\(base)/sci/JIHAKSA_%EA%B3%BC%ED%95%99_%EC%B4%88_4-1_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
            jh("jh-sci-4-2", "과학 4-2", 4, "과학", "\(base)/sci/JIHAKSA_%EA%B3%BC%ED%95%99_%EC%B4%88_4-2_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
        ]
        private static let sciLab: [Book] = [
            jh("jh-lab-3-1", "실험관찰 3-1", 3, "실험관찰", "\(base)/sci/JIHAKSA_%EA%B3%BC%ED%95%99_%EC%B4%88_3-1_%EC%8B%A4%ED%97%98%EA%B4%80%EC%B0%B0.pdf", "실험관찰"),
            jh("jh-lab-3-2", "실험관찰 3-2", 3, "실험관찰", "\(base)/sci/JIHAKSA_%EA%B3%BC%ED%95%99_%EC%B4%88_3-2_%EC%8B%A4%ED%97%98%EA%B4%80%EC%B0%B0.pdf", "실험관찰"),
            jh("jh-lab-4-1", "실험관찰 4-1", 4, "실험관찰", "\(base)/sci/JIHAKSA_%EA%B3%BC%ED%95%99_%EC%B4%88_4-1_%EC%8B%A4%ED%97%98%EA%B4%80%EC%B0%B0.pdf", "실험관찰"),
            jh("jh-lab-4-2", "실험관찰 4-2", 4, "실험관찰", "\(base)/sci/JIHAKSA_%EA%B3%BC%ED%95%99_%EC%B4%88_4-2_%EC%8B%A4%ED%97%98%EA%B4%80%EC%B0%B0.pdf", "실험관찰"),
        ]
        private static let music: [Book] = [
            jh("jh-music-3", "음악 3", 3, "음악", "\(base)/mus/JIHAKSA_%EC%9D%8C%EC%95%85_%EC%B4%88_3_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
            jh("jh-music-4", "음악 4", 4, "음악", "\(base)/mus/JIHAKSA_%EC%9D%8C%EC%95%85_%EC%B4%88_4_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
        ]
        private static let art: [Book] = [
            jh("jh-art-3", "미술 3", 3, "미술", "\(base)/art/JIHAKSA_%EB%AF%B8%EC%88%A0_%EC%B4%88_3_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
            jh("jh-art-4", "미술 4", 4, "미술", "\(base)/art/JIHAKSA_%EB%AF%B8%EC%88%A0_%EC%B4%88_4_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
        ]
        private static let pe: [Book] = [
            jh("jh-pe-3", "체육 3", 3, "체육", "\(base)/phy/JIHAKSA_%EC%B2%B4%EC%9C%A1_%EC%B4%88_3_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
            jh("jh-pe-4", "체육 4", 4, "체육", "\(base)/phy/JIHAKSA_%EC%B2%B4%EC%9C%A1_%EC%B4%88_4_%EA%B5%90%EA%B3%BC%EC%84%9C.pdf"),
        ]
    }
}

// MARK: - 천재교육 (streamdocs filePath → API 변환)

extension BookCatalog {
    enum Chunjae {
        private static let pathBase = "/00_교과서홍보관_초등/교과서PDF"
        private static func cj(_ id: String, _ title: String, _ grade: Int, _ subject: String, _ path: String, _ section: String = "교과서") -> Book {
            Book(id: id, title: title, grade: grade, subject: subject,
                 viewPageID: path, viewSection: section, publisher: .chunjae)
        }

        static let all: [Book] =
            mathPa + mathPaWb + mathHa + mathHaWb +
            socialKj + socialPa +
            scienceJy + scienceJyLab + scienceLe + scienceLeLab +
            engKt + engLe + engHa +
            music + art + pe + practical

        private static let mathPa: [Book] = [
            cj("cj-math-pa-3-1", "수학 3-1 (박만구)", 3, "수학", "\(pathBase)/02_수학/천재_초등_수학3-1(박만구)_교과서.pdf"),
            cj("cj-math-pa-3-2", "수학 3-2 (박만구)", 3, "수학", "\(pathBase)/02_수학/천재_초등_수학3-2(박만구)_교과서.pdf"),
            cj("cj-math-pa-4-1", "수학 4-1 (박만구)", 4, "수학", "\(pathBase)/02_수학/천재_초등_수학4-1(박만구)_교과서.pdf"),
            cj("cj-math-pa-4-2", "수학 4-2 (박만구)", 4, "수학", "\(pathBase)/02_수학/천재_초등_수학4-2(박만구)_교과서.pdf"),
            cj("cj-math-pa-5-1", "수학 5-1 (박만구)", 5, "수학", "\(pathBase)/02_수학/천재_초등_수학5-1(박만구)_교과서.pdf"),
            cj("cj-math-pa-5-2", "수학 5-2 (박만구)", 5, "수학", "\(pathBase)/02_수학/천재_초등_수학5-2(박만구)_교과서.pdf"),
            cj("cj-math-pa-6-1", "수학 6-1 (박만구)", 6, "수학", "\(pathBase)/02_수학/천재_초등_수학6-1(박만구)_교과서.pdf"),
            cj("cj-math-pa-6-2", "수학 6-2 (박만구)", 6, "수학", "\(pathBase)/02_수학/천재_초등_수학6-2(박만구)_교과서.pdf"),
        ]
        private static let mathPaWb: [Book] = [
            cj("cj-mathwb-pa-3-1", "수학익힘 3-1 (박만구)", 3, "수학익힘", "\(pathBase)/02_수학/천재_초등_수학3-1(박만구)_수학익힘.pdf", "수학익힘"),
            cj("cj-mathwb-pa-3-2", "수학익힘 3-2 (박만구)", 3, "수학익힘", "\(pathBase)/02_수학/천재_초등_수학3-2(박만구)_수학익힘.pdf", "수학익힘"),
            cj("cj-mathwb-pa-4-1", "수학익힘 4-1 (박만구)", 4, "수학익힘", "\(pathBase)/02_수학/천재_초등_수학4-1(박만구)_수학익힘.pdf", "수학익힘"),
            cj("cj-mathwb-pa-4-2", "수학익힘 4-2 (박만구)", 4, "수학익힘", "\(pathBase)/02_수학/천재_초등_수학4-2(박만구)_수학익힘.pdf", "수학익힘"),
            cj("cj-mathwb-pa-5-1", "수학익힘 5-1 (박만구)", 5, "수학익힘", "\(pathBase)/02_수학/천재_초등_수학5-1(박만구)_수학익힘.pdf", "수학익힘"),
            cj("cj-mathwb-pa-5-2", "수학익힘 5-2 (박만구)", 5, "수학익힘", "\(pathBase)/02_수학/천재_초등_수학5-2(박만구)_수학익힘.pdf", "수학익힘"),
            cj("cj-mathwb-pa-6-1", "수학익힘 6-1 (박만구)", 6, "수학익힘", "\(pathBase)/02_수학/천재_초등_수학6-1(박만구)_수학익힘.pdf", "수학익힘"),
            cj("cj-mathwb-pa-6-2", "수학익힘 6-2 (박만구)", 6, "수학익힘", "\(pathBase)/02_수학/천재_초등_수학6-2(박만구)_수학익힘.pdf", "수학익힘"),
        ]
        private static let mathHa: [Book] = [
            cj("cj-math-ha-3-1", "수학 3-1 (한대희)", 3, "수학", "\(pathBase)/02_수학/천재_초등_수학3-1(한대희)_교과서.pdf"),
            cj("cj-math-ha-3-2", "수학 3-2 (한대희)", 3, "수학", "\(pathBase)/02_수학/천재_초등_수학3-2(한대희)_교과서.pdf"),
            cj("cj-math-ha-4-1", "수학 4-1 (한대희)", 4, "수학", "\(pathBase)/02_수학/천재_초등_수학4-1(한대희)_교과서.pdf"),
            cj("cj-math-ha-4-2", "수학 4-2 (한대희)", 4, "수학", "\(pathBase)/02_수학/천재_초등_수학4-2(한대희)_교과서.pdf"),
            cj("cj-math-ha-5-1", "수학 5-1 (한대희)", 5, "수학", "\(pathBase)/02_수학/천재_초등_수학5-1(한대희)_교과서.pdf"),
            cj("cj-math-ha-5-2", "수학 5-2 (한대희)", 5, "수학", "\(pathBase)/02_수학/천재_초등_수학5-2(한대희)_교과서.pdf"),
            cj("cj-math-ha-6-1", "수학 6-1 (한대희)", 6, "수학", "\(pathBase)/02_수학/천재_초등_수학6-1(한대희)_교과서.pdf"),
            cj("cj-math-ha-6-2", "수학 6-2 (한대희)", 6, "수학", "\(pathBase)/02_수학/천재_초등_수학6-2(한대희)_교과서.pdf"),
        ]
        private static let mathHaWb: [Book] = [
            cj("cj-mathwb-ha-3-1", "수학익힘 3-1 (한대희)", 3, "수학익힘", "\(pathBase)/02_수학/천재_초등_수학3-1(한대희)_수학익힘.pdf", "수학익힘"),
            cj("cj-mathwb-ha-3-2", "수학익힘 3-2 (한대희)", 3, "수학익힘", "\(pathBase)/02_수학/천재_초등_수학3-2(한대희)_수학익힘.pdf", "수학익힘"),
            cj("cj-mathwb-ha-4-1", "수학익힘 4-1 (한대희)", 4, "수학익힘", "\(pathBase)/02_수학/천재_초등_수학4-1(한대희)_수학익힘.pdf", "수학익힘"),
            cj("cj-mathwb-ha-4-2", "수학익힘 4-2 (한대희)", 4, "수학익힘", "\(pathBase)/02_수학/천재_초등_수학4-2(한대희)_수학익힘.pdf", "수학익힘"),
            cj("cj-mathwb-ha-5-1", "수학익힘 5-1 (한대희)", 5, "수학익힘", "\(pathBase)/02_수학/천재_초등_수학5-1(한대희)_수학익힘.pdf", "수학익힘"),
            cj("cj-mathwb-ha-5-2", "수학익힘 5-2 (한대희)", 5, "수학익힘", "\(pathBase)/02_수학/천재_초등_수학5-2(한대희)_수학익힘.pdf", "수학익힘"),
            cj("cj-mathwb-ha-6-1", "수학익힘 6-1 (한대희)", 6, "수학익힘", "\(pathBase)/02_수학/천재_초등_수학6-1(한대희)_수학익힘.pdf", "수학익힘"),
            cj("cj-mathwb-ha-6-2", "수학익힘 6-2 (한대희)", 6, "수학익힘", "\(pathBase)/02_수학/천재_초등_수학6-2(한대희)_수학익힘.pdf", "수학익힘"),
        ]
        private static let socialKj: [Book] = [
            cj("cj-social-kj-3-1", "사회 3-1 (김정인)", 3, "사회", "\(pathBase)/03_사회/천재_초등_사회3-1(김정인)_교과서.pdf"),
            cj("cj-social-kj-3-2", "사회 3-2 (김정인)", 3, "사회", "\(pathBase)/03_사회/천재_초등_사회3-2(김정인)_교과서.pdf"),
            cj("cj-social-kj-4-1", "사회 4-1 (김정인)", 4, "사회", "\(pathBase)/03_사회/천재_초등_사회4-1(김정인)_교과서.pdf"),
            cj("cj-social-kj-4-2", "사회 4-2 (김정인)", 4, "사회", "\(pathBase)/03_사회/천재_초등_사회4-2(김정인)_교과서.pdf"),
            cj("cj-social-kj-5-1", "사회 5-1 (김정인)", 5, "사회", "\(pathBase)/03_사회/천재_초등_사회5-1(김정인)_교과서.pdf"),
            cj("cj-social-kj-5-2", "사회 5-2 (김정인)", 5, "사회", "\(pathBase)/03_사회/천재_초등_사회5-2(김정인)_교과서.pdf"),
            cj("cj-social-kj-6-1", "사회 6-1 (김정인)", 6, "사회", "\(pathBase)/03_사회/천재_초등_사회6-1(김정인)_교과서.pdf"),
            cj("cj-social-kj-6-2", "사회 6-2 (김정인)", 6, "사회", "\(pathBase)/03_사회/천재_초등_사회6-2(김정인)_교과서.pdf"),
        ]
        private static let socialPa: [Book] = [
            cj("cj-social-pa-5-1", "사회 5-1 (박기범)", 5, "사회", "\(pathBase)/03_사회/천재_초등_사회5-1(박기범)_교과서.pdf"),
            cj("cj-social-pa-5-2", "사회 5-2 (박기범)", 5, "사회", "\(pathBase)/03_사회/천재_초등_사회5-2(박기범)_교과서.pdf"),
            cj("cj-social-pa-6-1", "사회 6-1 (박기범)", 6, "사회", "\(pathBase)/03_사회/천재_초등_사회6-1(박기범)_교과서.pdf"),
            cj("cj-social-pa-6-2", "사회 6-2 (박기범)", 6, "사회", "\(pathBase)/03_사회/천재_초등_사회6-2(박기범)_교과서.pdf"),
        ]
        private static let scienceJy: [Book] = [
            cj("cj-sci-jy-3-1", "과학 3-1 (정용재)", 3, "과학", "\(pathBase)/04_과학/천재_초등_과학3-1(정용재)_교과서.pdf"),
            cj("cj-sci-jy-3-2", "과학 3-2 (정용재)", 3, "과학", "\(pathBase)/04_과학/천재_초등_과학3-2(정용재)_교과서.pdf"),
            cj("cj-sci-jy-4-1", "과학 4-1 (정용재)", 4, "과학", "\(pathBase)/04_과학/천재_초등_과학4-1(정용재)_교과서.pdf"),
            cj("cj-sci-jy-4-2", "과학 4-2 (정용재)", 4, "과학", "\(pathBase)/04_과학/천재_초등_과학4-2(정용재)_교과서.pdf"),
            cj("cj-sci-jy-5-1", "과학 5-1 (정용재)", 5, "과학", "\(pathBase)/04_과학/천재_초등_과학5-1(정용재)_교과서.pdf"),
            cj("cj-sci-jy-5-2", "과학 5-2 (정용재)", 5, "과학", "\(pathBase)/04_과학/천재_초등_과학5-2(정용재)_교과서.pdf"),
            cj("cj-sci-jy-6-1", "과학 6-1 (정용재)", 6, "과학", "\(pathBase)/04_과학/천재_초등_과학6-1(정용재)_교과서.pdf"),
            cj("cj-sci-jy-6-2", "과학 6-2 (정용재)", 6, "과학", "\(pathBase)/04_과학/천재_초등_과학6-2(정용재)_교과서.pdf"),
        ]
        private static let scienceJyLab: [Book] = [
            cj("cj-lab-jy-3-1", "실험관찰 3-1 (정용재)", 3, "실험관찰", "\(pathBase)/04_과학/천재_초등_과학3-1(정용재)_실험관찰.pdf", "실험관찰"),
            cj("cj-lab-jy-3-2", "실험관찰 3-2 (정용재)", 3, "실험관찰", "\(pathBase)/04_과학/천재_초등_과학3-2(정용재)_실험관찰.pdf", "실험관찰"),
            cj("cj-lab-jy-4-1", "실험관찰 4-1 (정용재)", 4, "실험관찰", "\(pathBase)/04_과학/천재_초등_과학4-1(정용재)_실험관찰.pdf", "실험관찰"),
            cj("cj-lab-jy-4-2", "실험관찰 4-2 (정용재)", 4, "실험관찰", "\(pathBase)/04_과학/천재_초등_과학4-2(정용재)_실험관찰.pdf", "실험관찰"),
            cj("cj-lab-jy-5-1", "실험관찰 5-1 (정용재)", 5, "실험관찰", "\(pathBase)/04_과학/천재_초등_과학5-1(정용재)_실험관찰.pdf", "실험관찰"),
            cj("cj-lab-jy-5-2", "실험관찰 5-2 (정용재)", 5, "실험관찰", "\(pathBase)/04_과학/천재_초등_과학5-2(정용재)_실험관찰.pdf", "실험관찰"),
            cj("cj-lab-jy-6-1", "실험관찰 6-1 (정용재)", 6, "실험관찰", "\(pathBase)/04_과학/천재_초등_과학6-1(정용재)_실험관찰.pdf", "실험관찰"),
            cj("cj-lab-jy-6-2", "실험관찰 6-2 (정용재)", 6, "실험관찰", "\(pathBase)/04_과학/천재_초등_과학6-2(정용재)_실험관찰.pdf", "실험관찰"),
        ]
        private static let scienceLe: [Book] = [
            cj("cj-sci-le-3-1", "과학 3-1 (이상원)", 3, "과학", "\(pathBase)/04_과학/천재_초등_과학3-1(이상원)_교과서.pdf"),
            cj("cj-sci-le-3-2", "과학 3-2 (이상원)", 3, "과학", "\(pathBase)/04_과학/천재_초등_과학3-2(이상원)_교과서.pdf"),
            cj("cj-sci-le-4-1", "과학 4-1 (이상원)", 4, "과학", "\(pathBase)/04_과학/천재_초등_과학4-1(이상원)_교과서.pdf"),
            cj("cj-sci-le-4-2", "과학 4-2 (이상원)", 4, "과학", "\(pathBase)/04_과학/천재_초등_과학4-2(이상원)_교과서.pdf"),
        ]
        private static let scienceLeLab: [Book] = [
            cj("cj-lab-le-3-1", "실험관찰 3-1 (이상원)", 3, "실험관찰", "\(pathBase)/04_과학/천재_초등_과학3-1(이상원)_실험관찰.pdf", "실험관찰"),
            cj("cj-lab-le-3-2", "실험관찰 3-2 (이상원)", 3, "실험관찰", "\(pathBase)/04_과학/천재_초등_과학3-2(이상원)_실험관찰.pdf", "실험관찰"),
            cj("cj-lab-le-4-2", "실험관찰 4-2 (이상원)", 4, "실험관찰", "\(pathBase)/04_과학/천재_초등_과학4-2(이상원)_실험관찰.pdf", "실험관찰"),
        ]
        private static let engKt: [Book] = [
            cj("cj-eng-kt-3", "영어 3 (김태은)", 3, "영어", "\(pathBase)/01_영어/천재_초등_영어3(김태은)_교과서.pdf"),
            cj("cj-eng-kt-4", "영어 4 (김태은)", 4, "영어", "\(pathBase)/01_영어/천재_초등_영어4(김태은)_교과서.pdf"),
            cj("cj-eng-kt-6", "영어 6 (김태은)", 6, "영어", "\(pathBase)/01_영어/천재_초등_영어6(김태은)_교과서.pdf"),
        ]
        private static let engLe: [Book] = [
            cj("cj-eng-le-3", "영어 3 (이동환)", 3, "영어", "\(pathBase)/01_영어/천재_초등_영어3(이동환)_교과서.pdf"),
            cj("cj-eng-le-4", "영어 4 (이동환)", 4, "영어", "\(pathBase)/01_영어/천재_초등_영어4(이동환)_교과서.pdf"),
            cj("cj-eng-le-5", "영어 5 (이동환)", 5, "영어", "\(pathBase)/01_영어/천재_초등_영어5(이동환)_교과서.pdf"),
            cj("cj-eng-le-6", "영어 6 (이동환)", 6, "영어", "\(pathBase)/01_영어/천재_초등_영어6(이동환)_교과서.pdf"),
        ]
        private static let engHa: [Book] = [
            cj("cj-eng-ha-3", "영어 3 (함순애)", 3, "영어", "\(pathBase)/01_영어/천재_초등_영어3(함순애)_교과서.pdf"),
            cj("cj-eng-ha-4", "영어 4 (함순애)", 4, "영어", "\(pathBase)/01_영어/천재_초등_영어4(함순애)_교과서.pdf"),
            cj("cj-eng-ha-5", "영어 5 (함순애)", 5, "영어", "\(pathBase)/01_영어/천재_초등_영어5(함순애)_교과서.pdf"),
            cj("cj-eng-ha-6", "영어 6 (함순애)", 6, "영어", "\(pathBase)/01_영어/천재_초등_영어6(함순애)_교과서.pdf"),
        ]
        private static let music: [Book] = [
            cj("cj-music-3", "음악 3 (최은아)", 3, "음악", "\(pathBase)/05_음악/천재_초등_음악3(최은아)_교과서.pdf"),
            cj("cj-music-4", "음악 4 (최은아)", 4, "음악", "\(pathBase)/05_음악/천재_초등_음악4(최은아)_교과서.pdf"),
            cj("cj-music-5", "음악 5 (최은아)", 5, "음악", "\(pathBase)/05_음악/천재_초등_음악5(최은아)_교과서.pdf"),
            cj("cj-music-6", "음악 6 (최은아)", 6, "음악", "\(pathBase)/05_음악/천재_초등_음악6(최은아)_교과서.pdf"),
        ]
        private static let art: [Book] = [
            cj("cj-art-3", "미술 3 (안금희)", 3, "미술", "\(pathBase)/06_미술/천재_초등_미술3(안금희)_교과서.pdf"),
            cj("cj-art-4", "미술 4 (안금희)", 4, "미술", "\(pathBase)/06_미술/천재_초등_미술4(안금희)_교과서.pdf"),
            cj("cj-art-5", "미술 5 (안금희)", 5, "미술", "\(pathBase)/06_미술/천재_초등_미술5(안금희)_교과서.pdf"),
            cj("cj-art-6", "미술 6 (안금희)", 6, "미술", "\(pathBase)/06_미술/천재_초등_미술6(안금희)_교과서.pdf"),
        ]
        private static let pe: [Book] = [
            cj("cj-pe-3", "체육 3 (고문수)", 3, "체육", "\(pathBase)/07_체육/천재_초등_체육3(고문수)_교과서.pdf"),
            cj("cj-pe-4", "체육 4 (고문수)", 4, "체육", "\(pathBase)/07_체육/천재_초등_체육4(고문수)_교과서.pdf"),
            cj("cj-pe-5", "체육 5 (고문수)", 5, "체육", "\(pathBase)/07_체육/천재_초등_체육5(고문수)_교과서.pdf"),
            cj("cj-pe-6", "체육 6 (고문수)", 6, "체육", "\(pathBase)/07_체육/천재_초등_체육6(고문수)_교과서.pdf"),
        ]
        private static let practical: [Book] = [
            cj("cj-practical-5", "실과 5 (이춘식)", 5, "실과", "\(pathBase)/08_실과/천재_초등_실과5(이춘식)_교과서.pdf"),
            cj("cj-practical-6", "실과 6 (이춘식)", 6, "실과", "\(pathBase)/08_실과/천재_초등_실과6(이춘식)_교과서.pdf"),
        ]
    }
}

// MARK: - YBM (REST API → contentId → PDF URL)

extension BookCatalog {
    enum Ybm {
        // contentId 직접 지정: viewPageID 가 C 로 시작
        // 선택자 방식: "bookCode|semester|materialTitle" 형식
        private static func y(_ id: String, _ title: String, _ grade: Int, _ subject: String, _ contentId: String, _ section: String = "교과서") -> Book {
            Book(id: id, title: title, grade: grade, subject: subject,
                 viewPageID: contentId, viewSection: section, publisher: .ybm)
        }
        private static func yp(_ id: String, _ title: String, _ grade: Int, _ subject: String, _ bookCode: String, _ semester: String, _ material: String = "교과서", _ section: String = "교과서") -> Book {
            y(id, title, grade, subject, "\(bookCode)|\(semester)|\(material)", section)
        }

        static let all: [Book] = engKim + engChoi + math + social + music + pe + health + practical

        private static let engKim: [Book] = [
            y("ybm-engK-3", "영어 3 (김혜리)", 3, "영어", "C20240816120059rPrQi"),
            y("ybm-engK-4", "영어 4 (김혜리)", 4, "영어", "C20240816120135GIwrj"),
            y("ybm-engK-5", "영어 5 (김혜리)", 5, "영어", "C20250807032906aheKd"),
            y("ybm-engK-6", "영어 6 (김혜리)", 6, "영어", "C202508070329066tlhB"),
        ]
        private static let engChoi: [Book] = [
            y("ybm-engC-3", "영어 3 (최희경)", 3, "영어", "C20240816121740R1Ekt"),
            y("ybm-engC-4", "영어 4 (최희경)", 4, "영어", "C20240816121804wj9fM"),
            y("ybm-engC-5", "영어 5 (최희경)", 5, "영어", "C202508070329062f4mo"),
            y("ybm-engC-6", "영어 6 (최희경)", 6, "영어", "C20250807032906ZC9fM"),
        ]
        private static let math: [Book] = [
            yp("ybm-math-3-1", "수학 3-1 (류희찬)", 3, "수학", "book03", "3학년 1학기"),
            yp("ybm-math-3-2", "수학 3-2 (류희찬)", 3, "수학", "book03", "3학년 2학기"),
            yp("ybm-math-4-1", "수학 4-1 (류희찬)", 4, "수학", "book03", "4학년 1학기"),
            yp("ybm-math-4-2", "수학 4-2 (류희찬)", 4, "수학", "book03", "4학년 2학기"),
            yp("ybm-math-5-1", "수학 5-1 (류희찬)", 5, "수학", "book13", "5학년 1학기"),
            yp("ybm-math-5-2", "수학 5-2 (류희찬)", 5, "수학", "book13", "5학년 2학기"),
            yp("ybm-math-6-1", "수학 6-1 (류희찬)", 6, "수학", "book13", "6학년 1학기"),
            yp("ybm-math-6-2", "수학 6-2 (류희찬)", 6, "수학", "book13", "6학년 2학기"),
        ]
        private static let social: [Book] = [
            y("ybm-social-3-1", "사회 3-1 (남상준)", 3, "사회", "C20240902045856wp31r"),
            y("ybm-social-3-2", "사회 3-2 (남상준)", 3, "사회", "C20240816015542gknll"),
            y("ybm-social-4-1", "사회 4-1 (남상준)", 4, "사회", "C202408160156093zUWr"),
            y("ybm-social-4-2", "사회 4-2 (남상준)", 4, "사회", "C20240816015639uHIWr"),
            y("ybm-social-5-1", "사회 5-1 (남상준)", 5, "사회", "C202508070329030jaH0"),
            y("ybm-social-5-2", "사회 5-2 (남상준)", 5, "사회", "C20250807032904RCP5C"),
            y("ybm-social-6-1", "사회 6-1 (남상준)", 6, "사회", "C20250807032904iUgi9"),
            y("ybm-social-6-2", "사회 6-2 (남상준)", 6, "사회", "C20250807032904zKLBD"),
        ]
        private static let music: [Book] = [
            y("ybm-music-3", "음악 3 (양소영)", 3, "음악", "C20240816021257k42bR"),
            y("ybm-music-4", "음악 4 (양소영)", 4, "음악", "C20240816021909GRGRI"),
            y("ybm-music-5", "음악 5 (양소영)", 5, "음악", "C20250807032906VQt38"),
            y("ybm-music-6", "음악 6 (양소영)", 6, "음악", "C20250807032906w7eZR"),
        ]
        private static let pe: [Book] = [
            y("ybm-pe-3", "체육 3 (이기청)", 3, "체육", "C20240816023640zAPQb"),
            y("ybm-pe-4", "체육 4 (이기청)", 4, "체육", "C20240816023757mZPB0"),
            y("ybm-pe-5", "체육 5 (이기청)", 5, "체육", "C20250807032907Nwz2H"),
            y("ybm-pe-6", "체육 6 (이기청)", 6, "체육", "C20250807032907WlLiT"),
        ]
        private static let health: [Book] = [
            y("ybm-health-5", "보건 5 (우옥영)", 5, "보건", "C20250807032904uOjVd"),
            y("ybm-health-6", "보건 6 (우옥영)", 6, "보건", "C20250807032904JBBDE"),
        ]
        private static let practical: [Book] = [
            y("ybm-practical-5", "실과 5 (이상원)", 5, "실과", "C20250807032905LHJ0N"),
            y("ybm-practical-6", "실과 6 (이상원)", 6, "실과", "C2025080703290591FwH"),
        ]
    }
}

// MARK: - 비상교육 (iBook ID → config.js → 페이지별 PDF 병합)

extension BookCatalog {
    enum Visang {
        private static func vs(_ id: String, _ title: String, _ grade: Int, _ subject: String, _ ibookId: String, _ section: String = "교과서") -> Book {
            Book(id: id, title: title, grade: grade, subject: subject,
                 viewPageID: ibookId, viewSection: section, publisher: .visang)
        }

        static let all: [Book] = math + mathWb + science + sciLab + social + english + music + pe + practical

        private static let math: [Book] = [
            vs("vs-math-3-1", "수학 3-1 (방정숙)", 3, "수학", "1497"),
            vs("vs-math-3-2", "수학 3-2 (방정숙)", 3, "수학", "1498"),
            vs("vs-math-4-1", "수학 4-1 (방정숙)", 4, "수학", "1499"),
            vs("vs-math-4-2", "수학 4-2 (방정숙)", 4, "수학", "1500"),
            vs("vs-math-5-1", "수학 5-1 (방정숙)", 5, "수학", "10842"),
            vs("vs-math-5-2", "수학 5-2 (방정숙)", 5, "수학", "10843"),
            vs("vs-math-6-1", "수학 6-1 (방정숙)", 6, "수학", "10846"),
            vs("vs-math-6-2", "수학 6-2 (방정숙)", 6, "수학", "10848"),
        ]
        private static let mathWb: [Book] = [
            vs("vs-mathwb-3-1", "수학익힘 3-1 (방정숙)", 3, "수학익힘", "1583", "수학익힘"),
            vs("vs-mathwb-3-2", "수학익힘 3-2 (방정숙)", 3, "수학익힘", "1584", "수학익힘"),
            vs("vs-mathwb-4-1", "수학익힘 4-1 (방정숙)", 4, "수학익힘", "1585", "수학익힘"),
            vs("vs-mathwb-4-2", "수학익힘 4-2 (방정숙)", 4, "수학익힘", "1586", "수학익힘"),
            vs("vs-mathwb-5-1", "수학익힘 5-1 (방정숙)", 5, "수학익힘", "10849", "수학익힘"),
            vs("vs-mathwb-5-2", "수학익힘 5-2 (방정숙)", 5, "수학익힘", "10850", "수학익힘"),
            vs("vs-mathwb-6-1", "수학익힘 6-1 (방정숙)", 6, "수학익힘", "10851", "수학익힘"),
            vs("vs-mathwb-6-2", "수학익힘 6-2 (방정숙)", 6, "수학익힘", "10852", "수학익힘"),
        ]
        private static let science: [Book] = [
            vs("vs-sci-3-1", "과학 3-1 (강석진)", 3, "과학", "1514"),
            vs("vs-sci-3-2", "과학 3-2 (강석진)", 3, "과학", "1515"),
            vs("vs-sci-4-1", "과학 4-1 (강석진)", 4, "과학", "1516"),
            vs("vs-sci-4-2", "과학 4-2 (강석진)", 4, "과학", "1517"),
        ]
        private static let sciLab: [Book] = [
            vs("vs-lab-3-1", "실험관찰 3-1 (강석진)", 3, "실험관찰", "1520", "실험관찰"),
            vs("vs-lab-3-2", "실험관찰 3-2 (강석진)", 3, "실험관찰", "1521", "실험관찰"),
            vs("vs-lab-4-1", "실험관찰 4-1 (강석진)", 4, "실험관찰", "1523", "실험관찰"),
            vs("vs-lab-4-2", "실험관찰 4-2 (강석진)", 4, "실험관찰", "1524", "실험관찰"),
            vs("vs-lab-5-1", "실험관찰 5-1 (강석진)", 5, "실험관찰", "11132", "실험관찰"),
            vs("vs-lab-5-2", "실험관찰 5-2 (강석진)", 5, "실험관찰", "11133", "실험관찰"),
            vs("vs-lab-6-1", "실험관찰 6-1 (강석진)", 6, "실험관찰", "11134", "실험관찰"),
            vs("vs-lab-6-2", "실험관찰 6-2 (강석진)", 6, "실험관찰", "11135", "실험관찰"),
        ]
        private static let social: [Book] = [
            vs("vs-social-3-1", "사회 3-1 (설규주)", 3, "사회", "1593"),
            vs("vs-social-3-2", "사회 3-2 (설규주)", 3, "사회", "1594"),
            vs("vs-social-4-1", "사회 4-1 (설규주)", 4, "사회", "1595"),
            vs("vs-social-4-2", "사회 4-2 (설규주)", 4, "사회", "1596"),
        ]
        private static let english: [Book] = [
            vs("vs-eng-5", "영어 5 (우길주)", 5, "영어", "8178"),
            vs("vs-eng-6", "영어 6 (우길주)", 6, "영어", "8181"),
        ]
        private static let music: [Book] = [
            vs("vs-music-3", "음악 3 (주대창)", 3, "음악", "1690"),
            vs("vs-music-4", "음악 4 (주대창)", 4, "음악", "1691"),
            vs("vs-music-5", "음악 5 (주대창)", 5, "음악", "11125"),
            vs("vs-music-6", "음악 6 (주대창)", 6, "음악", "11126"),
        ]
        private static let pe: [Book] = [
            vs("vs-pe-5", "체육 5 (송지환)", 5, "체육", "11136"),
            vs("vs-pe-6", "체육 6 (송지환)", 6, "체육", "11139"),
        ]
        private static let practical: [Book] = [
            vs("vs-practical-5", "실과 5 (송현순)", 5, "실과", "11144"),
            vs("vs-practical-6", "실과 6 (송현순)", 6, "실과", "11147"),
        ]
    }
}

// MARK: - 동아출판 (페이지별 JPG → PDF 병합. viewPageID 형식 "dirCode|maxPage")

extension BookCatalog {
    enum Donga {
        private static func da(_ id: String, _ title: String, _ grade: Int, _ subject: String, _ dirCode: String, _ maxPage: Int, _ section: String = "교과서") -> Book {
            Book(id: id, title: title, grade: grade, subject: subject,
                 viewPageID: "\(dirCode)|\(maxPage)", viewSection: section, publisher: .donga)
        }

        static let all: [Book] = math + social + science + english + music + art + pe

        private static let math: [Book] = [
            da("da-math-3-1", "수학 3-1", 3, "수학", "2203", 196),
            da("da-math-3-2", "수학 3-2", 3, "수학", "2206", 184),
            da("da-math-4-1", "수학 4-1", 4, "수학", "2209", 200),
            da("da-math-4-2", "수학 4-2", 4, "수학", "2213", 188),
        ]
        private static let social: [Book] = [
            da("da-social-3-1", "사회 3-1", 3, "사회", "2397", 172),
            da("da-social-3-2", "사회 3-2", 3, "사회", "2443", 168),
            da("da-social-4-1", "사회 4-1", 4, "사회", "2440", 188),
            da("da-social-4-2", "사회 4-2", 4, "사회", "2441", 184),
        ]
        private static let science: [Book] = [
            da("da-sci-3-1", "과학 3-1", 3, "과학", "2268", 152),
            da("da-sci-3-2", "과학 3-2", 3, "과학", "2272", 148),
            da("da-sci-4-1", "과학 4-1", 4, "과학", "2444", 176),
            da("da-sci-4-2", "과학 4-2", 4, "과학", "2445", 172),
        ]
        private static let english: [Book] = [
            da("da-eng-3-1", "영어 3-1", 3, "영어", "2224", 128),
            da("da-eng-3-2", "영어 3-2", 3, "영어", "2228", 128),
        ]
        private static let music: [Book] = [
            da("da-music-3", "음악 3", 3, "음악", "2410", 96),
            da("da-music-4", "음악 4", 4, "음악", "2411", 96),
        ]
        private static let art: [Book] = [
            da("da-art-3", "미술 3", 3, "미술", "2178", 112),
            da("da-art-4", "미술 4", 4, "미술", "2190", 112),
        ]
        private static let pe: [Book] = [
            da("da-pe-3", "체육 3", 3, "체육", "2421", 104),
            da("da-pe-4", "체육 4", 4, "체육", "2425", 104),
        ]
    }
}
