import Foundation
import SwiftUI
import CoreGraphics

struct AppliedUpgrades {
    var maxStaminaBonus: CGFloat = 0
    var staminaDrainMultiplier: CGFloat = 1.0
    var adrenalineCooldownMultiplier: CGFloat = 1.0

    var scentGainMultiplier: CGFloat = 1.0
    var hideScentBonusMultiplier: CGFloat = 1.0
    var hideWindowBonus: CGFloat = 0.0

    var pickupSpawnMultiplier: CGFloat = 1.0
    var hungerDrainMultiplier: CGFloat = 1.0
    var rareFoodBonusChance: CGFloat = 0.0
}

enum UpgradeApplier {
    static func build(from store: ProgressionStore) -> AppliedUpgrades {
        var a = AppliedUpgrades()

        // Endurance
        let ironLegs = store.level(for: UpgradeID.ironLegs)
        a.maxStaminaBonus = CGFloat(ironLegs) * 10

        let slowBurn = store.level(for: UpgradeID.slowBurn)
        a.staminaDrainMultiplier *= (1.0 - CGFloat(slowBurn) * 0.06)

        let deepBreath = store.level(for: UpgradeID.deepBreath)
        a.adrenalineCooldownMultiplier *= (1.0 - CGFloat(deepBreath) * 0.10)

        // Stealth
        let quietSteps = store.level(for: UpgradeID.quietSteps)
        a.scentGainMultiplier *= (1.0 - CGFloat(quietSteps) * 0.08)

        let scentDrop = store.level(for: UpgradeID.scentDrop)
        a.hideScentBonusMultiplier *= (1.0 + CGFloat(scentDrop) * 0.10)

        let fastHide = store.level(for: UpgradeID.fastHide)
        a.hideWindowBonus += CGFloat(fastHide) * 0.15

        // Scavenger
        let sharpNose = store.level(for: UpgradeID.sharpNose)
        a.pickupSpawnMultiplier *= (1.0 + CGFloat(sharpNose) * 0.06)

        let fullBelly = store.level(for: UpgradeID.fullBelly)
        a.hungerDrainMultiplier *= (1.0 - CGFloat(fullBelly) * 0.06)

        let luckyFind = store.level(for: UpgradeID.luckyFind)
        a.rareFoodBonusChance += CGFloat(luckyFind) * 0.02

        // Clamp safety
        a.staminaDrainMultiplier = max(0.6, a.staminaDrainMultiplier)
        a.hungerDrainMultiplier = max(0.6, a.hungerDrainMultiplier)
        a.scentGainMultiplier = max(0.65, a.scentGainMultiplier)

        return a
    }
}
