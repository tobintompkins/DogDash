import SwiftUI

struct MainMenuView: View {
    @ObservedObject var store: ProgressionStore
    @State private var showShop = false
    @State private var startGame = false

    var body: some View {
        VStack(spacing: 16) {
            Text("DOG DASH")
                .font(.largeTitle.bold())

            Text("Paw Points: \(store.data.pawPoints)")
                .font(.headline)

            Button("Start Run") { startGame = true }
                .buttonStyle(.borderedProminent)

            Button("Upgrade Shop") { showShop = true }
                .buttonStyle(.bordered)
        }
        .padding()
        .navigationDestination(isPresented: $startGame) {
            GameView(store: store)
        }
        .sheet(isPresented: $showShop) {
            ShopView(store: store)
        }
    }
}
