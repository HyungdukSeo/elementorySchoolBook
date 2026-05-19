package com.hdseo.elementaryschoolbook.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.hdseo.elementaryschoolbook.data.Book
import com.hdseo.elementaryschoolbook.data.BookCatalog
import com.hdseo.elementaryschoolbook.service.BookCatalogService
import com.hdseo.elementaryschoolbook.service.DongaCatalogService
import com.hdseo.elementaryschoolbook.service.PdfDownloadService
import com.hdseo.elementaryschoolbook.service.TsherpaCatalogService
import com.hdseo.elementaryschoolbook.service.VivasamCatalogService
import com.hdseo.elementaryschoolbook.service.YbmCatalogService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlinx.coroutines.launch

data class BookUiState(
    val books: List<Book> = BookCatalog.all,
    val downloadingIds: Set<String> = emptySet(),
    val downloadProgress: Map<String, Float> = emptyMap(),
    val isUpdatingCatalog: Boolean = false,
    val errorMessage: String? = null,
    val catalogMessage: String? = null,
    val useExternalViewer: Boolean = false,
    val selectedPublisher: String = "미래엔",
    val selectedGrade: Int = 3
)

class BookStoreViewModel(application: Application) : AndroidViewModel(application) {

    private val filesDir = application.filesDir
    private val prefs = application.getSharedPreferences("book_meta", 0)
    private val catalogService = BookCatalogService()
    private val tsherpaCatalogService = TsherpaCatalogService()
    private val vivasamCatalogService = VivasamCatalogService()
    private val dongaCatalogService = DongaCatalogService()
    private val ybmCatalogService = YbmCatalogService()
    private val downloadService = PdfDownloadService()
    private val json = Json { ignoreUnknownKeys = true }

    private val _uiState = MutableStateFlow(BookUiState())
    val uiState: StateFlow<BookUiState> = _uiState.asStateFlow()

    init {
        loadCatalog()
        loadMetadata()
        val external = prefs.getBoolean("use_external_viewer", false)
        val publisher = prefs.getString("selected_publisher", "미래엔") ?: "미래엔"
        val grade = prefs.getInt("selected_grade", 3)
        _uiState.update { it.copy(
            useExternalViewer = external,
            selectedPublisher = publisher,
            selectedGrade = grade
        ) }
    }

    fun setUseExternalViewer(use: Boolean) {
        prefs.edit().putBoolean("use_external_viewer", use).apply()
        _uiState.update { it.copy(useExternalViewer = use) }
    }

    fun setPublisher(publisher: String) {
        prefs.edit().putString("selected_publisher", publisher).apply()
        _uiState.update { it.copy(selectedPublisher = publisher) }
    }

    fun setGrade(grade: Int) {
        prefs.edit().putInt("selected_grade", grade).apply()
        _uiState.update { it.copy(selectedGrade = grade) }
    }

    fun updateSelectedPublisherCatalog() {
        val publisher = _uiState.value.selectedPublisher
        if (_uiState.value.isUpdatingCatalog) return

        viewModelScope.launch {
            _uiState.update { it.copy(isUpdatingCatalog = true) }
            try {
                val deletedIds = loadDeletedBookIds()
                val remoteBooks = when (publisher) {
                    "YBM" -> ybmCatalogService.fetchCatalogBooks()
                    else -> builtInPublisherBooks(publisher)
                }.filterNot { it.id in deletedIds }

                if (remoteBooks.isEmpty()) {
                    throw Exception("$publisher 도서 목록을 가져오지 못했습니다.")
                }

                val current = _uiState.value.books
                val merged = mergeCatalog(current, publisher, remoteBooks)
                val message = buildUpdateMessage(publisher, current, merged)
                saveCatalog(merged)
                _uiState.update { it.copy(books = merged, catalogMessage = message) }
            } catch (e: Exception) {
                _uiState.update { it.copy(errorMessage = e.message) }
            } finally {
                _uiState.update { it.copy(isUpdatingCatalog = false) }
            }
        }
    }

    // ── 다운로드

