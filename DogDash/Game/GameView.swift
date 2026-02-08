import SwiftUI
import SpriteKit

struct GameView: View {
    var store: ProgressionStore?

    @State private var scene: GameScene = {
        let s = GameScene()
        s.scaleMode = .resizeFill
        return s
    }()

    init(store: ProgressionStore? = nil) {
        self.store = store
    }

    var body: some View {
        ZStack(alignment: .top) {
            SpriteView(scene: scene)
                .ignoresSafeArea()

            HUDOverlay(scene: scene)
                .padding(.top, 16)
                .padding(.horizontal, 16)
        }
        .onAppear {
            if let store {
                scene.configureProgression(store)
            }
        }
    }
}

private struct HUDOverlay: View {
    let scene: GameScene
    @ObservedObject private var viewModel: GameViewModel
    @ObservedObject private var gameState: GameState

    init(scene: GameScene) {
        self.scene = scene
        self._viewModel = ObservedObject(wrappedValue: scene.viewModel)
        self._gameState = ObservedObject(wrappedValue: scene.viewModel.gameState)
    }

    var body: some View {
        HUDView(
            isGameOver: scene.viewModel.isGameOver,
            isWon: scene.viewModel.isWon,
            scoreText: scene.viewModel.scoreText,
            timeText: scene.viewModel.timeText,
            stamina: scene.viewModel.stamina,
            hunger: scene.viewModel.hunger,
            catcher: scene.viewModel.catcher,
            homeProgress: scene.viewModel.homeProgress,
            checkpointCount: scene.viewModel.checkpointCount,
            effectsText: scene.viewModel.activeEffectsText,
            weatherText: scene.viewModel.weatherText,
            coverTimerText: scene.viewModel.coverTimerText,
            weatherHintText: scene.viewModel.weatherHintText,
            dailyTitle: gameState.dailyTitle,
            dailyDescription: gameState.dailyDescription,
            onRestart: { scene.requestRestart() }
        )
    }
}

#Preview {
    GameView(store: ProgressionStore())
}
