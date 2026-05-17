import SwiftUI
import PDFKit
import PencilKit

// MARK: - 메인 리더 뷰

struct PDFReaderView: View {
    let book: Book
    @Environment(\.dismiss) private var dismiss
    @State private var drawing = PKDrawing()
    @State private var isDrawingMode = false

    var body: some View {
        NavigationStack {
            PDFAnnotationView(
                pdfURL: book.localPDFPath,
                drawing: $drawing,
                isDrawingMode: isDrawingMode
            )
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle(book.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        saveDrawing()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        isDrawingMode.toggle()
                    } label: {
                        Image(systemName: isDrawingMode ? "hand.draw.fill" : "hand.draw")
                            }
                    .tint(isDrawingMode ? .blue : .primary)

                    Button {
                        saveDrawing()
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
            }
        }
        .onAppear { loadDrawing() }
        .onDisappear { saveDrawing() }
    }

    private func loadDrawing() {
        guard let data = try? Data(contentsOf: book.annotationPath),
              let saved = try? PKDrawing(data: data) else { return }
        drawing = saved
    }

    private func saveDrawing() {
        let data = drawing.dataRepresentation()
        try? data.write(to: book.annotationPath, options: .atomic)
    }
}

// MARK: - PDFKit + PencilKit 통합 뷰

struct PDFAnnotationView: UIViewControllerRepresentable {
    let pdfURL: URL
    @Binding var drawing: PKDrawing
    let isDrawingMode: Bool

    func makeUIViewController(context: Context) -> PDFAnnotationViewController {
        let vc = PDFAnnotationViewController()
        vc.load(pdfURL: pdfURL, drawing: drawing)
        vc.onDrawingChange = { drawing = $0 }
        return vc
    }

    func updateUIViewController(_ vc: PDFAnnotationViewController, context: Context) {
        vc.setDrawingMode(isDrawingMode)
        if vc.currentDrawing != drawing {
            vc.setDrawing(drawing)
        }
    }
}

// MARK: - UIViewController

final class PDFAnnotationViewController: UIViewController {
    var onDrawingChange: ((PKDrawing) -> Void)?
    var currentDrawing: PKDrawing { canvasView.drawing }

    private let pdfView = PDFView()
    private let canvasView = PKCanvasView()
    private let toolPicker = PKToolPicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPDFView()
        setupCanvas()
    }

    private func setupPDFView() {
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: view.topAnchor),
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = .systemGray6
    }

    private func setupCanvas() {
        // 캔버스를 PDFView의 documentView(내부 스크롤 영역)에 추가하여 PDF와 함께 스크롤
        // documentView는 viewDidLayoutSubviews 이후에 접근 가능
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        attachCanvasToDocumentView()
    }

    private func attachCanvasToDocumentView() {
        guard let docView = pdfView.documentView,
              canvasView.superview == nil else { return }

        canvasView.frame = docView.bounds
        canvasView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        // 기본: 손가락은 스크롤, Apple Pencil만 필기
        canvasView.drawingPolicy = .pencilOnly
        canvasView.delegate = self
        docView.addSubview(canvasView)

        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }

    // MARK: - 외부 접근

    func load(pdfURL: URL, drawing: PKDrawing) {
        pdfView.document = PDFDocument(url: pdfURL)
        canvasView.drawing = drawing
    }

    func setDrawing(_ drawing: PKDrawing) {
        canvasView.drawing = drawing
    }

    func setDrawingMode(_ enabled: Bool) {
        // enabled: 손가락도 필기 허용 / disabled: Apple Pencil만 필기
        canvasView.drawingPolicy = enabled ? .anyInput : .pencilOnly
    }
}

// MARK: - PKCanvasViewDelegate

extension PDFAnnotationViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        onDrawingChange?(canvasView.drawing)
    }
}
