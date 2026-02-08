import Foundation

enum DailyChallengeID: String, CaseIterable, Codable {
    case normal
    case noHiding
    case doubleFog
    case riskOnly
    case adrenalineStart
    case lowFood
}

struct DailyChallenge: Codable {
    let id: DailyChallengeID
    let title: String
    let description: String
    let modifiers: RunModifiers

    static let presets: [DailyChallenge] = [
        .init(
            id: .normal,
            title: "Normal Run",
            description: "Standard rules. Make it HOME.",
            modifiers: RunModifiers()
        ),
        .init(
            id: .noHiding,
            title: "No Hiding",
            description: "Hide spots are disabled. Run smart.",
            modifiers: RunModifiers(noHiding: true, scoreMultiplier: 1.2)
        ),
        .init(
            id: .doubleFog,
            title: "Thick Fog",
            description: "Fog is heavier than usual.",
            modifiers: RunModifiers(fogMultiplier: 2.0, scoreMultiplier: 1.25)
        ),
        .init(
            id: .riskOnly,
            title: "Risk Lanes Only",
            description: "Only RISK lane rewards count.",
            modifiers: RunModifiers(riskOnly: true, scoreMultiplier: 1.35)
        ),
        .init(
            id: .adrenalineStart,
            title: "Adrenaline Rush",
            description: "Start the run in Adrenaline Mode.",
            modifiers: RunModifiers(startWithAdrenaline: true, scoreMultiplier: 1.2)
        ),
        .init(
            id: .lowFood,
            title: "Slim Pickings",
            description: "Food spawns are reduced.",
            modifiers: RunModifiers(foodSpawnMultiplier: 0.6, scoreMultiplier: 1.4)
        )
    ]

    static func preset(for id: DailyChallengeID) -> DailyChallenge? {
        presets.first { $0.id == id }
    }
}
