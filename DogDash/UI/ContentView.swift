import SwiftUI

struct ContentView: View {
    @StateObject private var store = ProgressionStore()

    var body: some View {
        NavigationStack {
            MainMenuView(store: store)
        }
    }
}
    