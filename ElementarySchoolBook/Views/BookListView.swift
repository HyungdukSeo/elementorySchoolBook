import SwiftUI

struct BookListView: View {
    @EnvironmentObject var store: BookStore

    private let columns = [GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                publisherTabs
                Divider()
                gradeTabs
                Divider()
                if store.selectedPublisher.supportsCatalogUpdate {
                    catalogUpdateButton
                    Divider()
                }
                bookGrid
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("초등 교과서")
            .navigationBarTitleDisplayMode(.inline)
            .alert("도서 목록 업데이트", isPresented: Binding(
                get: { store.catalogMessage != nil },
                set: { if !$0 { store.catalogMessage = nil } }
            )) {
                Button("확인") { store.catalogMessage = nil }
            } message: {
                Text(store.catalogMessage ?? "")
            }
        }
    }

    // MARK: - 출판사 가로 스크롤 탭

    private var publisherTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(Publisher.allCases, id: \.self) { pub in
                    Button {
                        store.selectedPublisher = pub
                    } label: {
                        Text(pub.rawValue)
                            .font(.subheadline)
                            .fontWeight(store.selectedPublisher == pub ? .semibold : .regular)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .foregroundStyle(store.selectedPublisher == pub ? Color.accentColor : .primary)
                            .background(
                                ZStack(alignment: .bottom) {
                                    Color.clear
                                    if store.selectedPublisher == pub {
                                        Rectangle()
                                            .fill(Color.accentColor)
                                            .frame(height: 2)
                                    }
                                }
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - 학년 세그먼트

    private var gradeTabs: some View {
        Picker("학년", selection: $store.selectedGrade) {
            ForEach(3...6, id: \.self) { grade in
                Text("\(grade)학년").tag(grade)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }

    // MARK: - 카탈로그 업데이트 버튼 (동아·지학사 제외)

    private var catalogUpdateButton: some View {
        Button {
            store.updateCurrentPublisherCatalog()
        } label: {
            HStack(spacing: 6) {
                if store.isUpdatingCatalog {
                    ProgressView().controlSize(.small)
                } else {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
                Text("\(store.selectedPublisher.rawValue) 도서 목록 업데이트")
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .buttonStyle(.bordered)
        .disabled(store.isUpdatingCatalog)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }

    // MARK: - 책 그리드

    @ViewBuilder
    private var bookGrid: some View {
        let books = store.filteredBooks
        if books.isEmpty {
            VStack {
                Spacer()
                Text("해당 출판사의 교과서 목록이 아직 준비되지 않았습니다.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(books) { book in
                        BookCardView(book: book)
                    }
                }
                .padding()
            }
        }
    }
}
