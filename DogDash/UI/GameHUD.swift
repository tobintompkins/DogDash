import SwiftUI

struct GameHUD: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack {
            HStack {
                HomeProgressBar(progress: gameState.homeProgress)
                Spacer()
            }
            .padding()

            Spacer()
        }
    }
}
