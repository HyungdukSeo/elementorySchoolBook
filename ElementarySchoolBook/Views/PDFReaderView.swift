import SwiftUI
import QuickLook

// MARK: - 메인 리더 뷰
//
// QuickLook 의 QLPreviewController 를 사용해 Files 앱에서 PDF 를 여는 것과 동일한
// 네이티브 UX 제공: 핀치 줌, 페이지 스크롤, 마크업(필기). 마크업으로 그린 내용은
// 편집 모드 .updateContents 로 PDF 파일 자체에 저장된다.

struct PDFReaderView: View {
    let book: Book
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        QuickLookPreview(url: book.localPDFPath, onClose: { dismiss() })
            .ignoresSafeArea()
    }
}

// MARK: - QLPreviewController 래퍼

struct QuickLookPreview: UIViewControllerRepresentable {
    let url: URL
    let onClose: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url, onClose: onClose)
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let preview = QLPreviewController()
        preview.dataSource = context.coordinator
        preview.delegate = context.coordinator

        // SwiftUI fullScreenCover 로 띄워졌으므로 닫기 버튼을 직접 추가해
        // SwiftUI 의 dismiss 와 연결
        preview.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: context.coordinator,
            action: #selector(Coordinator.didTapClose)
        )

        return UINavigationController(rootViewController: preview)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        context.coordinator.onClose = onClose
    }

    final class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
        let url: URL
        var onClose: () -> Void

        init(url: URL, onClose: @escaping () -> Void) {
            self.url = url
            self.onClose = onClose
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> any QLPreviewItem {
            url as QLPreviewItem
        }

        // 마크업 결과를 PDF 파일에 직접 덮어쓰기
        func previewController(_ controller: QLPreviewController,
                               editingModeFor previewItem: any QLPreviewItem) -> QLPreviewItemEditingMode {
            .updateContents
        }

        @objc func didTapClose() {
            onClose()
        }
    }
}