    fun download(book: Book) {
        if (book.id in _uiState.value.downloadingIds) return

        _uiState.update { it.copy(downloadingIds = it.downloadingIds + book.id) }

        viewModelScope.launch {
            try {
                when (book.publisher) {
                    "비상교육" -> {
                        // 비상교육: iBook ID → 페이지별 PDF 다운로드 → 병합
                        vivasamCatalogService.downloadAndMerge(
                            ibookId = book.viewPageId,
                            destination = book.pdfFile(filesDir)
                        ) { progress ->
                            _uiState.update { s ->
                                s.copy(downloadProgress = s.downloadProgress + (book.id to progress))
                            }
                        }
                    }
                    "동아출판" -> {
                        // 동아출판: dirCode|maxPage → 페이지별 JPG 다운로드 → 병합
                        val parts = book.viewPageId.split("|")
                        if (parts.size != 2) {
                            throw Exception("동아출판 데이터 형식 오류")
                        }
                        val dirCode = parts[0]
                        val maxPage = parts[1].toIntOrNull()
                            ?: throw Exception("동아출판 페이지 수 오류")

                        dongaCatalogService.downloadAndMerge(
                            dirCode = dirCode,
                            maxPage = maxPage,
                            destination = book.pdfFile(filesDir)
                        ) { progress ->
                            _uiState.update { s ->
                                s.copy(downloadProgress = s.downloadProgress + (book.id to progress))
                            }
                        }
                    }
                    "YBM" -> {
                        // YBM: 홍보관 자료 선택자 또는 contentId → PDF URL
                        val url = ybmCatalogService.resolvePdfUrl(book)
                        downloadService.downloadPdf(url, book.pdfFile(filesDir), isDirectUrl = true) { progress ->
                            _uiState.update { s ->
                                s.copy(downloadProgress = s.downloadProgress + (book.id to progress))
                            }
                        }
                    }
                    "천재교육" -> {
                        // 천재교육: filePath → streamdocs API → PDF URL
                        val url = tsherpaCatalogService.resolvePdfUrl(book.viewPageId)
                        downloadService.downloadPdf(url, book.pdfFile(filesDir), isDirectUrl = true) { progress ->
                            _uiState.update { s ->
                                s.copy(downloadProgress = s.downloadProgress + (book.id to progress))
                            }
                        }
                    }
                    "지학사", "아이스크림미디어" -> {
                        // 지학사·아이스크림: viewPageId 가 직접 PDF URL
                        downloadService.downloadPdf(book.viewPageId, book.pdfFile(filesDir), isDirectUrl = true) { progress ->
                            _uiState.update { s ->
                                s.copy(downloadProgress = s.downloadProgress + (book.id to progress))
                            }
                        }
                    }
                    else -> {
                        // 미래엔: 단축 URL → redirect → PDF URL
                        val url = catalogService.fetchShortUrl(book)
                        downloadService.downloadPdf(url, book.pdfFile(filesDir)) { progress ->
                            _uiState.update { s ->
                                s.copy(downloadProgress = s.downloadProgress + (book.id to progress))
                            }
                        }
                    }
                }
                updateLastDownloaded(book.id, System.currentTimeMillis())
            } catch (e: Exception) {
                _uiState.update { it.copy(errorMessage = e.message) }
            } finally {
                _uiState.update { s ->
                    s.copy(
                        downloadingIds = s.downloadingIds - book.id,
                        downloadProgress = s.downloadProgress - book.id
                    )
                }
            }
        }
    }

    fun delete(book: Book) {
        book.pdfFile(filesDir).delete()
        book.annotationFile(filesDir).delete()
        updateLastDownloaded(book.id, null)
        markBookDeleted(book.id)

        val updated = _uiState.value.books.filterNot { it.id == book.id }
        saveCatalog(updated)
        _uiState.update { it.copy(books = updated) }
    }

    fun clearError() = _uiState.update { it.copy(errorMessage = null) }
    fun clearCatalogMessage() = _uiState.update { it.copy(catalogMessage = null) }

    // ── 퍼시스턴스

    private fun loadMetadata() {
        val updated = _uiState.value.books.map { book ->
            val ts = prefs.getLong(book.id, -1L)
            if (ts != -1L) book.copy(lastDownloaded = ts) else book
        }
        _uiState.update { it.copy(books = updated) }
    }

    private fun loadCatalog() {
        val saved = prefs.getString("catalog_books_json", null) ?: return
        val books = runCatching { json.decodeFromString<List<Book>>(saved) }.getOrNull() ?: return
        _uiState.update { it.copy(books = books) }
    }

    private fun saveCatalog(books: List<Book>) {
        prefs.edit().putString("catalog_books_json", json.encodeToString(books)).apply()
    }

