package com.hdseo.elementaryschoolbook.ui

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.DirectionsRun
import androidx.compose.material.icons.automirrored.filled.MenuBook
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.core.content.FileProvider
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.hdseo.elementaryschoolbook.data.Book
import com.hdseo.elementaryschoolbook.viewmodel.BookStoreViewModel
import java.text.SimpleDateFormat
import java.util.*

@Composable
fun BookListScreen(viewModel: BookStoreViewModel) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    val context = LocalContext.current

    val publishers = listOf("미래엔", "천재교육", "비상교육", "동아출판", "YBM", "지학사", "아이스크림미디어")
    val books = state.books.filter { 
        it.publisher == state.selectedPublisher && it.grade == state.selectedGrade 
    }

    // 오류 다이얼로그
    state.errorMessage?.let { msg ->
        AlertDialog(
            onDismissRequest = viewModel::clearError,
            title = { Text("오류") },
            text = { Text(msg) },
            confirmButton = { TextButton(onClick = viewModel::clearError) { Text("확인") } }
        )
    }

    state.catalogMessage?.let { msg ->
        AlertDialog(
            onDismissRequest = viewModel::clearCatalogMessage,
            title = { Text("도서 목록 업데이트") },
            text = { Text(msg) },
            confirmButton = {
                TextButton(onClick = viewModel::clearCatalogMessage) { Text("확인") }
            }
        )
    }

    // 내장 PDF 리더 표시
    state.openBook?.let { book ->
        PdfReaderScreen(
            book = book,
            pdfFile = viewModel.pdfFile(book),
            annotationFile = viewModel.annotationFile(book),
            onClose = { viewModel.setOpenBook(null) }
        )
        return
    }

    Scaffold(
        topBar = {
            @OptIn(ExperimentalMaterial3Api::class)
            TopAppBar(
                title = { Text("초등 교과서") },
                actions = {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier.padding(end = 12.dp)
                    ) {
                        Text(
                            if (state.useExternalViewer) "외장 앱" else "내장 앱",
                            style = MaterialTheme.typography.labelMedium
                        )
                        Spacer(Modifier.width(8.dp))
                        Switch(
                            checked = state.useExternalViewer,
                            onCheckedChange = { viewModel.setUseExternalViewer(it) }
                        )
                    }
                }
            )
        }
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding)) {
            // 출판사 탭
            ScrollableTabRow(
                selectedTabIndex = publishers.indexOf(state.selectedPublisher),
                edgePadding = 8.dp
            ) {
                publishers.forEach { pub ->
                    Tab(
                        selected = state.selectedPublisher == pub,
                        onClick = { viewModel.setPublisher(pub) },
                        text = { Text(pub) }
                    )
                }
            }

            // 학년 탭
            TabRow(
                selectedTabIndex = state.selectedGrade - 3,
                containerColor = MaterialTheme.colorScheme.surfaceVariant,
                contentColor = MaterialTheme.colorScheme.onSurfaceVariant
            ) {
                (3..6).forEach { grade ->
                    Tab(
                        selected = state.selectedGrade == grade,
                        onClick = { viewModel.setGrade(grade) },
                        text = { Text("${grade}학년") }
                    )
                }
            }

            OutlinedButton(
                onClick = { viewModel.updateSelectedPublisherCatalog() },
                enabled = !state.isUpdatingCatalog,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 12.dp, vertical = 8.dp)
            ) {
                if (state.isUpdatingCatalog) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(16.dp),
                        strokeWidth = 2.dp
                    )
                } else {
                    Icon(Icons.Default.Sync, null, Modifier.size(16.dp))
                }
                Spacer(Modifier.width(6.dp))
                Text("${state.selectedPublisher} 도서 목록 업데이트")
            }

            if (books.isEmpty()) {
                Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Text("해당 출판사의 교과서 목록이 아직 준비되지 않았습니다.", color = Color.Gray)
                }
            } else {
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
                            onDelete = { viewModel.delete(book) },
                            onOpen = {
                                if (state.useExternalViewer) {
                                    val pdfFile = viewModel.pdfFile(book)
                                    if (pdfFile.exists()) {
                                        try {
                                            val uri = FileProvider.getUriForFile(
                                                context,
                                                "${context.packageName}.fileprovider",
                                                pdfFile
                                            )
                                            val intent = Intent(Intent.ACTION_VIEW).apply {
                                                setDataAndType(uri, "application/pdf")
                                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                            }
                                            context.startActivity(intent)
                                        } catch (e: Exception) {
                                            viewModel.setOpenBook(book)
                                        }
                                    }
                                } else {
                                    viewModel.setOpenBook(book)
                                }
                            }
                        )
                    }
                }
            }
        }
    }
}

