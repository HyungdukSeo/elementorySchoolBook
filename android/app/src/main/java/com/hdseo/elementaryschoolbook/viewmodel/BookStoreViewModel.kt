package com.hdseo.elementaryschoolbook.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.hdseo.elementaryschoolbook.data.Book
import com.hdseo.elementaryschoolbook.data.BookCatalog
import com.hdseo.elementaryschoolbook.service.BookCatalogService
import com.hdseo.elementaryschoolbook.service.PdfDownloadService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

data class BookUiState(
    val books: List<Book> = BookCatalog.all,
    val downloadingIds: Set<String> = emptySet(),
    val downloadProgress: Map<String, Float> = emptyMap(),
    val errorMessage: String? = null
)

class BookStoreViewModel(application: Application) : AndroidViewModel(application) {

    private val filesDir = application.filesDir
    private val prefs = application.getSharedPreferences("book_meta", 0)
    private val catalogService = BookCatalogService()
    private val downloadService = PdfDownloadService()

    private val _uiState = MutableStateFlow(BookUiState())
    val uiState: StateFlow<BookUiState> = _uiState.asStateFlow()

    init {
        loadMetadata()
    }

    // ── 다운로드

    fun download(book: Book) {
        if (book.id in _uiState.value.downloadingIds) return

        _uiState.update { it.copy(downloadingIds = it.downloadingIds + book.id) }

        viewModelScope.launch {
            try {
                val shortUrl = catalogService.fetchShortUrl(book)
                downloadService.downloadPdf(shortUrl, book.pdfFile(filesDir)) { progress ->
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
