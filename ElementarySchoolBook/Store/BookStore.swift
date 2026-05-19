import Foundation

@MainActor
final class BookStore: ObservableObject {
    @Published var books: [Book] = []
    @Published var downloadProgress: [String: Double] = [:]  // bookID → 0~1
    @Published var downloadingIDs: Set<String> = []
    @Published var errorMessage: String?
    @Published var catalogMessage: String?
    @Published var isUpdatingCatalog: Bool = false

    @Published var selectedPublisher: Publisher = .miraen {
        didSet { UserDefaults.standard.set(selectedPublisher.rawValue, forKey: publisherKey) }
    }
    @Published var selectedGrade: Int = 3 {
        didSet { UserDefaults.standard.set(selectedGrade, forKey: gradeKey) }
    }

    private let catalogService = BookCatalogService()
    private let tsherpaService = TsherpaCatalogService()
    private let ybmService = YbmCatalogService()
    private let visangService = VisangCatalogService()
    private let dongaService = DongaCatalogService()
    private let downloadService = PDFDownloadService()

    private let booksKey = "booksData_v2"
    private let publisherKey = "selectedPublisher"
    private let gradeKey = "selectedGrade"

    init() {
        if let raw = UserDefaults.standard.string(forKey: publisherKey),
           let pub = Publisher(rawValue: raw) {
            self.selectedPublisher = pub
        }
        let savedGrade = UserDefaults.standard.integer(forKey: gradeKey)
        if (3...6).contains(savedGrade) {
            self.selectedGrade = savedGrade
        }
        loadBooks()
    }

    // MARK: - 필터된 책 목록

    var filteredBooks: [Book] {
        books.filter { $0.publisher == selectedPublisher.rawValue && $0.grade == selectedGrade }
    }

    // MARK: - 다운로드

    func download(_ book: Book) {
        guard !downloadingIDs.contains(book.id) else { return }
        downloadingIDs.insert(book.id)
        downloadProgress[book.id] = 0

        Task {
            do {
                try await dispatchDownload(for: book)
                updateDownloadDate(for: book.id)
            } catch {
                errorMessage = error.localizedDescription
            }
            downloadingIDs.remove(book.id)
            downloadProgress.removeValue(forKey: book.id)
        }
    }

    private func dispatchDownload(for book: Book) async throws {
        let progressHandler: @Sendable (Double) -> Void = { [weak self] p in
            Task { @MainActor in self?.downloadProgress[book.id] = p }
        }

        switch book.publisherEnum ?? .miraen {
        case .miraen:
            let shortURL = try await catalogService.fetchShortURL(for: book)
            try await downloadService.downloadPDF(shortURL: shortURL, to: book.localPDFPath, progress: progressHandler)

        case .iscream, .jihaksa:
            try await downloadService.downloadDirectPDF(url: book.viewPageID, to: book.localPDFPath, progress: progressHandler)

        case .chunjae:
            let pdfURL = try await tsherpaService.resolvePDFURL(filePath: book.viewPageID)
            try await downloadService.downloadDirectPDF(url: pdfURL, to: book.localPDFPath, progress: progressHandler)

        case .ybm:
            let pdfURL = try await ybmService.resolvePDFURL(book: book)
            try await downloadService.downloadDirectPDF(url: pdfURL, to: book.localPDFPath, progress: progressHandler)

        case .visang:
            try await visangService.downloadAndMerge(ibookId: book.viewPageID, destination: book.localPDFPath, progress: progressHandler)

        case .donga:
            try await dongaService.downloadAndMerge(viewPageID: book.viewPageID, destination: book.localPDFPath, progress: progressHandler)
        }
    }

    /// 다운로드된 PDF 만 제거. 책은 목록에 남는다 (다시 다운로드 가능).
    func clearDownload(_ book: Book) {
        try? FileManager.default.removeItem(at: book.localPDFPath)
        try? FileManager.default.removeItem(at: book.annotationPath)
        updateDownloadDate(for: book.id, date: nil)
    }

    /// 책을 목록에서 완전히 제거. 동아·지학사는 정적 카탈로그라 막힘.
    func deleteBook(_ book: Book) {
        guard book.publisherEnum?.supportsCatalogUpdate == true else { return }
        try? FileManager.default.removeItem(at: book.localPDFPath)
        try? FileManager.default.removeItem(at: book.annotationPath)
        books.removeAll { $0.id == book.id }
        saveBooks()
    }

    // MARK: - 카탈로그 동적 업데이트 (동아·지학사 제외)

