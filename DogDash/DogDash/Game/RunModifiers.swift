import Foundation
import CoreGraphics

struct RunModifiers: Codable {
    var noHiding: Bool = false
    var fogMultiplier: CGFloat = 1.0
    var riskOnly: Bool = false
    var startWithAdrenaline: Bool = false
    var foodSpawnMultiplier: CGFloat = 1.0
    var scoreMultiplier: CGFloat = 1.0
}
