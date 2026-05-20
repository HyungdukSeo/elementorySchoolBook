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
        guard parts.count == 2, let rawMaxPage = Int(parts[1]) else {
            throw DongaError.invalidFormat
        }
        let dirCode = parts[0]
        // 동적 카탈로그에서 받은 책은 maxPage = 0. HTML 파싱으로 실제 페이지 수 확인.
        let maxPage = rawMaxPage > 0 ? rawMaxPage : (try await fetchMaxPage(dirCode: dirCode) ?? 0)
        guard maxPage > 0 else { throw DongaError.maxPageUnknown }

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

    // MARK: - 동적 카탈로그 (api.douclass.com)

    /// 동아출판 홍보관 API 에서 도서 목록을 동적으로 가져옴.
    func fetchCatalogBooks() async throws -> [Book] {
        struct Source {
            let code: String
            let groups: [String]
            let subject: String
            let idPrefix: String
            let fallbackGrades: [Int]
        }
        let sources: [Source] = [
            Source(code: "P_EL_MAT", groups: ["EL_3_4", "EL_5_6"], subject: "수학",    idPrefix: "math",      fallbackGrades: []),
            Source(code: "P_EL_SOC", groups: ["EL_3_4", "EL_5_6"], subject: "사회",    idPrefix: "social",    fallbackGrades: []),
            Source(code: "P_EL_ATL", groups: ["EL_5_6"],            subject: "사회과 부도", idPrefix: "atlas",    fallbackGrades: [5, 6]),
            Source(code: "P_EL_SCI", groups: [""],                   subject: "과학",    idPrefix: "sci",       fallbackGrades: []),
            Source(code: "P_EL_ENG", groups: ["EL_3_4", "EL_5_6"], subject: "영어",    idPrefix: "eng",       fallbackGrades: []),
            Source(code: "P_EL_MUS", groups: ["EL_3_4", "EL_5_6"], subject: "음악",    idPrefix: "music",     fallbackGrades: []),
            Source(code: "P_EL_ART", groups: ["EL_3_4", "EL_5_6"], subject: "미술",    idPrefix: "art",       fallbackGrades: []),
            Source(code: "P_EL_ATH", groups: ["EL_3_4", "EL_5_6"], subject: "체육",    idPrefix: "pe",        fallbackGrades: []),
            Source(code: "P_EL_PRA", groups: ["EL_5_6"],            subject: "실과",    idPrefix: "practical", fallbackGrades: []),
        ]

        var all: [Book] = []
        var seenKeys: Set<String> = []
        for source in sources {
            for group in source.groups {
                let books = (try? await fetchSubjectBooks(code: source.code, group: group, subject: source.subject, idPrefix: source.idPrefix, fallbackGrades: source.fallbackGrades)) ?? []
                for b in books where !seenKeys.contains(b.catalogKey) {
                    seenKeys.insert(b.catalogKey)
                    all.append(b)
                }
            }
        }
        return all
    }

    private func fetchSubjectBooks(code: String, group: String, subject: String, idPrefix: String, fallbackGrades: [Int]) async throws -> [Book] {
        let groupQ = group.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? group
        let urlStr = "https://api.douclass.com/api/promotion/info?subj_code=\(code)&subj_group_code=&school_grade=\(groupQ)"
        guard let url = URL(string: urlStr) else { return [] }
        let json = try await fetchDouclassJSON(url: url)
        guard (json["ret_code"] as? Int) == 200,
              let retData = json["ret_data"] as? [String: Any],
              let list = retData["promotionTextbookList"] as? [[String: Any]] else { return [] }

        var books: [Book] = []
        for item in list {
            books.append(contentsOf: try await booksFromTextbook(item: item, subject: subject, idPrefix: idPrefix, fallbackGrades: fallbackGrades))
        }
        return books
    }

    private func booksFromTextbook(item: [String: Any], subject: String, idPrefix: String, fallbackGrades: [Int]) async throws -> [Book] {
        let textbookId = (item["textbook_id"] as? Int) ?? Int(item["textbook_id"] as? String ?? "") ?? 0
        guard textbookId > 0 else { return [] }

        let title = ((item["textBookInfo"] as? [String: Any])?["txbook_title"] as? String ?? "")
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)

        // 제목에서 학년 추출 (예: "수학 3" → 3). 없으면 fallback.
        let grades: [Int]
        if let match = title.range(of: #"(\d)"#, options: .regularExpression),
           let grade = Int(title[match].prefix(1)) {
            grades = [grade]
        } else {
            grades = fallbackGrades
        }
        guard !grades.isEmpty else { return [] }

        // textbookData 가 item 에 들어 있으면 사용, 아니면 별도 호출
        let textbookData: [String: Any]?
        if let inline = item["promotionTextbookData"] as? [String: Any] {
            textbookData = inline
        } else {
            textbookData = try await fetchTextbookData(textbookId: textbookId)
        }
        guard let data = textbookData,
              (data["textbook_file_show"] as? String) == "Y" else { return [] }

        let fileUrl = data["textbook_file_url"] as? String ?? ""
        guard let dirMatch = fileUrl.range(of: #"[?&]Dir=(\d+)"#, options: .regularExpression) else { return [] }
        let dirCode = String(fileUrl[dirMatch])
            .replacingOccurrences(of: #"[?&]Dir="#, with: "", options: .regularExpression)

        return grades.map { grade in
            let key = "da-\(idPrefix)-\(titleKey(title))-\(grade)"
            return Book(id: key, title: title, grade: grade, subject: subject,
                        viewPageID: "\(dirCode)|0",
                        viewSection: "교과서", publisher: .donga, catalogKey: key)
        }
    }

    private func fetchTextbookData(textbookId: Int) async throws -> [String: Any]? {
        let urlStr = "https://api.douclass.com/api/promotion/textbook_data?textbook_id=\(textbookId)&useLoading=false"
        guard let url = URL(string: urlStr) else { return nil }
        let json = try await fetchDouclassJSON(url: url)
        guard (json["ret_code"] as? Int) == 200,
              let retData = json["ret_data"] as? [String: Any] else { return nil }
        return retData["promotionTextbookData"] as? [String: Any]
    }

    private func fetchMaxPage(dirCode: String) async throws -> Int? {
        guard let url = URL(string: "https://ebook.dongapublishing.com/ebook/ecatalog5.asp?Dir=\(dirCode)") else { return nil }
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        let (data, _) = try await URLSession.shared.data(for: request)
        let html = String(data: data, encoding: .utf8) ?? ""
        let pattern = #"set_pageinfo\('[^']*','\d+',\d+,(\d+),"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let range = Range(match.range(at: 1), in: html) else { return nil }
        return Int(html[range])
    }

    private func fetchDouclassJSON(url: URL) async throws -> [String: Any] {
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("CHN_MID_HI", forHTTPHeaderField: "Channel-Type")
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw DongaError.httpError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        return (try? JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
    }

    private nonisolated func titleKey(_ title: String) -> String {
        title.replacingOccurrences(of: #"\s+"#, with: "-", options: .regularExpression)
             .replacingOccurrences(of: #"[^0-9A-Za-z가-힣\-]"#, with: "", options: .regularExpression)
    }

    enum DongaError: LocalizedError {
        case invalidFormat
        case httpError(Int)
        case incompleteDownload(Int, Int)
        case maxPageUnknown
        var errorDescription: String? {
            switch self {
            case .invalidFormat:                return "동아출판 데이터 형식 오류 (dirCode|maxPage)"
            case .httpError(let c):             return "동아출판 페이지 다운로드 실패 (HTTP \(c))"
            case .incompleteDownload(let g, let t):
                return "동아출판 페이지 다운로드 불완전 (\(g)/\(t))"
            case .maxPageUnknown:               return "동아출판 페이지 수 확인 실패"
            }
        }
    }
}

// MARK: - 지학사 (Base64 인코딩 JSON API + POST 다운로드)

actor JihaksaCatalogService {
    private let downloadableSections: Set<String> = ["교과서", "수학익힘", "실험관찰"]

    /// 전체 카탈로그 동적 조회 (3~6학년, 1~2학기)
    func fetchCatalogBooks() async throws -> [Book] {
        var textbooks: [(grade: Int, item: [String: Any])] = []
        for grade in 3...6 {
            for term in 1...2 {
                let list = (try? await fetchTextbookList(grade: grade, term: term)) ?? []
                for item in list {
                    textbooks.append((grade, item))
                }
            }
        }

        var all: [Book] = []
        var seenKeys: Set<String> = []
        for entry in textbooks {
            let books = (try? await booksForTextbook(grade: entry.grade, textbook: entry.item)) ?? []
            for b in books where !seenKeys.contains(b.catalogKey) {
                seenKeys.insert(b.catalogKey)
                all.append(b)
            }
        }
        return all
    }

    /// fileSeq 로 PDF 다운로드 (POST seq=fileSeq → 응답 본문이 PDF)
    func downloadPDF(fileSeq: String, to destination: URL, progress: @Sendable @escaping (Double) -> Void) async throws {
        guard let url = URL(string: "https://tsol.jihak.co.kr/file/download.ez") else {
            throw JihaksaError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.httpBody = "seq=\(fileSeq)".data(using: .utf8)
        request.timeoutInterval = 60

        let (tempURL, response) = try await URLSession.shared.download(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw JihaksaError.httpError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        let fm = FileManager.default
        if fm.fileExists(atPath: destination.path) {
            try fm.removeItem(at: destination)
        }
        try fm.moveItem(at: tempURL, to: destination)
        progress(1.0)
    }

    // MARK: - 내부

    private func fetchTextbookList(grade: Int, term: Int) async throws -> [[String: Any]] {
        let urlStr = "https://tsol.jihak.co.kr/api/v1/textbook/ele/SNB/list.ez?grade=\(grade)&term=\(term)"
        guard let url = URL(string: urlStr) else { return [] }
        let body = try await get(url: url)
        guard let decoded = Data(base64Encoded: body),
              let json = try? JSONSerialization.jsonObject(with: decoded) as? [String: Any],
              let list = json["list"] as? [[String: Any]] else { return [] }
        return list
    }

    private func fetchDataList(textbookSeq: String) async throws -> [[String: Any]] {
        let payload: [String: Any] = [
            "textbookSeq": textbookSeq,
            "schoolTypeSeq": "SUBJECT_SCHOOLTYPE_ELEMENTARY",
        ]
        let payloadData = try JSONSerialization.data(withJSONObject: payload)
        let encoded = payloadData.base64EncodedString()

        guard let url = URL(string: "https://tsol.jihak.co.kr/api/v1/textbook/data/list.ez") else { return [] }
        let body = try await postText(url: url, body: encoded)
        guard let decoded = Data(base64Encoded: body),
              let json = try? JSONSerialization.jsonObject(with: decoded) as? [String: Any],
              let list = json["dataList"] as? [[String: Any]] else { return [] }
        return list
    }

    private func booksForTextbook(grade: Int, textbook: [String: Any]) async throws -> [Book] {
        guard let textbookSeq = textbook["textbookSeq"] as? String, !textbookSeq.isEmpty,
              let subjectName = (textbook["subjectName"] as? String)?.trimmingCharacters(in: .whitespaces), !subjectName.isEmpty
        else { return [] }
        let rawName = textbook["textbookName"] as? String ?? ""
        let textbookName = normalizeTitle(rawName)
        guard !textbookName.isEmpty else { return [] }

        let dataList = try await fetchDataList(textbookSeq: textbookSeq)
        var books: [Book] = []
        for data in dataList {
            let dataName = (data["dataName"] as? String)?.trimmingCharacters(in: .whitespaces) ?? ""
            guard downloadableSections.contains(dataName) else { continue }
            guard let fileSeq = data["dataFileSeq"] as? String, !fileSeq.isEmpty else { continue }

            let subject: String
            let title: String
            switch dataName {
            case "수학익힘":
                subject = "수학익힘"
                title = textbookName.replacingOccurrences(of: "수학", with: "수학익힘")
            case "실험관찰":
                subject = "실험관찰"
                title = textbookName.replacingOccurrences(of: "과학", with: "실험관찰")
            default:
                subject = subjectName
                title = textbookName
            }
            let key = "jh-\(titleKey(title))-\(dataName)"
            books.append(Book(id: key, title: title, grade: grade, subject: subject,
                              viewPageID: fileSeq, viewSection: dataName,
                              publisher: .jihaksa, catalogKey: key))
        }
        return books
    }

    private nonisolated func titleKey(_ title: String) -> String {
        title.replacingOccurrences(of: #"\s+"#, with: "-", options: .regularExpression)
             .replacingOccurrences(of: #"[^0-9A-Za-z가-힣\-]"#, with: "", options: .regularExpression)
    }

    private nonisolated func normalizeTitle(_ title: String) -> String {
        title.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
             .replacingOccurrences(of: #"([가-힣])(\d)"#, with: "$1 $2", options: .regularExpression)
             .trimmingCharacters(in: .whitespaces)
    }

    private func get(url: URL) async throws -> String {
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw JihaksaError.httpError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        return String(data: data, encoding: .utf8) ?? ""
    }

    private func postText(url: URL, body: String) async throws -> String {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.setValue("text/plain;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.httpBody = body.data(using: .utf8)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw JihaksaError.httpError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        return String(data: data, encoding: .utf8) ?? ""
    }

    enum JihaksaError: LocalizedError {
        case invalidURL
        case httpError(Int)
        var errorDescription: String? {
            switch self {
            case .invalidURL:       return "지학사 URL 오류"
            case .httpError(let c): return "지학사 서버 오류 (HTTP \(c))"
            }
        }
    }
}
