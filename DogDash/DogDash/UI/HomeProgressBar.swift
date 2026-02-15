import SwiftUI

struct HomeProgressBar: View {
    var progress: CGFloat

    var body: some View {
        VStack(alignment: .leading) {
            Text("HOME")
                .font(.caption)
                .foregroundColor(.white)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 10)

                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.green)
                    .frame(width: 200 * progress, height: 10)
            }
        }
        .frame(width: 200)
    }
}
