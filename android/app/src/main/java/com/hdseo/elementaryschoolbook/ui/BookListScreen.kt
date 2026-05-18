package com.hdseo.elementaryschoolbook.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.hdseo.elementaryschoolbook.data.Book
import com.hdseo.elementaryschoolbook.viewmodel.BookStoreViewModel
import java.text.SimpleDateFormat
import java.util.*

@Composable
fun BookListScreen(viewModel: BookStoreViewModel) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    var selectedGrade by remember { mutableIntStateOf(3) }
    var openBook by remember { mutableStateOf<Book?>(null) }

    val books = state.books.filter { it.grade == selectedGrade }

    // 오류 다이얼로그
    state.errorMessage?.let { msg ->
        AlertDialog(
            onDismissRequest = viewModel::clearError,
            title = { Text("오류") },
            text = { Text(msg) },
            confirmButton = { TextButton(onClick = viewModel::clearError) { Text("확인") } }
        )
    }

    // PDF 리더
    openBook?.let { book ->
        PdfReaderScreen(
            book = book,
            pdfFile = viewModel.pdfFile(book),
            annotationFile = viewModel.annotationFile(book),
            onClose = { openBook = null }
        )
        return
    }

    Scaffold(
        topBar = {
            @OptIn(ExperimentalMaterial3Api::class)
            TopAppBar(title = { Text("초등 교과서") })
        }
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding)) {
            // 학년 탭
            TabRow(selectedTabIndex = selectedGrade - 3) {
                (3..6).forEach { grade ->
                    Tab(
                        selected = selectedGrade == grade,
                        onClick = { selectedGrade = grade },
                        text = { Text("${grade}학년") }
                    )
                }
            }

            LazyVerticalGrid(
                columns = GridCells.Adaptive(minSize = 160.dp),
                contentPadding = PaddingValues(12.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier.fillMaxSize()
            ) {
                items(books, key = { it.id }) { book ->
                    BookCard(
                        book = book,
                        isDownloaded = viewModel.isDownloaded(book),
                        isDownloading = book.id in state.downloadingIds,
                        progress = state.downloadProgress[book.id] ?: 0f,
                        onDownload = { viewModel.download(book) },
                        onOpen = { openBook = book }
                    )
                }
            }
        }
    }
}

@Composable
fun BookCard(
    book: Book,
    isDownloaded: Boolean,
    isDownloading: Boolean,
    progress: Float,
    onDownload: () -> Unit,
    onOpen: () -> Unit
) {
    val color = subjectColor(book.subject)

    Card(
        shape = RoundedCornerShape(12.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 3.dp),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column {
            // 표지
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(140.dp)
                    .background(
                        Brush.linearGradient(listOf(color, color.copy(alpha = 0.7f)))
                    ),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(
                        subjectIcon(book.subject),
                        contentDescription = null,
                        tint = Color.White.copy(alpha = 0.9f),
                        modifier = Modifier.size(40.dp)
                    )
                    Spacer(Modifier.height(4.dp))
                    Text(
                        book.title,
                        color = Color.White,
                        fontWeight = FontWeight.Bold,
                        textAlign = TextAlign.Center,
                        style = MaterialTheme.typography.bodyMedium
                    )
                    book.supplementLabel?.let { label ->
                        Spacer(Modifier.height(2.dp))
                        Surface(
                            color = Color.White.copy(alpha = 0.25f),
                            shape = RoundedCornerShape(50)
                        ) {
                            Text(
                                label,
                                color = Color.White,
                                style = MaterialTheme.typography.labelSmall,
                                modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                            )
                        }
                    }
                }

                // 다운로드 중 오버레이
                if (isDownloading) {
                    Box(
                        Modifier
                            .fillMaxSize()
                            .background(Color.Black.copy(alpha = 0.45f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            LinearProgressIndicator(
                                progress = { progress },
                                color = Color.White,
                                trackColor = Color.White.copy(alpha = 0.3f),
                                modifier = Modifier
                                    .fillMaxWidth(0.75f)
                                    .padding(bottom = 4.dp)
                            )
                            Text(
                                "${(progress * 100).toInt()}%",
                                color = Color.White,
                                fontWeight = FontWeight.Bold,
                                style = MaterialTheme.typography.bodySmall
                            )
                        }
                    }
                }
            }

            // 버튼 영역
            Column(
                Modifier.padding(8.dp),
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                if (isDownloaded) {
                    Button(
                        onClick = onOpen,
                        modifier = Modifier.fillMaxWidth(),
                        colors = ButtonDefaults.buttonColors(containerColor = color)
                    ) {
                        Icon(Icons.Default.MenuBook, null, Modifier.size(16.dp))
                        Spacer(Modifier.width(4.dp))
                        Text("열기")
                    }
                    OutlinedButton(
                        onClick = onDownload,
                        enabled = !isDownloading,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Icon(Icons.Default.Refresh, null, Modifier.size(14.dp))
                        Spacer(Modifier.width(4.dp))
                        Text("업데이트", style = MaterialTheme.typography.bodySmall)
                    }
                    book.lastDownloaded?.let { ts ->
                        Text(
                            SimpleDateFormat("yy.MM.dd", Locale.getDefault()).format(Date(ts)),
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.outline,
                            modifier = Modifier.align(Alignment.CenterHorizontally)
                        )
                    }
                } else {
                    Button(
                        onClick = onDownload,
                        enabled = !isDownloading,
                        modifier = Modifier.fillMaxWidth(),
                        colors = ButtonDefaults.buttonColors(containerColor = color)
                    ) {
                        Icon(Icons.Default.Download, null, Modifier.size(16.dp))
                        Spacer(Modifier.width(4.dp))
                        Text("다운로드")
                    }
                }
            }
        }
    }
}

private fun subjectColor(subject: String): Color = when (subject) {
    "수학"    -> Color(0xFF1565C0)
    "수학익힘" -> Color(0xFF0097A7)
    "사회"    -> Color(0xFFE65100)
    "과학"    -> Color(0xFF2E7D32)
    "실험관찰" -> Color(0xFF00695C)
    "영어"    -> Color(0xFF6A1B9A)
    "미술"    -> Color(0xFFAD1457)
    "음악"    -> Color(0xFF283593)
    "체육"    -> Color(0xFFC62828)
    "실과"    -> Color(0xFF4E342E)
    else     -> Color(0xFF546E7A)
}

private fun subjectIcon(subject: String): ImageVector = when (subject) {
    "수학", "수학익힘" -> Icons.Default.Calculate
    "사회"           -> Icons.Default.Public
    "과학", "실험관찰" -> Icons.Default.Science
    "영어"           -> Icons.Default.Translate
    "미술"           -> Icons.Default.Palette
    "음악"           -> Icons.Default.MusicNote
    "체육"           -> Icons.Default.DirectionsRun
    "실과"           -> Icons.Default.Build
    else            -> Icons.Default.Book
}
