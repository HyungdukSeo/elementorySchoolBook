package com.hdseo.elementaryschoolbook.ui

import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import com.hdseo.elementaryschoolbook.data.Book
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PdfReaderScreen(
    book: Book,
    pdfFile: File,
    annotationFile: File,
    onClose: () -> Unit
) {
    var pages by remember { mutableStateOf<List<Bitmap>>(emptyList()) }
    var isLoading by remember { mutableStateOf(true) }
    var strokeColor by remember { mutableStateOf(Color.BLUE) }
    var strokeWidth by remember { mutableStateOf(4f) }
    var isEraserMode by remember { mutableStateOf(false) }
    var showToolMenu by remember { mutableStateOf(false) }
    val pageViews = remember { mutableListOf<PdfPageView>() }

    val context = LocalContext.current

    // PDF 렌더링
    LaunchedEffect(pdfFile) {
        isLoading = true
        pages = withContext(Dispatchers.IO) {
            renderPdfPages(pdfFile, context.resources.displayMetrics.widthPixels)
        }
        isLoading = false
    }

    // 저장 함수
    fun saveAll() {
        pageViews.getOrNull(0)?.saveAnnotation(annotationFile)
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(book.title, maxLines = 1) },
                navigationIcon = {
                    IconButton(onClick = { saveAll(); onClose() }) {
                        Icon(Icons.Default.Close, contentDescription = "닫기")
                    }
                },
                actions = {
                    // 실행 취소
                    IconButton(onClick = { pageViews.forEach { it.undo() } }) {
                        Icon(Icons.Default.Undo, contentDescription = "실행취소")
                    }
                    // 지우개
                    IconButton(onClick = { isEraserMode = !isEraserMode }) {
                        Icon(
                            if (isEraserMode) Icons.Default.EditOff else Icons.Default.Edit,
                            contentDescription = "지우개",
                            tint = if (isEraserMode) MaterialTheme.colorScheme.error
                            else MaterialTheme.colorScheme.onSurface
                        )
                    }
                    // 색상 선택
                    IconButton(onClick = { showToolMenu = true }) {
                        Icon(Icons.Default.Palette, contentDescription = "색상")
                    }
                    // 저장
                    IconButton(onClick = { saveAll() }) {
                        Icon(Icons.Default.Save, contentDescription = "저장")
                    }
                }
            )
        }
    ) { padding ->
        Box(Modifier.fillMaxSize().padding(padding)) {
            if (isLoading) {
                CircularProgressIndicator(Modifier.align(Alignment.Center))
            } else {
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(androidx.compose.ui.graphics.Color.DarkGray),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    itemsIndexed(pages) { index, bitmap ->
                        AndroidView(
                            factory = { ctx ->
                                PdfPageView(ctx).also { view ->
                                    view.pageBitmap = bitmap
                                    view.strokeColor = strokeColor
                                    view.strokeWidth = strokeWidth
                                    view.isEraserMode = isEraserMode
                                    if (index == 0) view.loadAnnotation(annotationFile)
                                    while (pageViews.size <= index) pageViews.add(view)
                                    pageViews[index] = view
                                }
                            },
                            update = { view ->
                                view.strokeColor = strokeColor
                                view.strokeWidth = strokeWidth
                                view.isEraserMode = isEraserMode
                            },
                            modifier = Modifier
                                .fillMaxWidth()
                                .aspectRatio(bitmap.width.toFloat() / bitmap.height)
                        )
                    }
                }
            }

            // 색상/굵기 팝업 메뉴
            if (showToolMenu) {
                ColorToolMenu(
                    currentColor = strokeColor,
                    currentWidth = strokeWidth,
                    onColorSelected = { strokeColor = it; showToolMenu = false },
                    onWidthSelected = { strokeWidth = it },
                    onDismiss = { showToolMenu = false }
                )
            }
        }
    }
}

@Composable
private fun ColorToolMenu(
    currentColor: Int,
    currentWidth: Float,
    onColorSelected: (Int) -> Unit,
    onWidthSelected: (Float) -> Unit,
    onDismiss: () -> Unit
) {
    val colors = listOf(
        Color.BLUE to "파랑",
        Color.RED to "빨강",
        Color.rgb(0, 150, 0) to "초록",
        Color.BLACK to "검정",
        Color.rgb(150, 0, 150) to "보라"
    )
    val widths = listOf(2f to "얇게", 4f to "보통", 8f to "굵게")

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("필기 도구") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Text("색상", style = MaterialTheme.typography.labelMedium)
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    colors.forEach { (color, name) ->
                        IconButton(onClick = { onColorSelected(color) }) {
                            Box(
                                Modifier
                                    .size(32.dp)
                                    .background(
                                        androidx.compose.ui.graphics.Color(color),
                                        shape = androidx.compose.foundation.shape.CircleShape
                                    )
                            )
                        }
                    }
                }
                Text("굵기", style = MaterialTheme.typography.labelMedium)
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    widths.forEach { (w, label) ->
                        FilterChip(
                            selected = currentWidth == w,
                            onClick = { onWidthSelected(w) },
                            label = { Text(label) }
                        )
                    }
                }
            }
        },
        confirmButton = {
            TextButton(onClick = onDismiss) { Text("닫기") }
        }
    )
}

private fun renderPdfPages(pdfFile: File, screenWidth: Int): List<Bitmap> {
    val bitmaps = mutableListOf<Bitmap>()
    val pfd = ParcelFileDescriptor.open(pdfFile, ParcelFileDescriptor.MODE_READ_ONLY)
    PdfRenderer(pfd).use { renderer ->
        for (i in 0 until renderer.pageCount) {
            renderer.openPage(i).use { page ->
                val scale = screenWidth.toFloat() / page.width
                val w = screenWidth
                val h = (page.height * scale).toInt()
                val bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
                bitmap.eraseColor(Color.WHITE)
                page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                bitmaps.add(bitmap)
            }
        }
    }
    pfd.close()
    return bitmaps
}
