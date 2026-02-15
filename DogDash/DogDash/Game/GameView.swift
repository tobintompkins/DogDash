import SwiftUI

struct GameView: View {
    @ObservedObject var store: ProgressionStore
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        GameContainerView(store: store, onDismiss: onDismiss)
    }
}

#Preview {
    GameView(store: ProgressionStore())
}
