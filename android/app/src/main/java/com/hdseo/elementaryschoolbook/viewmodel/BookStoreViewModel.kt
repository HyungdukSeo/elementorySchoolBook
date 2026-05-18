package com.hdseo.elementaryschoolbook.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.hdseo.elementaryschoolbook.data.Book
import com.hdseo.elementaryschoolbook.data.BookCatalog
import com.hdseo.elementaryschoolbook.service.BookCatalogService
import com.hdseo.elementaryschoolbook.service.PdfDownloadService
import com.hdseo.elementaryschoolbook.service.TsherpaCatalogService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class BookUiState(
    val books: List<Book> = BookCatalog.all,
    val downloadingIds: Set<String> = emptySet(),
    val downloadProgress: Map<String, Float> = emptyMap(),
    val errorMessage: String? = null,
    val useExternalViewer: Boolean = false,
    val selectedPublisher: String = "미래엔",
    val selectedGrade: Int = 3
)

class BookStoreViewModel(application: Application) : AndroidViewModel(application) {

    private val filesDir = application.filesDir
    private val prefs = application.getSharedPreferences("book_meta", 0)
    private val catalogService = BookCatalogService()
    private val tsherpaCatalogService = TsherpaCatalogService()
    private val downloadService = PdfDownloadService()

    private val _uiState = MutableStateFlow(BookUiState())
    val uiState: StateFlow<BookUiState> = _uiState.asStateFlow()

    init {
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

    // ── 다운로드

    fun download(book: Book) {
        if (book.id in _uiState.value.downloadingIds) return

        _uiState.update { it.copy(downloadingIds = it.downloadingIds + book.id) }

        viewModelScope.launch {
            try {
                val url = if (book.publisher == "천재교육") {
                    // 천재교육: filePath → streamdocs API → PDF URL
                    tsherpaCatalogService.resolvePdfUrl(book.viewPageId)
                } else {
                    // 미래엔: 단축 URL → redirect → PDF URL
                    catalogService.fetchShortUrl(book)
                }
                val isDirectUrl = book.publisher == "천재교육"

                downloadService.downloadPdf(url, book.pdfFile(filesDir), isDirectUrl) { progress ->
                    _uiState.update { s ->
                        s.copy(downloadProgress = s.downloadProgress + (book.id to progress))
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
    }

    fun clearError() = _uiState.update { it.copy(errorMessage = null) }

    // ── 퍼시스턴스

    private fun loadMetadata() {
        val updated = _uiState.value.books.map { book ->
            val ts = prefs.getLong(book.id, -1L)
            if (ts != -1L) book.copy(lastDownloaded = ts) else book
        }
        _uiState.update { it.copy(books = updated) }
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
