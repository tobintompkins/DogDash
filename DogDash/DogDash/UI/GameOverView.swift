import SwiftUI

struct GameOverView: View {
    let title: String
    let distance: Int
    let pawPoints: Int
    let bestDistance: Int
    let dailyTitle: String?

    let onRetry: () -> Void
    let onMenu: () -> Void
    let onShop: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()

            VStack(spacing: 14) {
                Text(title)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)

                if let dailyTitle {
                    Text("Daily: \(dailyTitle)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.85))
                }

                VStack(spacing: 8) {
                    statRow("Distance", "\(distance)")
                    statRow("Paw Points", "\(pawPoints)")
                    statRow("Best", "\(bestDistance)")
                }
                .padding()
                .background(Color.white.opacity(0.10))
                .cornerRadius(16)

                HStack(spacing: 12) {
                    Button("Retry") { onRetry() }
                        .buttonStyle(.borderedProminent)

                    Button("Menu") { onMenu() }
                        .buttonStyle(.bordered)

                    Button("Shop") { onShop() }
                        .buttonStyle(.bordered)
                }
                .padding(.top, 6)
            }
            .padding()
        }
    }

    private func statRow(_ left: String, _ right: String) -> some View {
        HStack {
            Text(left).foregroundColor(.white.opacity(0.9))
            Spacer()
            Text(right).foregroundColor(.white).font(.headline)
        }
    }
}
