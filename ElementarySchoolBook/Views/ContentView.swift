import SwiftUI

struct ContentView: View {
    @StateObject private var store = BookStore()

    var body: some View {
        TabView {
            ForEach([3, 4, 5, 6], id: \.self) { grade in
                BookListView(grade: grade)
                    .tabItem {
                        Label("\(grade)학년", systemImage: "book.fill")
                    }
            }
        }
        .environmentObject(store)
        .onAppear { store.loadMetadata() }
        .alert("오류", isPresented: Binding(
            get: { store.errorMessage != nil },
            set: { if !$0 { store.errorMessage = nil } }
        )) {
            Button("확인") { store.errorMessage = nil }
        } message: {
            Text(store.errorMessage ?? "")
        }
    }
}
