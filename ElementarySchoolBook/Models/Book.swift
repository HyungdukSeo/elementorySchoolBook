import Foundation

struct Book: Identifiable, Codable {
    let id: String          // "math-3-1"
    let title: String       // "수학 3-1"
    let linkTitle: String   // HTML link text "수학3-1"
    let grade: Int          // 3, 4, 5, 6
    let subject: String     // "수학", "수학익힘", "과학", "실험관찰" …
    let viewPageID: String  // view.mrn?id= 파라미터
    let viewSection: String // HTML 섹션명: "교과서", "수학익힘", "실험관찰"
    var lastDownloaded: Date?

    // viewSection 기본값 "교과서" — 기존 호출부 수정 불필요
    init(id: String, title: String, linkTitle: String,
         grade: Int, subject: String, viewPageID: String,
         viewSection: String = "교과서", lastDownloaded: Date? = nil) {
        self.id            = id
        self.title         = title
        self.linkTitle     = linkTitle
        self.grade         = grade
        self.subject       = subject
        self.viewPageID    = viewPageID
        self.viewSection   = viewSection
        self.lastDownloaded = lastDownloaded
    }

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
