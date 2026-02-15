import SwiftUI

private struct MeterBar: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .opacity(0.9)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.white.opacity(0.12))
                    .frame(height: 8)
                RoundedRectangle(cornerRadius: 6)
                    .fill(color.opacity(0.9))
                    .frame(width: max(0, CGFloat(value)) * 90, height: 8)
            }
            .frame(width: 90, height: 8)
        }
        .foregroundStyle(.white)
    }
}

struct GameHUD: View {
    let scene: GameScene
    @ObservedObject var gameState: GameState

    @ObservedObject private var viewModel: GameViewModel

    init(scene: GameScene, gameState: GameState) {
        self.scene = scene
        self.gameState = gameState
        self._viewModel = ObservedObject(wrappedValue: scene.viewModel)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("DogDash")
                    .font(.headline)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(.black.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text("Score: \(viewModel.scoreText)")
                        .font(.headline)
                    Text("Time: \(viewModel.timeText)")
                        .font(.subheadline)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(.black.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .allowsHitTesting(false)

            HStack(alignment: .top, spacing: 12) {
                HomeProgressBar(progress: gameState.homeProgress)
                Spacer()
                Text("\(Int(gameState.homeProgress * 100))%  •  CP: \(viewModel.checkpointCount)")
                    .font(.caption)
                    .opacity(0.9)
                    .foregroundStyle(.white)
            }
            .padding(.top, 6)
            .allowsHitTesting(false)

            if !viewModel.activeEffectsText.isEmpty {
                Text("Effects: \(viewModel.activeEffectsText)")
                    .font(.caption)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(.black.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(.white)
                    .allowsHitTesting(false)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(gameState.dailyTitle)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                if !gameState.dailyDescription.isEmpty {
                    Text(gameState.dailyDescription)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.85))
                }
            }
            .padding(10)
            .background(Color.black.opacity(0.25))
            .cornerRadius(12)
            .allowsHitTesting(false)

            Text(viewModel.weatherText.uppercased())
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.85))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.25))
                .cornerRadius(10)
                .allowsHitTesting(false)

            if !viewModel.coverTimerText.isEmpty {
                Text(viewModel.coverTimerText)
                    .font(.caption).bold()
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(.yellow.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(.white)
                    .allowsHitTesting(false)
            }

            if !viewModel.weatherHintText.isEmpty {
                Text(viewModel.weatherHintText)
                    .font(.caption)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(.black.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(.white)
                    .allowsHitTesting(false)
            }

            HStack {
                MissionHUD(gameState: gameState)
                Spacer()
            }

            HStack(spacing: 16) {
                MeterBar(label: "Stamina", value: viewModel.stamina, color: .green)
                MeterBar(label: "Hunger", value: viewModel.hunger, color: .orange)
                MeterBar(label: "Catcher", value: viewModel.catcher, color: .red.opacity(0.9))
            }
            .padding(.top, 8)
            .allowsHitTesting(false)

            Spacer()
                .allowsHitTesting(false)
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
    }
}
