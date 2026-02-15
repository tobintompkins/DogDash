import Foundation
import CoreGraphics

enum BiomeID: String, Codable, CaseIterable {
    case suburb
    case woods
    case industrial
    case stormNight
}

struct BiomeModifiers: Codable {
    var spawnIntensityMult: CGFloat = 1.0
    var staminaDrainMult: CGFloat = 1.0
    var hungerDrainMult: CGFloat = 1.0
    var scentGainMult: CGFloat = 1.0
    var fogExtra: CGFloat = 0.0        // adds on top of weather fog (0..1-ish)
}

struct WeightedItem: Codable {
    let id: String
    let weight: Int
}

struct BiomeConfig: Codable {
    let id: BiomeID
    let displayName: String

    // weights (spawn selection)
    let obstaclePool: [WeightedItem]   // "cone", "fence", "log", "pipe" etc.
    let pickupPool: [WeightedItem]     // "foodSmall", "foodBig", "rareFood"
    let hideSpotPool: [WeightedItem]   // "bush","tree","shed","house","culvert"

    let mods: BiomeModifiers
}

enum BiomeCatalog {
    static let all: [BiomeConfig] = [
        BiomeConfig(
            id: .suburb,
            displayName: "Suburbs",
            obstaclePool: [
                .init(id: "trashcan", weight: 30),
                .init(id: "fence", weight: 25),
                .init(id: "cone", weight: 20),
                .init(id: "bicycle", weight: 15)
            ],
            pickupPool: [
                .init(id: "foodSmall", weight: 55),
                .init(id: "foodBig", weight: 18),
                .init(id: "rareFood", weight: 5)
            ],
            hideSpotPool: [
                .init(id: "bush", weight: 50),
                .init(id: "tree", weight: 20)
            ],
            mods: .init(spawnIntensityMult: 1.0, staminaDrainMult: 1.0, hungerDrainMult: 1.0, scentGainMult: 1.0, fogExtra: 0.0)
        ),

        BiomeConfig(
            id: .woods,
            displayName: "Woods",
            obstaclePool: [
                .init(id: "log", weight: 35),
                .init(id: "branch", weight: 25),
                .init(id: "mud", weight: 15),
                .init(id: "rock", weight: 25)
            ],
            pickupPool: [
                .init(id: "foodSmall", weight: 50),
                .init(id: "foodBig", weight: 20),
                .init(id: "rareFood", weight: 6)
            ],
            hideSpotPool: [
                .init(id: "bush", weight: 35),
                .init(id: "tree", weight: 40),
                .init(id: "shed", weight: 10)
            ],
            mods: .init(spawnIntensityMult: 1.06, staminaDrainMult: 1.03, hungerDrainMult: 1.02, scentGainMult: 0.98, fogExtra: 0.0)
        ),

        BiomeConfig(
            id: .industrial,
            displayName: "Industrial",
            obstaclePool: [
                .init(id: "pallet", weight: 30),
                .init(id: "pipe", weight: 30),
                .init(id: "crate", weight: 20),
                .init(id: "barrel", weight: 20)
            ],
            pickupPool: [
                .init(id: "foodSmall", weight: 45),
                .init(id: "foodBig", weight: 24),
                .init(id: "rareFood", weight: 7)
            ],
            hideSpotPool: [
                .init(id: "shed", weight: 35),
                .init(id: "house", weight: 12),
                .init(id: "tree", weight: 10)
            ],
            mods: .init(spawnIntensityMult: 1.12, staminaDrainMult: 1.05, hungerDrainMult: 1.04, scentGainMult: 1.03, fogExtra: 0.0)
        ),

        BiomeConfig(
            id: .stormNight,
            displayName: "Storm Night",
            obstaclePool: [
                .init(id: "puddle", weight: 25),
                .init(id: "fallenSign", weight: 25),
                .init(id: "fence", weight: 20),
                .init(id: "trashcan", weight: 20),
                .init(id: "wire", weight: 10)
            ],
            pickupPool: [
                .init(id: "foodSmall", weight: 52),
                .init(id: "foodBig", weight: 16),
                .init(id: "rareFood", weight: 9)
            ],
            hideSpotPool: [
                .init(id: "bush", weight: 25),
                .init(id: "tree", weight: 25),
                .init(id: "house", weight: 15),
                .init(id: "culvert", weight: 8)
            ],
            mods: .init(spawnIntensityMult: 1.05, staminaDrainMult: 1.04, hungerDrainMult: 1.02, scentGainMult: 0.90, fogExtra: 0.18)
        )
    ]

    static func config(for id: BiomeID) -> BiomeConfig {
        all.first(where: { $0.id == id })!
    }
}
