import SwiftUI

struct DangerVignette: View {
    var intensity: CGFloat // 0...1

    var body: some View {
        Rectangle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.black.opacity(0.35 * intensity),
                        Color.black.opacity(0.65 * intensity)
                    ]),
                    center: .center,
                    startRadius: 140,
                    endRadius: 420
                )
            )
            .blendMode(.multiply)
            .ignoresSafeArea()
            .opacity(Double(min(1, max(0, intensity))))
            .allowsHitTesting(false)
    }
}
