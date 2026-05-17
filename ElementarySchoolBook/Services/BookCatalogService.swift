import Foundation

actor BookCatalogService {
    private let baseURL = "https://22txbook.m-teacher.co.kr/book"

    // view.mrn 페이지에서 학생용 교과서의 단축 URL 추출
    func fetchShortURL(for book: Book) async throws -> String {
        let url = URL(string: "\(baseURL)/view.mrn?id=\(book.viewPageID)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let html = String(data: data, encoding: .utf8) ?? ""

        guard let shortURL = parseShortURL(from: html, matching: book.linkTitle) else {
            throw CatalogError.shortURLNotFound(book.title)
        }
        return shortURL
    }

    // HTML에서 "교과서" 섹션을 찾아 linkTitle과 일치하는 q.mirae-n.com URL 반환
    private func parseShortURL(from html: String, matching linkTitle: String) -> String? {
        // "교과서" viewSub 버튼 위치 탐색 (교사용 교과서는 제외)
        // 패턴: >교과서</a> (교사용이 아닌 순수 "교과서" 섹션)
        let sectionMarker = ">교과서</a>"
        var searchStart = html.startIndex

        while let markerRange = html.range(of: sectionMarker, range: searchStart..<html.endIndex) {
            // "교사용" 이 앞에 있으면 건너뜀
            let precedingStart = html.index(markerRange.lowerBound, offsetBy: -10, limitedBy: html.startIndex) ?? html.startIndex
            let preceding = String(html[precedingStart..<markerRange.lowerBound])
            if preceding.contains("교사용") {
                searchStart = markerRange.upperBound
                continue
            }

            // 이 섹션의 끝: 다음 viewSub 위치
            let afterMarker = String(html[markerRange.upperBound...])
            let endMarker = "viewSub"
            let sectionContent: String
            if let endRange = afterMarker.range(of: endMarker) {
                sectionContent = String(afterMarker[..<endRange.lowerBound])
            } else {
                sectionContent = afterMarker
            }

            // 섹션 안의 링크 파싱: href="https://q.mirae-n.com/XXXX">TITLE</a>
            if let url = extractURL(from: sectionContent, matching: linkTitle) {
                return url
            }

            searchStart = markerRange.upperBound
        }

        // linkTitle 매칭 실패 시 섹션 내 첫 번째 URL 반환 (단일 교과서인 경우)
        if let fallback = findFirstShortURL(in: html, afterSection: sectionMarker) {
            return fallback
        }

        return nil
    }

    private func extractURL(from sectionHTML: String, matching title: String) -> String? {
        let pattern = #"href="(https://q\.mirae-n\.com/[A-Za-z0-9]+)"[^>]*>\s*([^<]+)\s*<"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(sectionHTML.startIndex..., in: sectionHTML)
        for match in regex.matches(in: sectionHTML, range: range) {
            guard let urlRange = Range(match.range(at: 1), in: sectionHTML),
                  let titleRange = Range(match.range(at: 2), in: sectionHTML) else { continue }
            let foundTitle = String(sectionHTML[titleRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            if foundTitle == title {
                return String(sectionHTML[urlRange])
            }
        }
        return nil
    }

    private func findFirstShortURL(in html: String, afterSection section: String) -> String? {
        guard let sectionRange = html.range(of: section) else { return nil }
        let afterSection = String(html[sectionRange.upperBound...])
        let endMarker = "viewSub"
        let content = afterSection.range(of: endMarker).map { String(afterSection[..<$0.lowerBound]) } ?? afterSection

        let pattern = #"href="(https://q\.mirae-n\.com/[A-Za-z0-9]+)""#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
              let urlRange = Range(match.range(at: 1), in: content) else { return nil }
        return String(content[urlRange])
    }

    enum CatalogError: LocalizedError {
        case shortURLNotFound(String)

        var errorDescription: String? {
            switch self {
            case .shortURLNotFound(let title): return "\(title) 다운로드 링크를 찾을 수 없습니다."
            }
        }
    }
}
