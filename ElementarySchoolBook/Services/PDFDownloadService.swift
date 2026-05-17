import Foundation

actor PDFDownloadService {
    // 단축 URL → PDF 다운로드 → 로컬 저장
    func downloadPDF(shortURL: String, to destination: URL, progress: @escaping (Double) -> Void) async throws {
        let pdfURL = try await resolvePDFURL(from: shortURL)
        try await downloadFile(from: pdfURL, to: destination, progress: progress)
    }

    // q.mirae-n.com 단축 URL → 리다이렉트 → viewer URL에서 file= 파라미터 추출
    private func resolvePDFURL(from shortURLString: String) async throws -> URL {
        guard let shortURL = URL(string: shortURLString) else {
            throw DownloadError.invalidURL(shortURLString)
        }

        let capturer = RedirectCapturer()
        let session = URLSession(configuration: .default, delegate: capturer, delegateQueue: nil)

        var request = URLRequest(url: shortURL)
        request.timeoutInterval = 15
        _ = try? await session.data(for: request)

        guard let viewerURL = capturer.capturedURL else {
            throw DownloadError.noRedirect
        }

        // viewer URL: https://viewer-cms.mirae-n.com/...?file=https://privw-cms.mirae-n.com/.../xxx.pdf?token=...
        guard let components = URLComponents(url: viewerURL, resolvingAgainstBaseURL: false),
              let fileParam = components.queryItems?.first(where: { $0.name == "file" })?.value,
              let pdfURL = URL(string: fileParam) else {
            throw DownloadError.pdfURLNotFound
        }

        return pdfURL
    }

    private func downloadFile(from url: URL, to destination: URL, progress: @escaping (Double) -> Void) async throws {
        let (asyncBytes, response) = try await URLSession.shared.bytes(from: url)
        let totalBytes = (response as? HTTPURLResponse)?.expectedContentLength ?? -1

        var data = Data()
        data.reserveCapacity(totalBytes > 0 ? Int(totalBytes) : 10_000_000)

        for try await byte in asyncBytes {
            data.append(byte)
            if totalBytes > 0 {
                await MainActor.run { progress(Double(data.count) / Double(totalBytes)) }
            }
        }

        let fm = FileManager.default
        if fm.fileExists(atPath: destination.path) {
            try fm.removeItem(at: destination)
        }
        try data.write(to: destination, options: .atomic)
    }

    enum DownloadError: LocalizedError {
        case invalidURL(String)
        case noRedirect
        case pdfURLNotFound

        var errorDescription: String? {
            switch self {
            case .invalidURL(let url): return "잘못된 URL: \(url)"
            case .noRedirect:          return "다운로드 링크를 가져오지 못했습니다."
            case .pdfURLNotFound:      return "PDF 주소를 찾을 수 없습니다."
            }
        }
    }
}

// URLSession delegate: 첫 리다이렉트 URL을 캡처하고 리다이렉트 중단
private final class RedirectCapturer: NSObject, URLSessionTaskDelegate, Sendable {
    private let _capturedURL = OSAllocatedUnfairLock<URL?>(initialState: nil)

    var capturedURL: URL? { _capturedURL.withLock { $0 } }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        _capturedURL.withLock { $0 = request.url }
        completionHandler(nil) // 리다이렉트 중단
    }
}
