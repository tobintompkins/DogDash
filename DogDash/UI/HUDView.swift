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

struct HUDView: View {
    let isGameOver: Bool
    let isWon: Bool
    let scoreText: String
    let timeText: String
    let stamina: Double
    let hunger: Double
    let catcher: Double
    let homeProgress: Double
    let checkpointCount: Int
    let effectsText: String
    let weatherText: String
    let coverTimerText: String
    let weatherHintText: String
    let dailyTitle: String
    let dailyDescription: String
    let onRestart: () -> Void

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
                    Text("Score: \(scoreText)")
                        .font(.headline)
                    Text("Time: \(timeText)")
                        .font(.subheadline)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(.black.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .allowsHitTesting(false)

            HStack(alignment: .top, spacing: 12) {
                HomeProgressBar(progress: CGFloat(homeProgress))
                Spacer()
                Text("\(Int(homeProgress * 100))%  •  CP: \(checkpointCount)")
                    .font(.caption)
                    .opacity(0.9)
                    .foregroundStyle(.white)
            }
            .padding(.top, 6)
            .allowsHitTesting(false)

            if !effectsText.isEmpty {
                Text("Effects: \(effectsText)")
                    .font(.caption)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(.black.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(.white)
                    .allowsHitTesting(false)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(dailyTitle)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                if !dailyDescription.isEmpty {
                    Text(dailyDescription)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.85))
                }
            }
            .padding(10)
            .background(Color.black.opacity(0.25))
            .cornerRadius(12)
            .allowsHitTesting(false)

            Text(weatherText.uppercased())
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.85))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.25))
                .cornerRadius(10)
                .allowsHitTesting(false)

            if !coverTimerText.isEmpty {
                Text(coverTimerText)
                    .font(.caption).bold()
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(.yellow.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(.white)
                    .allowsHitTesting(false)
            }

            if !weatherHintText.isEmpty {
                Text(weatherHintText)
                    .font(.caption)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(.black.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(.white)
                    .allowsHitTesting(false)
            }

            // Stamina, Hunger, Catcher meters
            HStack(spacing: 16) {
                MeterBar(label: "Stamina", value: stamina, color: .green)
                MeterBar(label: "Hunger", value: hunger, color: .orange)
                MeterBar(label: "Catcher", value: catcher, color: .red.opacity(0.9))
            }
            .padding(.top, 8)
            .allowsHitTesting(false)

            if isGameOver || isWon {
                VStack(spacing: 10) {
                    Text(isWon ? "You Win!" : "Game Over")
                        .font(.title2).bold()

                    Button("Restart") {
                        onRestart()
                    }
                    .font(.headline)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 18)
                    .background(.white.opacity(0.9))
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(16)
                .background(.black.opacity(0.45))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            Spacer()
                .allowsHitTesting(false)
        }
    }
}
