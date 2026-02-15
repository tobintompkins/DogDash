import Foundation
import CoreGraphics

enum MissionType: String, Codable, CaseIterable {
    case passCheckpoints
    case successfulHides
    case collectFood
    case surviveSeconds
    case reachDistance
}

struct Mission: Codable, Identifiable {
    let id: String
    let type: MissionType
    let title: String
    let target: Int
    let rewardPP: Int

    // runtime-ish
    var progress: Int = 0
    var isComplete: Bool = false

    var progressRatio: CGFloat {
        guard target > 0 else { return 0 }
        return min(1.0, CGFloat(progress) / CGFloat(target))
    }
}