    private fun loadDeletedBookIds(): Set<String> =
        prefs.getStringSet("deleted_book_ids", emptySet()).orEmpty()

    private fun markBookDeleted(bookId: String) {
        val deletedIds = loadDeletedBookIds().toMutableSet()
        deletedIds += bookId
        prefs.edit().putStringSet("deleted_book_ids", deletedIds).apply()
    }

    private fun mergeCatalog(current: List<Book>, publisher: String, remote: List<Book>): List<Book> {
        val result = current.toMutableList()
        val remoteKeys = remote.map { it.catalogKey }.toSet()

        current.forEachIndexed { index, book ->
            if (book.publisher == publisher && book.catalogKey !in remoteKeys && !book.isArchived) {
                result[index] = book.copy(isArchived = true)
            }
        }

        remote.forEach { remoteBook ->
            val existingIndex = result.indexOfFirst {
                it.publisher == publisher &&
                    (it.catalogKey == remoteBook.catalogKey ||
                        (it.title == remoteBook.title && it.grade == remoteBook.grade && it.subject == remoteBook.subject))
            }

            if (existingIndex == -1) {
                result += remoteBook
                return@forEach
            }

            val existing = result[existingIndex]
            if (existing.viewPageId == remoteBook.viewPageId) {
                result[existingIndex] = existing.copy(
                    title = remoteBook.title,
                    linkTitle = remoteBook.linkTitle,
                    grade = remoteBook.grade,
                    subject = remoteBook.subject,
                    viewSection = remoteBook.viewSection,
                    publisher = remoteBook.publisher,
                    isArchived = false,
                    catalogKey = remoteBook.catalogKey
                )
            } else if (existing.viewPageId.contains("|")) {
                result[existingIndex] = existing.copy(
                    viewPageId = remoteBook.viewPageId,
                    catalogKey = remoteBook.catalogKey,
                    isArchived = false
                )
            } else {
                result[existingIndex] = existing.copy(isArchived = true)
                result += remoteBook.copy(id = uniqueBookId(result, remoteBook))
            }
        }

        return result.sortedWith(
            compareBy<Book> { it.publisher }
                .thenBy { it.grade }
                .thenBy { it.subject }
                .thenBy { it.title }
                .thenBy { it.isArchived }
        )
    }

    private fun builtInPublisherBooks(publisher: String): List<Book> =
        BookCatalog.all
            .filter { it.publisher == publisher }
            .map { it.copy(isArchived = false, catalogKey = it.catalogKey.ifBlank { it.id }) }

    private fun buildUpdateMessage(publisher: String, before: List<Book>, after: List<Book>): String {
        val beforePublisher = before.filter { it.publisher == publisher }
        val afterPublisher = after.filter { it.publisher == publisher }
        val beforeIds = beforePublisher.map { it.id }.toSet()
        val afterIds = afterPublisher.map { it.id }.toSet()
        val added = (afterIds - beforeIds).size
        val archived = afterPublisher.count { afterBook ->
            afterBook.isArchived && beforePublisher.none { it.id == afterBook.id && it.isArchived }
        }

        return when {
            added > 0 || archived > 0 ->
                "$publisher 도서 목록 업데이트 완료\n새 도서 $added개, 보관 처리 $archived개"
            else ->
                "$publisher 도서 목록이 최신 상태입니다."
        }
    }

    private fun uniqueBookId(existing: List<Book>, book: Book): String {
        if (existing.none { it.id == book.id }) return book.id

        val suffix = book.viewPageId.hashCode().toUInt().toString(16)
        val candidate = "${book.id}-$suffix"
        if (existing.none { it.id == candidate }) return candidate

        var index = 2
        while (existing.any { it.id == "$candidate-$index" }) {
            index += 1
        }
        return "$candidate-$index"
    }

    private fun updateLastDownloaded(bookId: String, timestamp: Long?) {
        if (timestamp != null) prefs.edit().putLong(bookId, timestamp).apply()
        else prefs.edit().remove(bookId).apply()

        _uiState.update { state ->
            state.copy(books = state.books.map { b ->
                if (b.id == bookId) b.copy(lastDownloaded = timestamp) else b
            })
        }
    }

    // 다운로드 완료 여부 (실시간)
    fun isDownloaded(book: Book) = book.pdfFile(filesDir).exists()
    fun pdfFile(book: Book) = book.pdfFile(filesDir)
    fun annotationFile(book: Book) = book.annotationFile(filesDir)
}
