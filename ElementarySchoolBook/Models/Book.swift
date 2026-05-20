import Foundation

// MARK: - Publisher

enum Publisher: String, CaseIterable, Codable {
    case miraen     = "미래엔"
    case chunjae    = "천재교육"
    case visang     = "비상교육"
    case donga      = "동아출판"
    case ybm        = "YBM"
    case jihaksa    = "지학사"
    case iscream    = "아이스크림미디어"

    /// 모든 출판사가 카탈로그 동적 업데이트를 지원. (Donga / Jihaksa 도 API 추가됨)
    var supportsCatalogUpdate: Bool { true }
}

// MARK: - Book

struct Book: Identifiable, Codable {
    let id: String          // 고유 ID (예: "math-3-1", "ic-math-3-1")
    let title: String       // 표시 제목 ("수학 3-1")
    let linkTitle: String   // 미래엔 HTML link text. 다른 출판사는 빈 문자열
    let grade: Int          // 3, 4, 5, 6
    let subject: String     // "수학", "수학익힘", "과학", "실험관찰" …
    let viewPageID: String  // 출판사별 의미가 다름:
                            //   - 미래엔: view.mrn?id= 파라미터
                            //   - 아이스크림/지학사: 직접 PDF URL
                            //   - 천재교육: streamdocs 파일 경로
                            //   - 비상: iBook ID
                            //   - 동아: "dirCode|maxPage"
                            //   - YBM: contentId 또는 "book03|학기|자료"
    let viewSection: String // "교과서" / "수학익힘" / "실험관찰"
    let publisher: String   // Publisher.rawValue
    var lastDownloaded: Date?
    var isArchived: Bool
    /// 카탈로그 매칭 키. 기본은 id, YBM 동적 카탈로그처럼 contentId 가 바뀌어도
    /// 같은 책으로 인식해야 하는 경우에 별도 키 사용.
    var catalogKey: String

    init(id: String, title: String, linkTitle: String = "",
         grade: Int, subject: String, viewPageID: String,
         viewSection: String = "교과서",
         publisher: Publisher = .miraen,
         lastDownloaded: Date? = nil,
         isArchived: Bool = false,
         catalogKey: String? = nil) {
        self.id            = id
        self.title         = title
        self.linkTitle     = linkTitle
        self.grade         = grade
        self.subject       = subject
        self.viewPageID    = viewPageID
        self.viewSection   = viewSection
        self.publisher     = publisher.rawValue
        self.lastDownloaded = lastDownloaded
        self.isArchived    = isArchived
        self.catalogKey    = catalogKey ?? id
    }

    var publisherEnum: Publisher? { Publisher(rawValue: publisher) }

    var localPDFPath: URL {
        documentsDir.appendingPathComponent("\(id).pdf")
    }

    var annotationPath: URL {
        documentsDir.appendingPathComponent("\(id).pkd")
    }

    var isDownloaded: Bool {
        FileManager.default.fileExists(atPath: localPDFPath.path)
    }

    /// 교과서 외 부교재 라벨 (카드 배지용)
    var supplementLabel: String? {
        switch viewSection {
        case "수학익힘":  return "익힘"
        case "실험관찰":  return "실험관찰"
        default:         return nil
        }
    }

    private var documentsDir: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
