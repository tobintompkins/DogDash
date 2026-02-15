import SwiftUI
import SpriteKit

struct GameContainerView: View {
    @ObservedObject var store: ProgressionStore
    var onDismiss: (() -> Void)?

    @StateObject private var gameState = GameState()
    @StateObject private var streakTracker = StreakTracker()

    @State private var showShop = false

    private func makeScene() -> GameScene {
        let s = GameScene(size: UIScreen.main.bounds.size)
        s.scaleMode = .resizeFill
        s.attach(gameState: gameState, store: store, streakTracker: streakTracker)
        return s
    }

    @State private var scene: GameScene?

    var body: some View {
        ZStack {
            if let scene {
                Color.black.ignoresSafeArea()

                SpriteView(scene: scene)
                    .ignoresSafeArea()

                DangerVignette(intensity: gameState.dangerIntensity)

                GameHUD(scene: scene, gameState: gameState)

                BiomeBannerHUD(gameState: gameState)
                    .allowsHitTesting(false)
            } else {
                Color.black.ignoresSafeArea()
            }

            if gameState.isRunOver {
                GameOverView(
                    title: gameState.didWin ? "YOU MADE IT HOME 🏠" : "GAME OVER",
                    distance: gameState.distanceThisRun,
                    pawPoints: gameState.pawPointsEarnedThisRun,
                    bestDistance: store.data.bestDistance,
                    dailyTitle: gameState.dailyTitle.isEmpty ? nil : gameState.dailyTitle,
                    onRetry: { restartRun() },
                    onMenu: { onDismiss?() },
                    onShop: { showShop = true }
                )
            }

            if gameState.showRankUp {
                RankUpPopup(
                    newRank: PlayerRank(rawValue: gameState.rankUpNewRank) ?? .stray,
                    ppReward: gameState.rankUpRewardPP,
                    unlocks: gameState.rankUpUnlocks.map { key in
                        // lightweight placeholder unlock display (so we don't need full objects here)
                        UnlockItem(id: key, type: .perk, name: key, description: "")
                    },
                    onClose: { gameState.showRankUp = false }
                )
            }
        }
        .onAppear {
            if scene == nil {
                scene = makeScene()
            }
        }
        .sheet(isPresented: $showShop) {
            ShopView(store: store)
        }
    }

    private func restartRun() {
        let newScene = makeScene()
        scene = newScene
    }
}
