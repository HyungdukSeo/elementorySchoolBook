import SwiftUI

struct BookCardView: View {
    let book: Book
    @EnvironmentObject var store: BookStore
    @State private var showReader = false
    @State private var showDeleteConfirm = false

    private var isDownloading: Bool { store.downloadingIDs.contains(book.id) }
    private var progress: Double { store.downloadProgress[book.id] ?? 0 }
    /// 동아·지학사 같은 정적 카탈로그는 책 삭제 불가
    private var canDelete: Bool { book.publisherEnum?.supportsCatalogUpdate == true }

    var body: some View {
        VStack(spacing: 0) {
            cover
            controls
                .padding(10)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        .fullScreenCover(isPresented: $showReader) {
            PDFReaderView(book: book)
        }
        .contextMenu {
            // 동아·지학사는 메뉴 자체 비표시
            if canDelete {
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Label("목록에서 삭제", systemImage: "trash")
                }
            }
        }
        .confirmationDialog(
            "도서 삭제",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("삭제", role: .destructive) {
                store.deleteBook(book)
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("목록과 저장된 PDF, 필기 데이터를 삭제할까요?")
        }
    }

    // MARK: - 표지

    private var cover: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(subjectGradient)
                .frame(height: 140)

            VStack(spacing: 6) {
                Image(systemName: subjectIcon)
                    .font(.system(size: 36))
                    .foregroundStyle(.white.opacity(0.9))
                Text(book.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                if let label = book.supplementLabel {
                    Text(label)
                        .font(.caption2.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.white.opacity(0.25), in: Capsule())
                        .foregroundStyle(.white)
                }
                if book.isArchived {
                    Text("보관됨")
                        .font(.caption2.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.black.opacity(0.22), in: Capsule())
                        .foregroundStyle(.white)
                }
            }

            if isDownloading {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.black.opacity(0.45))
                VStack(spacing: 6) {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .tint(.white)
                        .padding(.horizontal, 16)
                    Text("\(Int(progress * 100))%")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                }
            }
        }
    }

    // MARK: - 버튼 영역

    @ViewBuilder
    private var controls: some View {
        if book.isArchived && !book.isDownloaded {
            // 보관됐고 다운로드도 안 된 책: 삭제 버튼만 (canDelete 인 경우만 — 동아·지학사는 도달 불가)
            if canDelete {
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Label("삭제", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            } else {
                Text("보관됨")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
        } else if book.isDownloaded {
            VStack(spacing: 6) {
                Button { showReader = true } label: {
                    Label("열기", systemImage: "doc.text.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(subjectColor)
                .controlSize(.regular)

                // 보관됐으면 재다운로드는 비활성 (URL 이 더 이상 유효하지 않을 수 있음)
                Button {
                    store.download(book)
                } label: {
                    Label("업데이트", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(subjectColor)
                .controlSize(.small)
                .disabled(isDownloading || book.isArchived)

                if let date = book.lastDownloaded {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        } else {
            Button {
                store.download(book)
            } label: {
                Label("다운로드", systemImage: "arrow.down.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(subjectColor)
            .disabled(isDownloading)
        }
    }

    // MARK: - 스타일

    private var subjectColor: Color {
        if book.isArchived { return Color(.systemGray) }
        switch book.subject {
        case "수학":    return .blue
        case "수학익힘": return .cyan
        case "사회":    return .orange
        case "과학":    return .green
        case "실험관찰": return .mint
        case "영어":    return .purple
        case "미술":    return .pink
        case "음악":    return .indigo
        case "체육":    return .red
        case "실과":    return Color(red: 0.6, green: 0.4, blue: 0.2)
        case "보건":    return Color(red: 0.85, green: 0.1, blue: 0.4)
        default:       return .gray
        }
    }

    private var subjectGradient: LinearGradient {
        LinearGradient(
            colors: [subjectColor, subjectColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var subjectIcon: String {
        switch book.subject {
        case "수학", "수학익힘":  return "function"
        case "사회":            return "globe.asia.australia.fill"
        case "과학", "실험관찰":  return "atom"
        case "영어":            return "textformat.abc"
        case "미술":            return "paintpalette.fill"
        case "음악":            return "music.note"
        case "체육":            return "figure.run"
        case "실과":            return "wrench.and.screwdriver.fill"
        case "보건":            return "cross.fill"
        default:               return "book.fill"
        }
    }
}