    func updateCurrentPublisherCatalog() {
        let publisher = selectedPublisher
        guard publisher.supportsCatalogUpdate, !isUpdatingCatalog else { return }
        isUpdatingCatalog = true

        Task {
            defer { isUpdatingCatalog = false }
            do {
                let fetched: [Book]
                switch publisher {
                case .ybm:
                    fetched = try await ybmService.fetchCatalogBooks()
                case .miraen:
                    fetched = BookCatalog.MiraeN.all
                case .chunjae:
                    fetched = BookCatalog.Chunjae.all
                case .visang:
                    fetched = BookCatalog.Visang.all
                case .iscream:
                    fetched = BookCatalog.IScream.all
                case .donga, .jihaksa:
                    return
                }
                let summary = mergeCatalog(fetched, for: publisher)
                catalogMessage = summary
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    /// 새 카탈로그 병합. 기존 메타데이터(lastDownloaded) 보존, 없어진 책은 isArchived.
    /// - returns: 사용자에게 보여 줄 요약 메시지
    @discardableResult
    private func mergeCatalog(_ newBooks: [Book], for publisher: Publisher) -> String {
        let publisherBooks = books.filter { $0.publisher == publisher.rawValue }

        // catalogKey 단위로 기존 책 인덱싱
        var oldByKey: [String: Book] = [:]
        for b in publisherBooks {
            oldByKey[b.catalogKey] = b
        }
        let newKeys = Set(newBooks.map(\.catalogKey))

        // 새 책: 기존 메타데이터(lastDownloaded, 다운로드된 파일 이전) 머지
        var merged: [Book] = []
        var added = 0
        for newBook in newBooks {
            var b = newBook
            if let old = oldByKey[b.catalogKey] {
                b.lastDownloaded = old.lastDownloaded
                b.isArchived = false
                // contentId 가 바뀐 경우 (id 가 다른 경우) 기존 PDF 이전
                if old.id != b.id {
                    let fm = FileManager.default
                    if fm.fileExists(atPath: old.localPDFPath.path) {
                        try? fm.moveItem(at: old.localPDFPath, to: b.localPDFPath)
                    }
                    if fm.fileExists(atPath: old.annotationPath.path) {
                        try? fm.moveItem(at: old.annotationPath, to: b.annotationPath)
                    }
                }
            } else {
                added += 1
            }
            merged.append(b)
        }

        // 기존에 있었는데 새 목록에서 빠진 책: 다운로드 이력 있으면 isArchived 로 유지, 없으면 정리
        var archivedCount = 0
        for old in publisherBooks where !newKeys.contains(old.catalogKey) {
            if old.isDownloaded || old.lastDownloaded != nil {
                var archived = old
                archived.isArchived = true
                merged.append(archived)
                archivedCount += 1
            }
        }

        books = books.filter { $0.publisher != publisher.rawValue } + merged
        saveBooks()

        if added == 0 && archivedCount == 0 {
            return "\(publisher.rawValue) 도서 목록은 이미 최신입니다."
        }
        var parts: [String] = []
        if added > 0 { parts.append("새 도서 \(added)권 추가") }
        if archivedCount > 0 { parts.append("\(archivedCount)권 보관함 이동") }
        return "\(publisher.rawValue): " + parts.joined(separator: ", ")
    }

    // MARK: - 퍼시스턴스

    private func loadBooks() {
        let staticBooks = BookCatalog.all

        if let data = UserDefaults.standard.data(forKey: booksKey),
           let saved = try? JSONDecoder().decode([Book].self, from: data), !saved.isEmpty {
            books = saved
            // 정적 카탈로그에 있는데 저장본에 없는 책 추가 (앱 업데이트로 새로 들어온 책)
            let savedKeys = Set(books.map(\.catalogKey))
            for sb in staticBooks where !savedKeys.contains(sb.catalogKey) {
                books.append(sb)
            }
            // 동아·지학사는 카탈로그가 정적이라 항상 전체가 있어야 함 — 누락 보강
            ensureStaticCompleteness(for: .donga, staticBooks: staticBooks)
            ensureStaticCompleteness(for: .jihaksa, staticBooks: staticBooks)
            saveBooks()
        } else {
            books = staticBooks
            saveBooks()
        }
    }

    private func ensureStaticCompleteness(for publisher: Publisher, staticBooks: [Book]) {
        let publisherStatic = staticBooks.filter { $0.publisher == publisher.rawValue }
        let existingIDs = Set(books.filter { $0.publisher == publisher.rawValue }.map(\.id))
        for sb in publisherStatic where !existingIDs.contains(sb.id) {
            books.append(sb)
        }
    }

    private func updateDownloadDate(for bookID: String, date: Date? = Date()) {
        if let idx = books.firstIndex(where: { $0.id == bookID }) {
            books[idx].lastDownloaded = date
        }
        saveBooks()
    }

    private func saveBooks() {
        if let data = try? JSONEncoder().encode(books) {
            UserDefaults.standard.set(data, forKey: booksKey)
        }
    }

    // 호환용 — ContentView 가 onAppear 에서 호출
    func loadMetadata() {}
}
