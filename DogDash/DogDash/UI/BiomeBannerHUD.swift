import SwiftUI

struct BiomeBannerHUD: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        HStack {
            Text(gameState.currentBiome.uppercased())
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.25))
                .cornerRadius(12)
            Spacer()
        }
        .padding(.top, 46)
        .padding(.leading, 10)
    }
}
