package com.hdseo.elementaryschoolbook.ui

import android.graphics.Bitmap
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.rememberTransformableState
import androidx.compose.foundation.gestures.transformable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.PointerType
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import com.hdseo.elementaryschoolbook.data.Book
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

import androidx.activity.compose.BackHandler

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PdfReaderScreen(
    book: Book,
    pdfFile: File,
    annotationFile: File,
    onClose: () -> Unit
) {
    // 시스템 뒤로가기 버튼 처리
    BackHandler {
        onClose()
    }

    var pageCount by remember { mutableIntStateOf(0) }
    var isLoading by remember { mutableStateOf(true) }
    var strokeColor by remember { mutableIntStateOf(android.graphics.Color.BLUE) }
    var strokeWidth by remember { mutableStateOf(4f) }
    var isEraserMode by remember { mutableStateOf(false) }
    var showToolMenu by remember { mutableStateOf(false) }
    
    // 줌 상태 관리
    var scale by remember { mutableStateOf(1f) }
    var offset by remember { mutableStateOf(androidx.compose.ui.geometry.Offset.Zero) }
    val state = rememberTransformableState { zoomChange, offsetChange, _ ->
        scale = (scale * zoomChange).coerceIn(1f, 5f)
        offset += offsetChange
    }

    val pageViews = remember { mutableStateMapOf<Int, PdfPageView>() }
    val context = LocalContext.current
    val screenWidth = context.resources.displayMetrics.widthPixels

    LaunchedEffect(pdfFile) {
        isLoading = true
        withContext(Dispatchers.IO) {
            try {
                ParcelFileDescriptor.open(pdfFile, ParcelFileDescriptor.MODE_READ_ONLY).use { pfd ->
                    PdfRenderer(pfd).use { renderer ->
                        pageCount = renderer.pageCount
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        isLoading = false
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(book.title, maxLines = 1) },
                navigationIcon = {
                    IconButton(onClick = { onClose() }) {
                        Icon(Icons.Default.Close, contentDescription = "닫기")
                    }
                },
                actions = {
                    IconButton(onClick = { pageViews.values.forEach { it.undo() } }) {
                        Icon(Icons.Default.Undo, contentDescription = "실행취소")
                    }
                    IconButton(onClick = { isEraserMode = !isEraserMode }) {
                        if (isEraserMode) {
                            Icon(Icons.Default.AutoFixNormal, "지우개", tint = MaterialTheme.colorScheme.primary)
                        } else {
                            Icon(Icons.Default.Edit, "펜", tint = MaterialTheme.colorScheme.onSurface)
                        }
                    }
                    IconButton(onClick = { showToolMenu = true }) {
                        Icon(Icons.Default.Palette, contentDescription = "색상")
                    }
                }
            )
        }
    ) { padding ->
        Box(
            Modifier
                .fillMaxSize()
                .padding(padding)
                .transformable(state = state)
        ) {
            if (isLoading) {
                CircularProgressIndicator(Modifier.align(Alignment.Center))
            } else {
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(Color.DarkGray)
                        .graphicsLayer(
                            scaleX = scale,
                            scaleY = scale,
                            translationX = offset.x,
                            translationY = offset.y
                        ),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    items(pageCount) { index ->
                        PdfPageItem(
                            pdfFile = pdfFile,
                            index = index,
                            screenWidth = screenWidth,
                            strokeColor = strokeColor,
                            strokeWidth = strokeWidth,
                            isEraserMode = isEraserMode,
                            annotationFile = if (index == 0) annotationFile else null,
                            onViewCreated = { view -> 
                                view.onDrawingChanged = {
                                    if (index == 0) view.saveAnnotation(annotationFile)
                                }
                                pageViews[index] = view 
                            },
                            onViewDisposed = { pageViews.remove(index) }
                        )
                    }
                }
            }

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
private fun PdfPageItem(
    pdfFile: File,
    index: Int,
    screenWidth: Int,
    strokeColor: Int,
    strokeWidth: Float,
    isEraserMode: Boolean,
    annotationFile: File?,
    onViewCreated: (PdfPageView) -> Unit,
    onViewDisposed: () -> Unit
) {
    var bitmap by remember { mutableStateOf<Bitmap?>(null) }
    var pdfPageView by remember { mutableStateOf<PdfPageView?>(null) }

    LaunchedEffect(pdfFile, index) {
        bitmap = withContext(Dispatchers.IO) {
            renderSinglePage(pdfFile, index, screenWidth)
        }
    }

    DisposableEffect(index) {
        onDispose {
            onViewDisposed()
            bitmap = null
            pdfPageView = null
        }
    }

    if (bitmap != null) {
        val b = bitmap!!
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .aspectRatio(b.width.toFloat() / b.height)
                .pointerInput(isEraserMode, strokeColor, strokeWidth) {
                    awaitPointerEventScope {
                        while (true) {
                            val event = awaitPointerEvent()
                            val change = event.changes.first()
                            if (change.type == PointerType.Stylus) {
                                val position = change.position
                                if (change.pressed) {
                                    if (change.previousPressed.not()) {
                                        pdfPageView?.handleActionDown(position.x, position.y)
                                    } else {
                                        pdfPageView?.handleActionMove(position.x, position.y)
                                    }
                                    change.consume()
                                } else {
                                    if (change.previousPressed) {
                                        pdfPageView?.handleActionUp()
                                        change.consume()
                                    }
                                }
                            }
                        }
                    }
                }
        ) {
            AndroidView(
                factory = { ctx ->
                    PdfPageView(ctx).also { view ->
                        view.pageBitmap = b
                        view.strokeColor = strokeColor
                        view.strokeWidth = strokeWidth
                        view.isEraserMode = isEraserMode
                        annotationFile?.let { view.loadAnnotation(it) }
                        pdfPageView = view
                        onViewCreated(view)
                    }
                },
                update = { view ->
                    view.strokeColor = strokeColor
                    view.strokeWidth = strokeWidth
                    view.isEraserMode = isEraserMode
                    pdfPageView = view
                },
                modifier = Modifier.fillMaxSize()
            )
        }
    } else {
        Box(
            modifier = Modifier.fillMaxWidth().aspectRatio(0.7f).background(Color.White),
            contentAlignment = Alignment.Center
        ) {
            CircularProgressIndicator()
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ColorToolMenu(
    currentColor: Int, // 현재 미사용 중이나 매개변수 유지
    currentWidth: Float,
    onColorSelected: (Int) -> Unit,
    onWidthSelected: (Float) -> Unit,
    onDismiss: () -> Unit
) {
    val _unused = currentColor
    val colors = listOf(
        android.graphics.Color.BLUE to "파랑",
        android.graphics.Color.RED to "빨강",
        android.graphics.Color.rgb(0, 150, 0) to "초록",
        android.graphics.Color.BLACK to "검정",
        android.graphics.Color.rgb(150, 0, 150) to "보라"
    )
    val widths = listOf(2f to "얇게", 4f to "보통", 8f to "굵게")

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("필기 도구") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Text("색상", style = MaterialTheme.typography.labelMedium)
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    colors.forEach { (color, _) ->
                        IconButton(onClick = { onColorSelected(color) }) {
                            Box(
                                Modifier.size(32.dp).background(
                                    Color(color),
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

private fun renderSinglePage(pdfFile: File, pageIndex: Int, screenWidth: Int): Bitmap? {
    return try {
        ParcelFileDescriptor.open(pdfFile, ParcelFileDescriptor.MODE_READ_ONLY).use { pfd ->
            PdfRenderer(pfd).use { renderer ->
                if (pageIndex >= renderer.pageCount) return null
                renderer.openPage(pageIndex).use { page ->
                    val scale = screenWidth.toFloat() / page.width
                    val w = screenWidth
                    val h = (page.height * scale).toInt()
                    val bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
                    bitmap.eraseColor(android.graphics.Color.WHITE)
                    page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                    bitmap
                }
            }
        }
    } catch (e: Exception) {
        e.printStackTrace()
        null
    }
}
