import SwiftUI

struct HUDView: View {
    let isGameOver: Bool
    let scoreText: String
    let timeText: String
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
