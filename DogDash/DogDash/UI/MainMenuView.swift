import SwiftUI

struct MainMenuView: View {
    @ObservedObject var store: ProgressionStore
    @ObservedObject private var gc = GameCenterManager.shared
    @State private var showShop = false
    @State private var showRank = false
    @State private var showPerks = false
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

            Button("Rank & Unlocks") { showRank = true }
                .buttonStyle(.bordered)

            Button("Perks") { showPerks = true }
                .buttonStyle(.bordered)

            Button("Leaderboards") {
                GameCenterManager.shared.showLeaderboards()
            }
            .buttonStyle(.bordered)

            Button("Achievements") {
                GameCenterManager.shared.showAchievements()
            }
            .buttonStyle(.bordered)

            Text(gc.isAuthenticated ? "Game Center: Connected" : "Game Center: Not signed in")
                .font(.caption)
                .opacity(0.8)
        }
        .padding()
        .fullScreenCover(isPresented: $startGame) {
            GameView(store: store, onDismiss: { startGame = false })
        }
        .sheet(isPresented: $showShop) {
            ShopView(store: store)
        }
        .sheet(isPresented: $showRank) {
            RankView(store: store)
        }
        .sheet(isPresented: $showPerks) {
            PerksView(store: store)
        }
    }
}
