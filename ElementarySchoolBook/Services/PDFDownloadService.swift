import Foundation
import os

actor PDFDownloadService {

    // 단축 URL → PDF 다운로드 → 로컬 저장
    func downloadPDF(shortURL: String, to destination: URL, progress: @escaping @Sendable (Double) -> Void) async throws {
        let pdfURL = try await resolvePDFURL(from: shortURL)
        try await downloadFile(from: pdfURL, to: destination, progress: progress)
    }

    // q.mirae-n.com 단축 URL → Location 헤더 raw 값 캡처 → file= 파라미터 추출
    private func resolvePDFURL(from shortURLString: String) async throws -> URL {
        guard let shortURL = URL(string: shortURLString) else {
            throw DownloadError.invalidURL(shortURLString)
        }

        let capturer = RedirectCapturer()
        let session = URLSession(configuration: .ephemeral, delegate: capturer, delegateQueue: nil)
        defer { session.invalidateAndCancel() }

        var request = URLRequest(url: shortURL)
        request.timeoutInterval = 15
        _ = try? await session.data(for: request) // 리다이렉트 중단 시 에러 무시

        guard let rawLocation = capturer.rawLocation else {
            throw DownloadError.noRedirect
        }

        // rawLocation 예시:
        // https://viewer-cms.mirae-n.com/...?content_name=...
        //   &file=https://privw-cms.mirae-n.com/...pdf?token=JWT
        //   &thumbnail_url=...
        //
        // ⚠️ 핵심: file= 값이 이미 percent-encoded 상태 (한글 파일명 포함)
        // URLComponents.queryItems 로 파싱하면 자동 디코딩 → 한글/공백 포함 → URL() 생성 실패
        // → raw 문자열에서 직접 추출해 인코딩 유지

        guard let fileRange = rawLocation.range(of: "file=") else {
            throw DownloadError.pdfURLNotFound
        }
        var rawPDFURL = String(rawLocation[fileRange.upperBound...])

        // &thumbnail_url= 또는 &down_url= 이전까지가 PDF URL
        for delimiter in ["&thumbnail_url=", "&down_url="] {
            if let delimRange = rawPDFURL.range(of: delimiter) {
                rawPDFURL = String(rawPDFURL[..<delimRange.lowerBound])
                break
            }
        }

        guard !rawPDFURL.isEmpty, let pdfURL = URL(string: rawPDFURL) else {
            throw DownloadError.pdfURLNotFound
        }
        return pdfURL
    }

    // 파일 다운로드 + 진행률 보고 (URLSessionDownloadDelegate 사용)
    private func downloadFile(from url: URL, to destination: URL, progress: @escaping @Sendable (Double) -> Void) async throws {
        let delegate = DownloadProgressDelegate(progressHandler: progress)
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = 300
        let session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
        defer { session.finishTasksAndInvalidate() }

        let (tempURL, _) = try await session.download(from: url)

        let fm = FileManager.default
        if fm.fileExists(atPath: destination.path) {
            try fm.removeItem(at: destination)
        }
        try fm.moveItem(at: tempURL, to: destination)
    }

    // MARK: - Error

    enum DownloadError: LocalizedError {
        case invalidURL(String)
        case noRedirect
        case pdfURLNotFound

        var errorDescription: String? {
            switch self {
            case .invalidURL(let url): return "잘못된 URL: \(url)"
            case .noRedirect:          return "다운로드 링크를 가져오지 못했습니다. 네트워크를 확인해 주세요."
            case .pdfURLNotFound:      return "PDF 주소를 찾을 수 없습니다."
            }
        }
    }
}

// MARK: - Redirect Capturer

// URLSession delegate: 리다이렉트 발생 시 Location 헤더 raw 값을 캡처하고 리다이렉트 중단
private final class RedirectCapturer: NSObject, URLSessionTaskDelegate, Sendable {
    private let _rawLocation = OSAllocatedUnfairLock<String?>(initialState: nil)

    var rawLocation: String? { _rawLocation.withLock { $0 } }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        // response.allHeaderFields["Location"]: raw percent-encoded Location 헤더 값 유지
        // request.url?.absoluteString 은 URLSession이 이미 파싱/정규화한 값이라 디코딩될 수 있음
        let location = response.allHeaderFields["Location"] as? String
                    ?? request.url?.absoluteString
        _rawLocation.withLock { $0 = location }
        completionHandler(nil) // 리다이렉트 중단
    }
}

// MARK: - Download Progress Delegate

// URLSession delegate: PDF 다운로드 진행률을 메인 액터로 전달
private final class DownloadProgressDelegate: NSObject, URLSessionDownloadDelegate, @unchecked Sendable {
    private let progressHandler: @Sendable (Double) -> Void

    init(progressHandler: @escaping @Sendable (Double) -> Void) {
        self.progressHandler = progressHandler
        super.init()
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        // download(from:)의 async 반환이 임시 파일 수명을 관리하므로 여기서는 별도 처리 없음
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard totalBytesExpectedToWrite > 0 else { return }
        let value = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        let handler = progressHandler
        Task { @MainActor in handler(value) }
    }
}
