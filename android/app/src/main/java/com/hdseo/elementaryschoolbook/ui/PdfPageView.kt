package com.hdseo.elementaryschoolbook.ui

import android.content.Context
import android.graphics.*
import android.view.MotionEvent
import android.view.View
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.io.File
import java.util.concurrent.CopyOnWriteArrayList

// ── 저장 가능한 필기 데이터 구조

@Serializable
data class StrokePoint(val x: Float, val y: Float)

@Serializable
data class Stroke(
    val points: List<StrokePoint>,
    val color: Int = Color.BLUE,
    val width: Float = 4f
) {
    @kotlinx.serialization.Transient
    private var _path: Path? = null

    fun getPath(): Path {
        if (_path == null) {
            _path = Path().apply {
                if (points.isNotEmpty()) {
                    moveTo(points[0].x, points[0].y)
                    for (i in 1 until points.size) {
                        val prev = points[i - 1]
                        val curr = points[i]
                        val midX = (prev.x + curr.x) / 2
                        val midY = (prev.y + curr.y) / 2
                        if (i == 1) {
                            lineTo(midX, midY)
                        } else {
                            quadTo(prev.x, prev.y, midX, midY)
                        }
                    }
                    lineTo(points.last().x, points.last().y)
                }
            }
        }
        return _path!!
    }
}

@Serializable
data class Annotation(val strokes: List<Stroke> = emptyList())

// ── PDF 페이지 + 스타일러스 필기 뷰

class PdfPageView(context: Context) : View(context) {

    init {
        // 비트맵이 너무 클 경우 하드웨어 가속에서 크래시가 발생할 수 있으므로 소프트웨어 렌더링 권장
        setLayerType(LAYER_TYPE_SOFTWARE, null)
    }

    var pageBitmap: Bitmap? = null
        set(value) { field = value; invalidate() }

    // 필기 획 데이터 (스레드 안전)
    private val finishedStrokes = CopyOnWriteArrayList<Stroke>()
    private var currentPoints = mutableListOf<StrokePoint>()
    private var isDrawingStroke = false

    var strokeColor: Int = Color.BLUE
    var strokeWidth: Float = 4f
    var isEraserMode: Boolean = false
    var onDrawingChanged: (() -> Unit)? = null

    private val strokePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeCap = Paint.Cap.ROUND
        strokeJoin = Paint.Join.ROUND
    }

    private val bitmapPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        isFilterBitmap = true
        isDither = true
    }

    private val destRect = RectF()

    override fun onDraw(canvas: Canvas) {
        canvas.drawColor(Color.WHITE)

        // PDF 페이지 렌더링 (뷰 크기에 맞춰 스케일링)
        pageBitmap?.let {
            destRect.set(0f, 0f, width.toFloat(), height.toFloat())
            canvas.drawBitmap(it, null, destRect, bitmapPaint)
        }

        // 완료된 획
        for (stroke in finishedStrokes) {
            strokePaint.color = stroke.color
            strokePaint.strokeWidth = stroke.width
            canvas.drawPath(stroke.getPath(), strokePaint)
        }

        // 현재 그리는 중인 획
        if (currentPoints.size > 1) {
            drawStroke(canvas, currentPoints, strokeColor, strokeWidth)
        }
    }

    private fun drawStroke(canvas: Canvas, points: List<StrokePoint>, color: Int, width: Float) {
        if (points.size < 2) return
        strokePaint.color = color
        strokePaint.strokeWidth = width

        val path = Path()
        path.moveTo(points[0].x, points[0].y)

        // QuadTo를 이용한 부드러운 곡선 처리
        for (i in 1 until points.size) {
            val prev = points[i - 1]
            val curr = points[i]
            val midX = (prev.x + curr.x) / 2
            val midY = (prev.y + curr.y) / 2

            if (i == 1) {
                path.lineTo(midX, midY)
            } else {
                path.quadTo(prev.x, prev.y, midX, midY)
            }
        }

        val last = points.last()
        path.lineTo(last.x, last.y)

        canvas.drawPath(path, strokePaint)
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        // 스타일러스 입력만 처리 → 손가락은 부모(LazyColumn)에 전달하여 스크롤/줌 허용
        if (event.getToolType(0) != MotionEvent.TOOL_TYPE_STYLUS) {
            return false
        }

        val x = event.x
        val y = event.y

        when (event.action) {
            MotionEvent.ACTION_DOWN -> handleActionDown(x, y)
            MotionEvent.ACTION_MOVE -> {
                // 부드러운 드로잉을 위해 historical 포인트들도 추가
                for (i in 0 until event.historySize) {
                    handleActionMove(event.getHistoricalX(i), event.getHistoricalY(i))
                }
                handleActionMove(x, y)
            }
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> handleActionUp()
        }
        return true
    }

    fun handleActionDown(x: Float, y: Float) {
        parent?.requestDisallowInterceptTouchEvent(true)
        isDrawingStroke = true
        currentPoints.clear()
        currentPoints.add(StrokePoint(x, y))
    }

    fun handleActionMove(x: Float, y: Float) {
        if (isDrawingStroke) {
            currentPoints.add(StrokePoint(x, y))
            if (isEraserMode) {
                eraseNear(listOf(StrokePoint(x, y)))
            }
            invalidate()
        }
    }

    fun handleActionUp() {
        if (isDrawingStroke && currentPoints.size > 1) {
            try {
                if (isEraserMode) {
                    eraseNear(currentPoints)
                } else {
                    finishedStrokes.add(Stroke(currentPoints.toList(), strokeColor, strokeWidth))
                }
                onDrawingChanged?.invoke()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        currentPoints.clear()
        isDrawingStroke = false
        parent?.requestDisallowInterceptTouchEvent(false)
        invalidate()
    }

    // 지우개: 경로 근처의 획 제거
    private fun eraseNear(erasePath: List<StrokePoint>) {
        val threshold = strokeWidth * 8
        finishedStrokes.removeAll { stroke ->
            stroke.points.any { sp ->
                erasePath.any { ep ->
                    val dx = sp.x - ep.x
                    val dy = sp.y - ep.y
                    dx * dx + dy * dy < threshold * threshold
                }
            }
        }
    }

    fun undo() {
        if (finishedStrokes.isNotEmpty()) {
            try {
                finishedStrokes.removeAt(finishedStrokes.size - 1)
                onDrawingChanged?.invoke()
                invalidate()
            } catch (e: Exception) {}
        }
    }

    // ── 저장/불러오기

    fun saveAnnotation(file: File) {
        try {
            val annotation = Annotation(finishedStrokes.toList())
            file.writeText(Json.encodeToString(annotation))
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun loadAnnotation(file: File) {
        if (!file.exists()) return
        try {
            val annotation = Json.decodeFromString<Annotation>(file.readText())
            finishedStrokes.clear()
            finishedStrokes.addAll(annotation.strokes)
            invalidate()
        } catch (_: Exception) {}
    }

    fun clearAnnotation() {
        finishedStrokes.clear()
        currentPoints.clear()
        onDrawingChanged?.invoke()
        invalidate()
    }
}
