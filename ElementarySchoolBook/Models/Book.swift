import Foundation

struct Book: Identifiable, Codable {
    let id: String          // "math-3-1"
    let title: String       // "수학 3-1"
    let linkTitle: String   // HTML link text "수학3-1"
    let grade: Int          // 3, 4, 5, 6
    let subject: String     // "수학"
    let viewPageID: String  // view.mrn?id= 파라미터
    var lastDownloaded: Date?

    var localPDFPath: URL {
        documentsDir.appendingPathComponent("\(id).pdf")
    }

    var annotationPath: URL {
        documentsDir.appendingPathComponent("\(id).pkd")
    }

    var isDownloaded: Bool {
        FileManager.default.fileExists(atPath: localPDFPath.path)
    }

    private var documentsDir: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
