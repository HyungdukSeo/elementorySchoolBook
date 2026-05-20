package com.hdseo.elementaryschoolbook.ui

import android.graphics.Bitmap
import android.graphics.Matrix
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.rememberTransformableState
import androidx.compose.foundation.gestures.transformable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Undo
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import com.hdseo.elementaryschoolbook.data.Book
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import kotlin.math.roundToInt
import kotlin.math.sqrt

import androidx.activity.compose.BackHandler

private const val MIN_RENDER_SIZE = 64
private const val MAX_RENDER_DIMENSION = 2500
private const val MAX_RENDER_PIXELS = 8_000_000
private const val TALL_PAGE_ASPECT_THRESHOLD = 0.45f

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
    var showLoadComplete by remember { mutableStateOf(false) }
    var strokeColor by remember { mutableIntStateOf(android.graphics.Color.BLUE) }
    var strokeWidth by remember { mutableStateOf(4f) }
    var isEraserMode by remember { mutableStateOf(false) }
    var showToolMenu by remember { mutableStateOf(false) }

    val listState = rememberLazyListState()
    val coroutineScope = rememberCoroutineScope()

    // 줌 상태 관리
    var scale by remember { mutableStateOf(1f) }
    var offset by remember { mutableStateOf(androidx.compose.ui.geometry.Offset.Zero) }

    val context = LocalContext.current
    val density = context.resources.displayMetrics.density
    val screenWidth = context.resources.displayMetrics.widthPixels
    val screenHeight = context.resources.displayMetrics.heightPixels

    val sidebarWidthPx = (120 * density).toInt()

    val transformState = rememberTransformableState { zoomChange, offsetChange, _ ->
        val newScale = (scale * zoomChange).coerceIn(1f, 5f)
        scale = newScale

        if (newScale <= 1f) {
            offset = androidx.compose.ui.geometry.Offset.Zero
        } else {
            // 정확한 뷰어 영역 크기 계산 (가로/세로 전환 대응)
            val viewerWidth = (screenWidth - sidebarWidthPx).coerceAtLeast(1)
            val viewerHeight = screenHeight.coerceAtLeast(1)

            val maxOffsetX = (viewerWidth * (newScale - 1f)) / 2
            val maxOffsetY = (viewerHeight * (newScale - 1f)) / 2

            val newOffset = offset + offsetChange
            offset = androidx.compose.ui.geometry.Offset(
                x = newOffset.x.coerceIn(-maxOffsetX, maxOffsetX),
                y = newOffset.y.coerceIn(-maxOffsetY, maxOffsetY)
            )
        }
    }

    val pageViews = remember { mutableStateMapOf<Int, PdfPageView>() }

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
        showLoadComplete = true
    }

    LaunchedEffect(showLoadComplete) {
        if (showLoadComplete) {
            kotlinx.coroutines.delay(2000)
            showLoadComplete = false
        }
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
                        Icon(Icons.AutoMirrored.Filled.Undo, contentDescription = "실행취소")
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
        ) {
            if (isLoading) {
                CircularProgressIndicator(Modifier.align(Alignment.Center))
            } else {
                Row(Modifier.fillMaxSize()) {
                    // 왼쪽 썸네일 리스트
                    LazyColumn(
                        modifier = Modifier
                            .width(120.dp)
                            .fillMaxHeight()
                            .background(MaterialTheme.colorScheme.surfaceVariant),
                        contentPadding = PaddingValues(8.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        items(pageCount) { index ->
                            PdfThumbnailItem(
                                pdfFile = pdfFile,
                                index = index,
                                onClick = {
                                    coroutineScope.launch {
                                        listState.animateScrollToItem(index)
                                    }
                                }
                            )
                        }
                    }

                    // 메인 PDF 뷰어
                    BoxWithConstraints(
                        Modifier
                            .weight(1f)
                            .fillMaxHeight()
                            .clipToBounds()
                            .transformable(state = transformState)
                    ) {
                        val vWidthPx = constraints.maxWidth
                        val vHeightPx = constraints.maxHeight

                        LazyColumn(
                            state = listState,
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
                            items(pageCount, key = { it }) { index ->
                                val pageAnnotationFile = File(annotationFile.parent, "${book.id}_page_$index.json")
                                PdfPageItem(
                                    pdfFile = pdfFile,
                                    index = index,
                                    screenWidth = vWidthPx,
                                    screenHeight = vHeightPx,
                                    strokeColor = strokeColor,
                                    strokeWidth = strokeWidth,
                                    isEraserMode = isEraserMode,
                                    annotationFile = pageAnnotationFile,
                                    onViewCreated = { view ->
                                        view.onDrawingChanged = {
                                            view.saveAnnotation(pageAnnotationFile)
                                        }
                                        pageViews[index] = view
                                    },
                                    onViewDisposed = { pageViews.remove(index) }
                                )
                            }
                        }
                    }
                }
            }

            // 로딩 완료 팝업
            androidx.compose.animation.AnimatedVisibility(
                visible = showLoadComplete,
                enter = androidx.compose.animation.fadeIn(),
                exit = androidx.compose.animation.fadeOut(),
                modifier = Modifier.align(Alignment.BottomCenter).padding(bottom = 32.dp)
            ) {
                Surface(
                    color = MaterialTheme.colorScheme.secondaryContainer,
                    shape = RoundedCornerShape(24.dp),
                    tonalElevation = 4.dp
                ) {
                    Text(
                        "도서를 불러왔습니다",
                        modifier = Modifier.padding(horizontal = 24.dp, vertical = 12.dp),
                        style = MaterialTheme.typography.bodyMedium
                    )
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
    screenHeight: Int,
    strokeColor: Int,
    strokeWidth: Float,
    isEraserMode: Boolean,
    annotationFile: File?,
    onViewCreated: (PdfPageView) -> Unit,
    onViewDisposed: () -> Unit
) {
    var bitmap by remember { mutableStateOf<Bitmap?>(null) }

    LaunchedEffect(pdfFile, index, screenWidth) {
        bitmap = null
        bitmap = withContext(Dispatchers.IO) {
            renderSinglePage(pdfFile, index, screenWidth)
        }
    }

    DisposableEffect(index) {
        onDispose {
            onViewDisposed()
            bitmap = null
        }
    }

    if (bitmap != null) {
        val b = bitmap!!
        val pageAspect = b.width.toFloat() / b.height
        val isVeryTallPage = pageAspect < TALL_PAGE_ASPECT_THRESHOLD
        val shouldFitTallPage = isVeryTallPage && screenHeight > 0 && screenWidth > screenHeight
        val naturalHeightPx = (screenWidth / pageAspect).roundToInt().coerceAtLeast(MIN_RENDER_SIZE)
        val displayHeightPx = if (shouldFitTallPage) {
            naturalHeightPx.coerceAtMost(screenHeight)
        } else {
            naturalHeightPx
        }
        val displayWidthPx = if (displayHeightPx < naturalHeightPx) {
            (displayHeightPx * pageAspect).roundToInt().coerceAtLeast(MIN_RENDER_SIZE)
        } else {
            screenWidth
        }
        val density = LocalDensity.current
        val displayHeightDp = with(density) { displayHeightPx.toDp() }
        val displayWidthDp = with(density) { displayWidthPx.toDp() }

        Box(modifier = Modifier.fillMaxWidth().height(displayHeightDp)) {
            AndroidView(
                factory = { ctx ->
                    PdfPageView(ctx).also { view ->
                        view.pageBitmap = b
                        view.strokeColor = strokeColor
                        view.strokeWidth = strokeWidth
                        view.isEraserMode = isEraserMode
                        annotationFile?.let { view.loadAnnotation(it) }
                        onViewCreated(view)
                    }
                },
                update = { view ->
                    if (view.pageBitmap !== b) {
                        view.pageBitmap = b
                    }
                    view.strokeColor = strokeColor
                    view.strokeWidth = strokeWidth
                    view.isEraserMode = isEraserMode
                },
                modifier = Modifier
                    .width(displayWidthDp)
                    .height(displayHeightDp)
                    .align(Alignment.TopCenter)
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
    currentColor: Int,
    currentWidth: Float,
    onColorSelected: (Int) -> Unit,
    onWidthSelected: (Float) -> Unit,
    onDismiss: () -> Unit
) {
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
                        val isSelected = color == currentColor
                        IconButton(onClick = { onColorSelected(color) }) {
                            Box(
                                Modifier
                                    .size(if (isSelected) 38.dp else 32.dp)
                                    .background(
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
    if (screenWidth <= 0) return null
    return try {
        ParcelFileDescriptor.open(pdfFile, ParcelFileDescriptor.MODE_READ_ONLY).use { pfd ->
            PdfRenderer(pfd).use { renderer ->
                if (pageIndex >= renderer.pageCount) return null
                renderer.openPage(pageIndex).use { page ->
                    val pw = page.width.coerceAtLeast(1)
                    val ph = page.height.coerceAtLeast(1)
                    val pageAspect = ph.toFloat() / pw

                    // screenWidth is already in pixels from Compose constraints.
                    // Keep render size inside PdfRenderer/device bitmap limits for very tall pages.
                    var rw = screenWidth.coerceIn(MIN_RENDER_SIZE, MAX_RENDER_DIMENSION)
                    var rh = (rw * pageAspect).roundToInt().coerceAtLeast(MIN_RENDER_SIZE)

                    val largestSide = maxOf(rw, rh)
                    if (largestSide > MAX_RENDER_DIMENSION) {
                        val scale = MAX_RENDER_DIMENSION.toFloat() / largestSide
                        rw = (rw * scale).roundToInt().coerceAtLeast(MIN_RENDER_SIZE)
                        rh = (rh * scale).roundToInt().coerceAtLeast(MIN_RENDER_SIZE)
                    }

                    val pixelCount = rw.toLong() * rh.toLong()
                    if (pixelCount > MAX_RENDER_PIXELS) {
                        val scale = sqrt(MAX_RENDER_PIXELS.toDouble() / pixelCount.toDouble()).toFloat()
                        rw = (rw * scale).roundToInt().coerceAtLeast(MIN_RENDER_SIZE)
                        rh = (rh * scale).roundToInt().coerceAtLeast(MIN_RENDER_SIZE)
                    }

                    // 가장 호환성이 좋은 ARGB_8888로 복구 (내용 미출력 문제 해결)
                    val bitmap = Bitmap.createBitmap(rw, rh, Bitmap.Config.ARGB_8888)
                    bitmap.eraseColor(android.graphics.Color.WHITE)

                    // PDF 좌표를 비트맵 크기에 정확히 맞춤
                    val transform = Matrix()
                    val scaleX = rw.toFloat() / pw.toFloat()
                    val scaleY = rh.toFloat() / ph.toFloat()
                    transform.postScale(scaleX, scaleY)

                    page.render(bitmap, null, transform, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                    bitmap
                }
            }
        }
    } catch (e: Exception) {
        e.printStackTrace()
        null
    }
}

@Composable
private fun PdfThumbnailItem(
    pdfFile: File,
    index: Int,
    onClick: () -> Unit
) {
    var bitmap by remember { mutableStateOf<Bitmap?>(null) }

    LaunchedEffect(pdfFile, index) {
        bitmap = withContext(Dispatchers.IO) {
            renderThumbnail(pdfFile, index)
        }
    }

    Card(
        onClick = onClick,
        modifier = Modifier.fillMaxWidth().aspectRatio(0.75f),
        elevation = CardDefaults.cardElevation(2.dp)
    ) {
        Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            if (bitmap != null) {
                androidx.compose.foundation.Image(
                    bitmap = bitmap!!.asImageBitmap(),
                    contentDescription = null,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = androidx.compose.ui.layout.ContentScale.Crop
                )
                Surface(
                    color = Color.Black.copy(alpha = 0.5f),
                    shape = RoundedCornerShape(bottomEnd = 8.dp),
                    modifier = Modifier.align(Alignment.TopStart)
                ) {
                    Text(
                        "${index + 1}",
                        color = Color.White,
                        style = MaterialTheme.typography.labelSmall,
                        modifier = Modifier.padding(horizontal = 4.dp, vertical = 2.dp)
                    )
                }
            } else {
                CircularProgressIndicator(modifier = Modifier.size(20.dp))
            }
        }
    }
}

private fun renderThumbnail(pdfFile: File, pageIndex: Int): Bitmap? {
    return try {
        ParcelFileDescriptor.open(pdfFile, ParcelFileDescriptor.MODE_READ_ONLY).use { pfd ->
            PdfRenderer(pfd).use { renderer ->
                renderer.openPage(pageIndex).use { page ->
                    val w = 150
                    val h = (page.height * (w.toFloat() / page.width)).toInt()
                    val bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
                    bitmap.eraseColor(android.graphics.Color.WHITE)
                    val transform = Matrix().apply {
                        postScale(w.toFloat() / page.width.toFloat(), h.toFloat() / page.height.toFloat())
                    }
                    page.render(bitmap, null, transform, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                    bitmap
                }
            }
        }
    } catch (e: Exception) {
        null
    }
}
