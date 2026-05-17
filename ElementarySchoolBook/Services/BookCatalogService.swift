import Foundation

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
