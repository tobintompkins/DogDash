import SwiftUI

struct MissionHUD: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Daily Missions")
                    .font(.caption.bold())
                    .foregroundColor(.white)

                Spacer()

                Text("Streak x\(String(format: "%.2f", gameState.streakMultiplier))")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.85))
            }

            ForEach(gameState.dailyMissions) { m in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(m.title)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.92))
                            .lineLimit(1)

                        Spacer()

                        Text(m.isComplete ? "✅ +\(m.rewardPP)" : "\(m.progress)/\(m.target)")
                            .font(.caption2.bold())
                            .foregroundColor(.white.opacity(0.92))
                    }

                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.18))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(m.isComplete ? Color.green : Color.white)
                            .frame(width: 260 * m.progressRatio, height: 8)
                    }
                    .frame(width: 260)
                }
            }
        }
        .padding(10)
        .background(Color.black.opacity(0.22))
        .cornerRadius(14)
        .padding(.top, 8)
        .padding(.leading, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
