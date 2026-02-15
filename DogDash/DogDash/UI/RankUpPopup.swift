import SwiftUI

struct RankUpPopup: View {
    let newRank: PlayerRank
    let ppReward: Int
    let unlocks: [UnlockItem]
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()

            VStack(spacing: 12) {
                Text("RANK UP!")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.9))

                Text(newRank.displayName)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)

                Text("+\(ppReward) Paw Points")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))

                if !unlocks.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Unlocked:")
                            .font(.headline)
                            .foregroundColor(.white)

                        ForEach(unlocks) { u in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(u.name)
                                    .foregroundColor(.white)
                                    .font(.subheadline.bold())
                                if !u.description.isEmpty {
                                    Text(u.description)
                                        .foregroundColor(.white.opacity(0.85))
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.10))
                    .cornerRadius(14)
                }

                Button("Continue") {
                    onClose()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 6)
            }
            .padding()
        }
    }
}
