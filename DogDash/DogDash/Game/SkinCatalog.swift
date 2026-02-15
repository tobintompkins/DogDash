import Foundation
import CoreGraphics

enum SkinID: String, Codable, CaseIterable {
    case classic
    case midnight
    case sunrise
    case legend
}

struct SkinDefinition: Codable, Identifiable {
    let skinId: SkinID
    let name: String
    let description: String
    let unlockKey: String        // e.g. "skin:legend"
    let tintHex: String          // fallback if no textures yet
    let textureName: String?     // optional texture name if you add art later

    var id: String { skinId.rawValue }
}

enum SkinCatalog {
    static let all: [SkinDefinition] = [
        .init(
            skinId: .classic,
            name: "Classic",
            description: "Default look.",
            unlockKey: "skin:classic",
            tintHex: "#FFFFFF",
            textureName: nil
        ),
        .init(
            skinId: .midnight,
            name: "Midnight",
            description: "Cool dark coat.",
            unlockKey: "skin:midnight",
            tintHex: "#2B2F4A",
            textureName: nil
        ),
        .init(
            skinId: .sunrise,
            name: "Sunrise",
            description: "Warm bright coat.",
            unlockKey: "skin:sunrise",
            tintHex: "#FFB25E",
            textureName: nil
        ),
        .init(
            skinId: .legend,
            name: "Legend Coat",
            description: "Earned by legends.",
            unlockKey: "skin:legend",
            tintHex: "#FFD24A",
            textureName: nil
        )
    ]

    static func def(_ id: SkinID) -> SkinDefinition {
        all.first(where: { $0.skinId == id })!
    }
}
