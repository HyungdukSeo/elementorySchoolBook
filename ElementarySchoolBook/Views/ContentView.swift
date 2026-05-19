import SwiftUI

struct ContentView: View {
    @StateObject private var store = BookStore()

    var body: some View {
        BookListView()
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
