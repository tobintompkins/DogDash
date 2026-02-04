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

            VStack(spacing: 6) {
                HStack {
                    Text("Home")
                        .font(.subheadline)
                    Spacer()
                    Text("\(Int(homeProgress * 100))%  •  CP: \(checkpointCount)")
                        .font(.caption)
                        .opacity(0.9)
                }

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.white.opacity(0.12))
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(.yellow.opacity(0.9))
                        .frame(width: max(0, CGFloat(homeProgress)) * 320, height: 10)
                }
                .frame(width: 320, height: 10)
            }
            .padding(.top, 6)
            .foregroundStyle(.white)
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

            Text("Weather: \(weatherText)")
                .font(.caption)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(.black.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(.white)
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

            if isGameOver {
                VStack(spacing: 10) {
                    Text("Game Over")
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
