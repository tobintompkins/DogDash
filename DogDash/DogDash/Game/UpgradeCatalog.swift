import Foundation

enum UpgradeBranch: String, Codable, CaseIterable {
    case endurance
    case stealth
    case scavenger

    var displayName: String {
        switch self {
        case .endurance: return "Endurance"
        case .stealth: return "Stealth"
        case .scavenger: return "Scavenger"
        }
    }
}

enum UpgradeID: String, Codable, CaseIterable {
    // Endurance
    case ironLegs
    case slowBurn
    case deepBreath

    // Stealth
    case quietSteps
    case scentDrop
    case fastHide

    // Scavenger
    case sharpNose
    case fullBelly
    case luckyFind
}

struct UpgradeDefinition: Codable {
    let id: UpgradeID
    let branch: UpgradeBranch
    let name: String
    let description: String
    let maxLevel: Int
    let baseCost: Int
    let costGrowth: Int

    func cost(for nextLevel: Int) -> Int {
        // nextLevel is 1...maxLevel
        baseCost + (nextLevel - 1) * costGrowth
    }
}

struct UpgradeCatalog {
    static let all: [UpgradeDefinition] = [
        // ENDURANCE
        .init(id: .ironLegs, branch: .endurance,
              name: "Iron Legs",
              description: "+10 max stamina per level.",
              maxLevel: 3, baseCost: 80, costGrowth: 60),

        .init(id: .slowBurn, branch: .endurance,
              name: "Slow Burn",
              description: "-6% stamina drain per level.",
              maxLevel: 3, baseCost: 120, costGrowth: 80),

        .init(id: .deepBreath, branch: .endurance,
              name: "Deep Breath",
              description: "Adrenaline cooldown -10% per level.",
              maxLevel: 2, baseCost: 180, costGrowth: 120),

        // STEALTH
        .init(id: .quietSteps, branch: .stealth,
              name: "Quiet Steps",
              description: "-8% scent gain per level.",
              maxLevel: 3, baseCost: 90, costGrowth: 70),

        .init(id: .scentDrop, branch: .stealth,
              name: "Scent Drop",
              description: "Hide reduces scent +10% per level.",
              maxLevel: 3, baseCost: 110, costGrowth: 80),

        .init(id: .fastHide, branch: .stealth,
              name: "Fast Hide",
              description: "Hide window +0.15s per level.",
              maxLevel: 2, baseCost: 160, costGrowth: 120),

        // SCAVENGER
        .init(id: .sharpNose, branch: .scavenger,
              name: "Sharp Nose",
              description: "+6% pickup spawns per level.",
              maxLevel: 3, baseCost: 90, costGrowth: 70),

        .init(id: .fullBelly, branch: .scavenger,
              name: "Full Belly",
              description: "-6% hunger drain per level.",
              maxLevel: 3, baseCost: 120, costGrowth: 85),

        .init(id: .luckyFind, branch: .scavenger,
              name: "Lucky Find",
              description: "Rare food chance +2% per level.",
              maxLevel: 3, baseCost: 150, costGrowth: 100),
    ]

    static func definition(for id: UpgradeID) -> UpgradeDefinition {
        all.first(where: { $0.id == id })!
    }
}
