import SwiftUI
import SpriteKit

struct GameView: View {
    @State private var scene: GameScene = {
        let s = GameScene()
        s.scaleMode = .resizeFill
        return s
    }()

    var body: some View {
        ZStack(alignment: .top) {
            SpriteView(scene: scene)
                .ignoresSafeArea()

            HUDOverlay(scene: scene)
                .padding(.top, 16)
                .padding(.horizontal, 16)
        }
    }
}

private struct HUDOverlay: View {
    let scene: GameScene
    @ObservedObject private var viewModel: GameViewModel

    init(scene: GameScene) {
        self.scene = scene
        self._viewModel = ObservedObject(wrappedValue: scene.viewModel)
    }

    var body: some View {
        HUDView(
            isGameOver: scene.viewModel.isGameOver,
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
            onRestart: { scene.requestRestart() }
        )
    }
}

#Preview {
    GameView()
}
