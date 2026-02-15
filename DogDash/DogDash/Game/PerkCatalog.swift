import Foundation
import CoreGraphics

enum PerkID: String, Codable, CaseIterable {
    case agileStart       // start with extra stamina
    case shadowStep       // scent decays faster for 10s after checkpoint
    case scavengerLuck    // higher chance of rare food
}

struct PerkDefinition: Codable, Identifiable {
    let perkId: PerkID
    let name: String
    let description: String
    let unlockKey: String // e.g. "perk:shadowStep"

    // optional tuning knobs (simple, general)
    let staminaStartBonus: CGFloat
    let shadowDecayMultiplier: CGFloat
    let shadowDuration: TimeInterval
    let rareFoodBonusChance: CGFloat

    var id: String { perkId.rawValue }
}

enum PerkCatalog {
    static let all: [PerkDefinition] = [
        PerkDefinition(
            perkId: .agileStart,
            name: "Agile Start",
            description: "Start each run with extra stamina.",
            unlockKey: "perk:agileStart",
            staminaStartBonus: 18,
            shadowDecayMultiplier: 1.0,
            shadowDuration: 0,
            rareFoodBonusChance: 0
        ),
        PerkDefinition(
            perkId: .shadowStep,
            name: "Shadow Step",
            description: "After each checkpoint, scent decays faster for a short time.",
            unlockKey: "perk:shadowStep",
            staminaStartBonus: 0,
            shadowDecayMultiplier: 2.2,
            shadowDuration: 10,
            rareFoodBonusChance: 0
        ),
        PerkDefinition(
            perkId: .scavengerLuck,
            name: "Scavenger Luck",
            description: "Slightly increases the chance of rare food drops.",
            unlockKey: "perk:scavengerLuck",
            staminaStartBonus: 0,
            shadowDecayMultiplier: 1.0,
            shadowDuration: 0,
            rareFoodBonusChance: 0.04
        )
    ]

    static func def(_ id: PerkID) -> PerkDefinition {
        all.first(where: { $0.perkId == id })!
    }
}
