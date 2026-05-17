import Foundation

enum BookCatalog {
    static let all: [Book] = grade3 + grade4 + grade5 + grade6

    // MARK: - 3학년
    static let grade3: [Book] = [
        Book(id: "math-3-1",    title: "수학 3-1",     linkTitle: "수학3-1",    grade: 3, subject: "수학", viewPageID: "1"),
        Book(id: "math-3-2",    title: "수학 3-2",     linkTitle: "수학3-2",    grade: 3, subject: "수학", viewPageID: "1"),
        Book(id: "social-3-1",  title: "사회 3-1",     linkTitle: "사회3-1",    grade: 3, subject: "사회", viewPageID: "5"),
        Book(id: "social-3-2",  title: "사회 3-2",     linkTitle: "사회3-2",    grade: 3, subject: "사회", viewPageID: "5"),
        Book(id: "science-3-1", title: "과학 3-1",     linkTitle: "과학3-1",    grade: 3, subject: "과학", viewPageID: "9"),
        Book(id: "science-3-2", title: "과학 3-2",     linkTitle: "과학3-2",    grade: 3, subject: "과학", viewPageID: "9"),
        Book(id: "english-3",   title: "영어 3",       linkTitle: "영어3",      grade: 3, subject: "영어", viewPageID: "13"),
        Book(id: "art-3",       title: "미술 3",       linkTitle: "미술3",      grade: 3, subject: "미술", viewPageID: "15"),
        Book(id: "music-3",     title: "음악 3",       linkTitle: "음악3",      grade: 3, subject: "음악", viewPageID: "10022"),
        Book(id: "pe-3",        title: "체육 3",       linkTitle: "체육3",      grade: 3, subject: "체육", viewPageID: "17"),
    ]

    // MARK: - 4학년
    static let grade4: [Book] = [
        Book(id: "math-4-1",    title: "수학 4-1",     linkTitle: "수학4-1",    grade: 4, subject: "수학", viewPageID: "1"),
        Book(id: "math-4-2",    title: "수학 4-2",     linkTitle: "수학4-2",    grade: 4, subject: "수학", viewPageID: "1"),
        Book(id: "social-4-1",  title: "사회 4-1",     linkTitle: "사회4-1",    grade: 4, subject: "사회", viewPageID: "5"),
        Book(id: "social-4-2",  title: "사회 4-2",     linkTitle: "사회4-2",    grade: 4, subject: "사회", viewPageID: "5"),
        Book(id: "science-4-1", title: "과학 4-1",     linkTitle: "과학4-1",    grade: 4, subject: "과학", viewPageID: "9"),
        Book(id: "science-4-2", title: "과학 4-2",     linkTitle: "과학4-2",    grade: 4, subject: "과학", viewPageID: "9"),
        Book(id: "english-4",   title: "영어 4",       linkTitle: "영어4",      grade: 4, subject: "영어", viewPageID: "14"),
        Book(id: "art-4",       title: "미술 4",       linkTitle: "미술4",      grade: 4, subject: "미술", viewPageID: "15"),
        Book(id: "music-4",     title: "음악 4",       linkTitle: "음악4",      grade: 4, subject: "음악", viewPageID: "10022"),
        Book(id: "pe-4",        title: "체육 4",       linkTitle: "체육4",      grade: 4, subject: "체육", viewPageID: "17"),
    ]

    // MARK: - 5학년
    static let grade5: [Book] = [
        Book(id: "math-5-1",    title: "수학 5-1",     linkTitle: "수학5-1",    grade: 5, subject: "수학", viewPageID: "10004"),
        Book(id: "math-5-2",    title: "수학 5-2",     linkTitle: "수학5-2",    grade: 5, subject: "수학", viewPageID: "10004"),
        Book(id: "social-5-1",  title: "사회 5-1",     linkTitle: "사회5-1",    grade: 5, subject: "사회", viewPageID: "10008"),
        Book(id: "social-5-2",  title: "사회 5-2",     linkTitle: "사회5-2",    grade: 5, subject: "사회", viewPageID: "10008"),
        Book(id: "science-5-1", title: "과학 5-1",     linkTitle: "과학5-1",    grade: 5, subject: "과학", viewPageID: "10012"),
        Book(id: "science-5-2", title: "과학 5-2",     linkTitle: "과학5-2",    grade: 5, subject: "과학", viewPageID: "10012"),
        Book(id: "english-5",   title: "영어 5",       linkTitle: "영어5",      grade: 5, subject: "영어", viewPageID: "10016"),
        Book(id: "art-5",       title: "미술 5",       linkTitle: "미술5",      grade: 5, subject: "미술", viewPageID: "10018"),
        Book(id: "music-5",     title: "음악 5",       linkTitle: "음악5",      grade: 5, subject: "음악", viewPageID: "10022"),
        Book(id: "pe-5",        title: "체육 5",       linkTitle: "체육5",      grade: 5, subject: "체육", viewPageID: "10020"),
        Book(id: "practical-5", title: "실과 5",       linkTitle: "실과5",      grade: 5, subject: "실과", viewPageID: "10026"),
    ]

    // MARK: - 6학년
    static let grade6: [Book] = [
        Book(id: "math-6-1",    title: "수학 6-1",     linkTitle: "수학6-1",    grade: 6, subject: "수학", viewPageID: "10004"),
        Book(id: "math-6-2",    title: "수학 6-2",     linkTitle: "수학6-2",    grade: 6, subject: "수학", viewPageID: "10004"),
        Book(id: "social-6-1",  title: "사회 6-1",     linkTitle: "사회6-1",    grade: 6, subject: "사회", viewPageID: "10008"),
        Book(id: "social-6-2",  title: "사회 6-2",     linkTitle: "사회6-2",    grade: 6, subject: "사회", viewPageID: "10008"),
        Book(id: "science-6-1", title: "과학 6-1",     linkTitle: "과학6-1",    grade: 6, subject: "과학", viewPageID: "10012"),
        Book(id: "science-6-2", title: "과학 6-2",     linkTitle: "과학6-2",    grade: 6, subject: "과학", viewPageID: "10012"),
        Book(id: "english-6",   title: "영어 6",       linkTitle: "영어6",      grade: 6, subject: "영어", viewPageID: "10017"),
        Book(id: "art-6",       title: "미술 6",       linkTitle: "미술6",      grade: 6, subject: "미술", viewPageID: "10018"),
        Book(id: "music-6",     title: "음악 6",       linkTitle: "음악6",      grade: 6, subject: "음악", viewPageID: "10022"),
        Book(id: "pe-6",        title: "체육 6",       linkTitle: "체육6",      grade: 6, subject: "체육", viewPageID: "10020"),
        Book(id: "practical-6", title: "실과 6",       linkTitle: "실과6",      grade: 6, subject: "실과", viewPageID: "10026"),
    ]
}
