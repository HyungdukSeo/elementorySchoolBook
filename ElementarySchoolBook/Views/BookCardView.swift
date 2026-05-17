import SwiftUI

struct BookCardView: View {
    let book: Book
    @EnvironmentObject var store: BookStore
    @State private var showReader = false

    private var isDownloading: Bool { store.downloadingIDs.contains(book.id) }
    private var progress: Double { store.downloadProgress[book.id] ?? 0 }

    var body: some View {
        VStack(spacing: 0) {
            // 표지 영역
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

            // 버튼 영역
            VStack(spacing: 6) {
                if book.isDownloaded {
                    Button { showReader = true } label: {
                        Label("열기", systemImage: "doc.text.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(subjectColor)
                    .controlSize(.regular)

                    Button {
                        store.download(book)
                    } label: {
                        Label("업데이트", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(subjectColor)
                    .controlSize(.small)
                    .disabled(isDownloading)

                    if let date = book.lastDownloaded {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
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
            .padding(10)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        .fullScreenCover(isPresented: $showReader) {
            PDFReaderView(book: book)
        }
    }

    private var subjectColor: Color {
        switch book.subject {
        case "수학": return .blue
        case "사회": return .orange
        case "과학": return .green
        case "영어": return .purple
        case "미술": return .pink
        case "음악": return .indigo
        case "체육": return .red
        case "실과": return Color(red: 0.6, green: 0.4, blue: 0.2)
        default:    return .gray
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
        case "수학": return "function"
        case "사회": return "globe.asia.australia.fill"
        case "과학": return "atom"
        case "영어": return "textformat.abc"
        case "미술": return "paintpalette.fill"
        case "음악": return "music.note"
        case "체육": return "figure.run"
        case "실과": return "wrench.and.screwdriver.fill"
        default:    return "book.fill"
        }
    }
}
