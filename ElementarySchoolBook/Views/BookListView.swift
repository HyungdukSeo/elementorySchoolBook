import SwiftUI

struct BookListView: View {
    let grade: Int
    @EnvironmentObject var store: BookStore

    private var books: [Book] {
        store.books.filter { $0.grade == grade }
    }

    private let columns = [GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(books) { book in
                        BookCardView(book: book)
                    }
                }
                .padding()
            }
            .navigationTitle("\(grade)학년 교과서")
            .background(Color(.systemGroupedBackground))
        }
    }
}
