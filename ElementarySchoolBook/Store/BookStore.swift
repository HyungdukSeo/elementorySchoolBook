import Foundation

@MainActor
final class BookStore: ObservableObject {
    @Published var books: [Book] = BookCatalog.all
    @Published var downloadProgress: [String: Double] = [:]  // bookID → 0~1
    @Published var downloadingIDs: Set<String> = []
    @Published var errorMessage: String?

    private let catalogService = BookCatalogService()
    private let downloadService = PDFDownloadService()
    private let metaKey = "booksMeta"

    // MARK: - 다운로드

    func download(_ book: Book) {
        guard !downloadingIDs.contains(book.id) else { return }
        downloadingIDs.insert(book.id)
        downloadProgress[book.id] = 0

        Task {
            do {
                let shortURL = try await catalogService.fetchShortURL(for: book)
                try await downloadService.downloadPDF(shortURL: shortURL, to: book.localPDFPath) { [weak self] p in
                    Task { @MainActor in self?.downloadProgress[book.id] = p }
                }
                updateDownloadDate(for: book.id)
            } catch {
                errorMessage = error.localizedDescription
            }
            downloadingIDs.remove(book.id)
            downloadProgress.removeValue(forKey: book.id)
        }
    }

    func delete(_ book: Book) {
        try? FileManager.default.removeItem(at: book.localPDFPath)
        try? FileManager.default.removeItem(at: book.annotationPath)
        updateDownloadDate(for: book.id, date: nil)
    }

    // MARK: - 퍼시스턴스

    func loadMetadata() {
        guard let data = UserDefaults.standard.data(forKey: metaKey),
              let meta = try? JSONDecoder().decode([String: Date?].self, from: data) else { return }
        books = books.map { book in
            var b = book
            b.lastDownloaded = meta[book.id] ?? nil
            return b
        }
    }

    private func updateDownloadDate(for bookID: String, date: Date? = Date()) {
        if let idx = books.firstIndex(where: { $0.id == bookID }) {
            books[idx].lastDownloaded = date
        }
        saveMetadata()
    }

    private func saveMetadata() {
        let meta = Dictionary(uniqueKeysWithValues: books.map { ($0.id, $0.lastDownloaded) })
        if let data = try? JSONEncoder().encode(meta) {
            UserDefaults.standard.set(data, forKey: metaKey)
        }
    }
}