@Composable
@OptIn(ExperimentalFoundationApi::class)
fun BookCard(
    book: Book,
    isDownloaded: Boolean,
    isDownloading: Boolean,
    progress: Float,
    onDownload: () -> Unit,
    onOpen: () -> Unit,
    onDelete: () -> Unit,
    canDelete: Boolean = true,
    isWebOnly: Boolean = false
) {
    val color = if (book.isArchived) Color(0xFF8A8F98) else subjectColor(book.subject)
    var showMenu by remember { mutableStateOf(false) }
    var showDeleteConfirm by remember { mutableStateOf(false) }

    if (showDeleteConfirm) {
        AlertDialog(
            onDismissRequest = { showDeleteConfirm = false },
            title = { Text("도서 삭제") },
            text = { Text("목록과 저장된 PDF, 필기 데이터를 삭제할까요?") },
            confirmButton = {
                TextButton(onClick = {
                    showDeleteConfirm = false
                    onDelete()
                }) { Text("삭제") }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteConfirm = false }) { Text("취소") }
            }
        )
    }

    Card(
        shape = RoundedCornerShape(12.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 3.dp),
        modifier = Modifier
            .fillMaxWidth()
            .combinedClickable(
                onClick = {},
                onLongClick = { if (canDelete) showMenu = true }
            )
    ) {
        Column {
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
                        style = MaterialTheme.typography.bodyMedium,
                        modifier = Modifier.padding(horizontal = 8.dp)
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
                    if (book.isArchived) {
                        Spacer(Modifier.height(4.dp))
                        Surface(
                            color = Color.Black.copy(alpha = 0.22f),
                            shape = RoundedCornerShape(50)
                        ) {
                            Text(
                                "보관됨",
                                color = Color.White,
                                style = MaterialTheme.typography.labelSmall,
                                modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                            )
                        }
                    }
                }

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

            Column(
                Modifier.padding(8.dp),
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                if (canDelete && showMenu) {
                    DropdownMenu(
                        expanded = showMenu,
                        onDismissRequest = { showMenu = false }
                    ) {
                        DropdownMenuItem(
                            text = { Text("삭제") },
                            leadingIcon = { Icon(Icons.Default.Delete, null) },
                            onClick = {
                                showMenu = false
                                showDeleteConfirm = true
                            }
                        )
                    }
                }

                if (book.isArchived && !isDownloaded) {
                    OutlinedButton(
                        onClick = { if (canDelete) showDeleteConfirm = true },
                        enabled = canDelete,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Icon(
                            if (canDelete) Icons.Default.Delete else Icons.Default.Archive,
                            null,
                            Modifier.size(14.dp)
                        )
                        Spacer(Modifier.width(4.dp))
                        Text(
                            if (canDelete) "삭제" else "보관됨",
                            style = MaterialTheme.typography.bodySmall
                        )
                    }
                } else if (isWebOnly) {
                    Button(
                        onClick = onOpen,
                        modifier = Modifier.fillMaxWidth(),
                        colors = ButtonDefaults.buttonColors(containerColor = color)
                    ) {
                        Icon(Icons.Default.OpenInBrowser, null, Modifier.size(16.dp))
                        Spacer(Modifier.width(4.dp))
                        Text("웹 뷰어")
                    }
                } else if (isDownloaded) {
                    Button(
                        onClick = onOpen,
                        modifier = Modifier.fillMaxWidth(),
                        colors = ButtonDefaults.buttonColors(containerColor = color)
                    ) {
                        Icon(Icons.AutoMirrored.Filled.MenuBook, null, Modifier.size(16.dp))
                        Spacer(Modifier.width(4.dp))
                        Text("열기")
                    }
                    OutlinedButton(
                        onClick = onDownload,
                        enabled = !isDownloading && !book.isArchived,
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
    "사회과 부도" -> Color(0xFFEF6C00)
    "과학"    -> Color(0xFF2E7D32)
    "실험관찰" -> Color(0xFF00695C)
    "영어"    -> Color(0xFF6A1B9A)
    "미술"    -> Color(0xFFAD1457)
    "음악"    -> Color(0xFF283593)
    "체육"    -> Color(0xFFC62828)
    "실과"    -> Color(0xFF4E342E)
    "보건"    -> Color(0xFFD81B60)
    else     -> Color(0xFF546E7A)
}

private fun subjectIcon(subject: String): ImageVector = when (subject) {
    "수학", "수학익힘" -> Icons.Default.Calculate
    "사회", "사회과 부도" -> Icons.Default.Public
    "과학", "실험관찰" -> Icons.Default.Science
    "영어"           -> Icons.Default.Translate
    "미술"           -> Icons.Default.Palette
    "음악"           -> Icons.Default.MusicNote
    "체육"           -> Icons.AutoMirrored.Filled.DirectionsRun
    "실과"           -> Icons.Default.Build
    "보건"           -> Icons.Default.Favorite
    else            -> Icons.Default.Book
}
