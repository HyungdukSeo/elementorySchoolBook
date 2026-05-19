import Foundation
import PDFKit
import UIKit

actor BookCatalogService {
    private let baseURL = "https://22txbook.m-teacher.co.kr/book"

    // view.mrn 페이지에서 해당 섹션의 단축 URL 추출
    func fetchShortURL(for book: Book) async throws -> String {
        let url = URL(string: "\(baseURL)/view.mrn?id=\(book.viewPageID)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let html = String(data: data, encoding: .utf8) ?? ""

        guard let shortURL = parseShortURL(from: html,
                                           matching: book.linkTitle,
                                           section: book.viewSection) else {
            throw CatalogError.shortURLNotFound(book.title)
        }
        return shortURL
    }

    // MARK: - HTML 파싱

    /// HTML에서 지정된 섹션을 찾아 linkTitle과 일치하는 q.mirae-n.com URL 반환
    private func parseShortURL(from html: String,
                               matching linkTitle: String,
                               section: String) -> String? {
        let sectionMarker = ">\(section)</a>"

        var searchStart = html.startIndex
        while let markerRange = html.range(of: sectionMarker, range: searchStart..<html.endIndex) {

            // "교과서" 섹션은 "교사용 교과서" 제외
            if section == "교과서" {
                let precedingStart = html.index(markerRange.lowerBound,
                                               offsetBy: -10,
                                               limitedBy: html.startIndex) ?? html.startIndex
                let preceding = String(html[precedingStart..<markerRange.lowerBound])
                if preceding.contains("교사용") {
                    searchStart = markerRange.upperBound
                    continue
                }
            }

            // 섹션 끝: 다음 viewSub 위치
            let afterMarker = String(html[markerRange.upperBound...])
            let sectionContent: String
            if let endRange = afterMarker.range(of: "viewSub") {
                sectionContent = String(afterMarker[..<endRange.lowerBound])
            } else {
                sectionContent = afterMarker
            }

            // linkTitle 매칭 링크 추출
            if let url = extractURL(from: sectionContent, matching: linkTitle) {
                return url
            }

            // 단일 항목 섹션 폴백: 첫 번째 URL 반환
            if let url = firstShortURL(in: sectionContent) {
                return url
            }

            searchStart = markerRange.upperBound
        }
        return nil
    }

    /// 섹션 HTML에서 linkTitle과 정확히 일치하는 URL 반환
    private func extractURL(from sectionHTML: String, matching title: String) -> String? {
        let pattern = #"href="(https://q\.mirae-n\.com/[A-Za-z0-9]+)"[^>]*>\s*([^<]+?)\s*<"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(sectionHTML.startIndex..., in: sectionHTML)
        for match in regex.matches(in: sectionHTML, range: range) {
            guard let urlRange   = Range(match.range(at: 1), in: sectionHTML),
                  let titleRange = Range(match.range(at: 2), in: sectionHTML) else { continue }
            let found = String(sectionHTML[titleRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            if found == title {
                return String(sectionHTML[urlRange])
            }
        }
        return nil
    }

    /// 섹션 HTML 내 첫 번째 단축 URL 반환 (단일 항목 섹션 폴백)
    private func firstShortURL(in sectionHTML: String) -> String? {
        let pattern = #"href="(https://q\.mirae-n\.com/[A-Za-z0-9]+)""#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: sectionHTML,
                                           range: NSRange(sectionHTML.startIndex..., in: sectionHTML)),
              let urlRange = Range(match.range(at: 1), in: sectionHTML) else { return nil }
        return String(sectionHTML[urlRange])
    }

    // MARK: - Error

    enum CatalogError: LocalizedError {
        case shortURLNotFound(String)
        var errorDescription: String? {
            if case .shortURLNotFound(let title) = self {
                return "\(title) 다운로드 링크를 찾을 수 없습니다."
            }
            return nil
        }
    }
}

// MARK: - 천재교육 (streamdocs API)

actor TsherpaCatalogService {
    private let apiURL = URL(string: "https://view.chunjae.co.kr/streamdocs/v4/custom/documents/view")!
    private let pdfBaseURL = "https://view.chunjae.co.kr/streamdocs/v4/documents"

    /// filePath → 직접 다운로드 가능한 PDF URL 반환
    func resolvePDFURL(filePath: String) async throws -> String {
        let id = try await fetchStreamdocsId(filePath: filePath)
        return "\(pdfBaseURL)/\(id)"
    }

    private func fetchStreamdocsId(filePath: String) async throws -> String {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15

        let body: [String: Any] = [
            "srcFilePath": ["T:/tsherpa\(filePath)"],
            "isLogin": "true",
            "userType": "S",
            "pageNumber": "pageNumber",
            "isExternal": "y",
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw ChunjaeError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let alink = json["alink"] as? String, !alink.isEmpty else {
            throw ChunjaeError.linkNotFound
        }

        // alink 예: https://view.chunjae.co.kr/streamdocs/view/sd;streamdocsId=XXXX;...
        guard let idRange = alink.range(of: "streamdocsId=") else {
            throw ChunjaeError.idNotFound
        }
        let after = alink[idRange.upperBound...]
        let end = after.firstIndex(of: ";") ?? after.endIndex
        return String(after[..<end])
    }

    enum ChunjaeError: LocalizedError {
        case serverError(Int)
        case linkNotFound
        case idNotFound
        var errorDescription: String? {
            switch self {
            case .serverError(let code): return "천재교육 서버 오류 (\(code))"
            case .linkNotFound:          return "천재교육 문서 링크를 받지 못했습니다."
            case .idNotFound:            return "streamdocsId 를 찾을 수 없습니다."
            }
        }
    }
}

// MARK: - YBM (REST API)

actor YbmCatalogService {

    /// Book 의 viewPageID 형식에 따라 PDF URL 반환.
    /// - "C..." 로 시작: contentId 직접 지정
    /// - "bookCode|semester|materialTitle": 홍보관 JSON 에서 contentId 조회
    func resolvePDFURL(book: Book) async throws -> String {
        let contentId: String
        if book.viewPageID.hasPrefix("C") {
            contentId = book.viewPageID
        } else {
            contentId = try await resolveContentId(selector: book.viewPageID)
        }
        return try await resolvePDFURL(byContentId: contentId)
    }

    /// YBM 홍보관 전체 도서 목록을 동적으로 가져옴.
    /// bookCode 별로 TEXTBOOK_INFO + textbooks API 를 호출해 Book 배열 생성.
    func fetchCatalogBooks() async throws -> [Book] {
        let bookCodes = [
            "book01", "book02", "book03", "book04", "book05", "book06",
            "book07", "book08", "book11", "book12", "book13", "book14",
            "book15", "book16",
        ]
        var all: [Book] = []
        for code in bookCodes {
            do {
                all.append(contentsOf: try await fetchCatalogBooks(bookCode: code))
            } catch {
                // 일부 bookCode 가 404 일 수 있음 — 무시하고 진행
            }
        }
        return all
    }

    private func fetchCatalogBooks(bookCode: String) async throws -> [Book] {
        let bookURL = URL(string: "https://www.ybmcloud.com/prcenter/book/ele/\(bookCode).json")!
        let bookJson = try await fetchJSONObject(url: bookURL)
        guard let textbookInfo = bookJson["TEXTBOOK_INFO"] as? [[String: Any]] else { return [] }
        let titleInfo = parseTitleInfo(rawTitle: bookJson["title"] as? String ?? "")

        let ids = textbookInfo.compactMap { $0["TEXTBOOK_ID"] as? String }.filter { !$0.isEmpty }
        guard !ids.isEmpty else { return [] }

        let query = ids
            .map { "textbookIds=\($0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0)" }
            .joined(separator: "&")
        let materialsURL = URL(string: "https://www.ybmcloud.com/rest/prcenter/textbooks?\(query)")!
        let materials = try await fetchJSONArray(url: materialsURL)

        var semesterByTextbookId: [String: String] = [:]
        for item in textbookInfo {
            if let id = item["TEXTBOOK_ID"] as? String,
               let sem = item["SEMESTER"] as? String {
                semesterByTextbookId[id] = sem
            }
        }

        var books: [Book] = []
        for item in materials {
            guard (item["mtrlTitle"] as? String) == "교과서" else { continue }
            guard let textbookId = item["textbookId"] as? String, !textbookId.isEmpty,
                  let contentId = item["contentid"] as? String, !contentId.isEmpty,
                  let semester = semesterByTextbookId[textbookId], !semester.isEmpty else { continue }

            // 학기 문자열에서 첫 숫자(학년) 추출
            guard let gradeChar = semester.first(where: { $0.isNumber }),
                  let grade = Int(String(gradeChar)),
                  (3...6).contains(grade) else { continue }

            let title = buildDisplayTitle(subject: titleInfo.subject, semester: semester, author: titleInfo.author)
            let catalogKey = "ybm-\(bookCode)-\(semester)-교과서"
            let id = "\(catalogKey)-\(contentId.suffix(6))"

            books.append(Book(
                id: id,
                title: title,
                grade: grade,
                subject: titleInfo.subject,
                viewPageID: contentId,
                viewSection: "교과서",
                publisher: .ybm,
                catalogKey: catalogKey
            ))
        }
        return books
    }

    private struct TitleInfo {
        let subject: String
        let author: String
    }

    private func parseTitleInfo(rawTitle: String) -> TitleInfo {
        // 괄호 안의 저자 추출
        let authorRegex = try? NSRegularExpression(pattern: #"\(([^)]+)\)"#)
        let nsTitle = rawTitle as NSString
        var author = ""
        if let match = authorRegex?.firstMatch(in: rawTitle, range: NSRange(location: 0, length: nsTitle.length)),
           match.numberOfRanges > 1 {
            author = nsTitle.substring(with: match.range(at: 1))
        }
        // 과목명: 괄호와 "n~m학년군" 제거
        var subject = rawTitle
        subject = subject.replacingOccurrences(of: #"\([^)]*\)"#, with: "", options: .regularExpression)
        subject = subject.replacingOccurrences(of: #"\d+\s*~\s*\d+학년군"#, with: "", options: .regularExpression)
        subject = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        if subject.isEmpty { subject = "교과서" }
        return TitleInfo(subject: subject, author: author)
    }

    private func buildDisplayTitle(subject: String, semester: String, author: String) -> String {
        // "3학년 1학기" → "3-1"
        let regex = try? NSRegularExpression(pattern: #"(\d+)학년(?:\s*(\d+)학기)?"#)
        let ns = semester as NSString
        var gradeLabel = semester
        if let match = regex?.firstMatch(in: semester, range: NSRange(location: 0, length: ns.length)) {
            let grade = match.range(at: 1).location != NSNotFound ? ns.substring(with: match.range(at: 1)) : ""
            let term = match.numberOfRanges > 2 && match.range(at: 2).location != NSNotFound ? ns.substring(with: match.range(at: 2)) : ""
            if !grade.isEmpty {
                gradeLabel = term.isEmpty ? grade : "\(grade)-\(term)"
            }
        }
        return author.isEmpty ? "\(subject) \(gradeLabel)" : "\(subject) \(gradeLabel) (\(author))"
    }

    private func resolveContentId(selector: String) async throws -> String {
        let parts = selector.split(separator: "|").map(String.init)
        guard parts.count == 3 else { throw YbmError.invalidFormat }
        let bookCode = parts[0]
        let semester = parts[1]
        let materialTitle = parts[2]

        let bookURL = URL(string: "https://www.ybmcloud.com/prcenter/book/ele/\(bookCode).json")!
        let bookJson = try await fetchJSONObject(url: bookURL)
        guard let textbookInfo = bookJson["TEXTBOOK_INFO"] as? [[String: Any]] else {
            throw YbmError.noTextbookInfo(bookCode)
        }
        guard let textbookId = textbookInfo.first(where: { ($0["SEMESTER"] as? String) == semester })?["TEXTBOOK_ID"] as? String,
              !textbookId.isEmpty else {
            throw YbmError.semesterNotFound(semester)
        }

        let encodedId = textbookId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? textbookId
        let materialsURL = URL(string: "https://www.ybmcloud.com/rest/prcenter/textbooks?textbookIds=\(encodedId)")!
        let materials = try await fetchJSONArray(url: materialsURL)

        for item in materials {
            if (item["textbookId"] as? String) == textbookId,
               (item["mtrlTitle"] as? String) == materialTitle,
               let contentId = item["contentid"] as? String, !contentId.isEmpty {
                return contentId
            }
        }
        throw YbmError.materialNotFound(materialTitle)
    }

    private func resolvePDFURL(byContentId contentId: String) async throws -> String {
        let url = URL(string: "https://www.ybmcloud.com/rest/viewer/getContents?contentsId=\(contentId)")!
        let json = try await fetchJSONObject(url: url)
        if let view = json["viewFilePath"] as? String, !view.isEmpty { return view }
        if let upload = json["uploadFilePath"] as? String, !upload.isEmpty { return upload }
        throw YbmError.pdfURLNotFound
    }

    private func fetchJSONObject(url: URL) async throws -> [String: Any] {
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw YbmError.httpError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        guard let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw YbmError.invalidJSON
        }
        return obj
    }

    private func fetchJSONArray(url: URL) async throws -> [[String: Any]] {
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw YbmError.httpError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        guard let arr = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw YbmError.invalidJSON
        }
        return arr
    }

    enum YbmError: LocalizedError {
        case invalidFormat
        case noTextbookInfo(String)
        case semesterNotFound(String)
        case materialNotFound(String)
        case pdfURLNotFound
        case httpError(Int)
        case invalidJSON
        var errorDescription: String? {
            switch self {
            case .invalidFormat:           return "YBM 데이터 형식 오류"
            case .noTextbookInfo(let c):   return "YBM TEXTBOOK_INFO 없음: \(c)"
            case .semesterNotFound(let s): return "YBM 학기 정보를 찾을 수 없습니다: \(s)"
            case .materialNotFound(let m): return "YBM 자료를 찾을 수 없습니다: \(m)"
            case .pdfURLNotFound:          return "YBM API: PDF URL 을 찾을 수 없습니다"
            case .httpError(let c):        return "YBM API 오류 (HTTP \(c))"
            case .invalidJSON:             return "YBM API: 잘못된 JSON 응답"
            }
        }
    }
}

// MARK: - 비상교육 (config.js → 페이지별 PDF → PDFKit 병합)

actor VisangCatalogService {
    private let configURLTemplate = "https://ibook.vivasam.com/CBS_iBook/%@/contents/config/config.js"
    private let pageURLTemplate   = "https://ibook.vivasam.com/CBS_iBook/%@/contents/data/%@.pdf"

    func downloadAndMerge(ibookId: String, destination: URL, progress: @Sendable @escaping (Double) -> Void) async throws {
        let pageNames = try await fetchPageNames(ibookId: ibookId)
        guard !pageNames.isEmpty else {
            throw VisangError.noPages
        }

        let tmpDir = destination.deletingPathExtension().appendingPathExtension("tmp")
        let fm = FileManager.default
        if fm.fileExists(atPath: tmpDir.path) {
            try? fm.removeItem(at: tmpDir)
        }
        try fm.createDirectory(at: tmpDir, withIntermediateDirectories: true)

        defer { try? fm.removeItem(at: tmpDir) }

        // 페이지 다운로드 (0 ~ 80%)
        var pageURLs: [URL] = []
        let total = pageNames.count
        for (i, name) in pageNames.enumerated() {
            let urlStr = String(format: pageURLTemplate, ibookId, name)
            guard let pageURL = URL(string: urlStr) else { continue }
            let dest = tmpDir.appendingPathComponent("\(i).pdf")
            try await downloadSinglePage(url: pageURL, to: dest)
            pageURLs.append(dest)
            progress(Double(i + 1) / Double(total) * 0.8)
        }

        // 병합 (80~100%)
        progress(0.85)
        try await mergePDFs(pageFiles: pageURLs, destination: destination)
        progress(1.0)
    }

    private func fetchPageNames(ibookId: String) async throws -> [String] {
        guard let url = URL(string: String(format: configURLTemplate, ibookId)) else {
            throw VisangError.invalidURL
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw VisangError.httpError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        let text = String(data: data, encoding: .utf8) ?? ""

        // e_arrPageName = ["abc","def",...];
        let pattern = #"e_arrPageName\s*=\s*\[([^\]]+)\]"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let bodyRange = Range(match.range(at: 1), in: text) else {
            return []
        }
        return text[bodyRange]
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: " \"\n\t")) }
            .filter { !$0.isEmpty }
    }

    private func downloadSinglePage(url: URL, to destination: URL) async throws {
        let (tempURL, response) = try await URLSession.shared.download(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw VisangError.httpError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        let fm = FileManager.default
        if fm.fileExists(atPath: destination.path) {
            try fm.removeItem(at: destination)
        }
        try fm.moveItem(at: tempURL, to: destination)
    }

    private func mergePDFs(pageFiles: [URL], destination: URL) async throws {
        let merged = PDFDocument()
        var pageIndex = 0
        for file in pageFiles {
            guard let doc = PDFDocument(url: file) else { continue }
            for i in 0..<doc.pageCount {
                if let page = doc.page(at: i) {
                    merged.insert(page, at: pageIndex)
                    pageIndex += 1
                }
            }
        }
        guard pageIndex > 0 else {
            throw VisangError.mergeFailed
        }
        let fm = FileManager.default
        if fm.fileExists(atPath: destination.path) {
            try fm.removeItem(at: destination)
        }
        guard merged.write(to: destination) else {
            throw VisangError.writeFailed
        }
    }

    enum VisangError: LocalizedError {
        case invalidURL
        case noPages
        case httpError(Int)
        case mergeFailed
        case writeFailed
        var errorDescription: String? {
            switch self {
            case .invalidURL:      return "비상교육 URL 오류"
            case .noPages:         return "비상교육 교과서 페이지 정보를 가져오지 못했습니다."
            case .httpError(let c):return "비상교육 페이지 다운로드 실패 (HTTP \(c))"
            case .mergeFailed:     return "비상교육 PDF 병합 실패"
            case .writeFailed:     return "비상교육 PDF 저장 실패"
            }
        }
    }
}

// MARK: - 동아출판 (페이지별 JPG → UIGraphicsPDFRenderer 로 PDF 병합. viewPageID = "dirCode|maxPage")

actor DongaCatalogService {
    private let imageURLTemplate = "https://ebook.dongapublishing.com/ebook/catImage/%@/%@.jpg"

    func downloadAndMerge(viewPageID: String, destination: URL, progress: @Sendable @escaping (Double) -> Void) async throws {
        let parts = viewPageID.split(separator: "|").map(String.init)
        guard parts.count == 2, let maxPage = Int(parts[1]) else {
            throw DongaError.invalidFormat
        }
        let dirCode = parts[0]

        let tmpDir = destination.deletingPathExtension().appendingPathExtension("tmp")
        let fm = FileManager.default
        if fm.fileExists(atPath: tmpDir.path) {
            try? fm.removeItem(at: tmpDir)
        }
        try fm.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: tmpDir) }

        // 다운로드 (0 ~ 80%)
        var imageFiles: [URL] = []
        for page in 1...maxPage {
            let padded = String(format: "%03d", page)
            let urlStr = String(format: imageURLTemplate, dirCode, padded)
            guard let url = URL(string: urlStr) else { continue }
            let dest = tmpDir.appendingPathComponent("\(padded).jpg")
            try await downloadImage(url: url, to: dest)
            imageFiles.append(dest)
            progress(Double(page) / Double(maxPage) * 0.8)
        }
        guard imageFiles.count == maxPage else {
            throw DongaError.incompleteDownload(imageFiles.count, maxPage)
        }

        // 병합 (80~100%)
        progress(0.85)
        try mergeImagesToPDF(imageFiles: imageFiles, destination: destination)
        progress(1.0)
    }

    private func downloadImage(url: URL, to destination: URL) async throws {
        let (tempURL, response) = try await URLSession.shared.download(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw DongaError.httpError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        let fm = FileManager.default
        if fm.fileExists(atPath: destination.path) {
            try fm.removeItem(at: destination)
        }
        try fm.moveItem(at: tempURL, to: destination)
    }

    private func mergeImagesToPDF(imageFiles: [URL], destination: URL) throws {
        // 안드로이드 버전과 동일한 해상도: 1000 x 1414
        let pageRect = CGRect(x: 0, y: 0, width: 1000, height: 1414)
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { ctx in
            for file in imageFiles {
                guard let image = UIImage(contentsOfFile: file.path) else { continue }
                ctx.beginPage()
                image.draw(in: pageRect)
            }
        }

        let fm = FileManager.default
        if fm.fileExists(atPath: destination.path) {
            try fm.removeItem(at: destination)
        }
        try data.write(to: destination, options: .atomic)
    }

    enum DongaError: LocalizedError {
        case invalidFormat
        case httpError(Int)
        case incompleteDownload(Int, Int)
        var errorDescription: String? {
            switch self {
            case .invalidFormat:                return "동아출판 데이터 형식 오류 (dirCode|maxPage)"
            case .httpError(let c):             return "동아출판 페이지 다운로드 실패 (HTTP \(c))"
            case .incompleteDownload(let g, let t):
                return "동아출판 페이지 다운로드 불완전 (\(g)/\(t))"
            }
        }
    }
}
