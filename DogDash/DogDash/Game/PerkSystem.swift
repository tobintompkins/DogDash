import Foundation

final class PerkSystem {
    private weak var scene: GameScene?

    // Active loadout (max 2)
    private(set) var equipped: [PerkID] = []

    // Shadow Step runtime
    private var shadowTimer: TimeInterval = 0
    private var shadowDecayMult: CGFloat = 1.0

    // Rare food bonus runtime
    private var rareFoodBonusChance: CGFloat = 0.0

    init(scene: GameScene) { self.scene = scene }

    func configure(equipped: [PerkID]) {
        self.equipped = Array(equipped.prefix(2))

        // reset runtime knobs
        shadowTimer = 0
        shadowDecayMult = 1.0
        rareFoodBonusChance = 0.0

        // precompute
        if self.equipped.contains(.scavengerLuck) {
            rareFoodBonusChance += PerkCatalog.def(.scavengerLuck).rareFoodBonusChance
        }
    }

    func onRunStart() {
        guard let scene else { return }
        if equipped.contains(.agileStart) {
            let bonus = PerkCatalog.def(.agileStart).staminaStartBonus
            scene.addStaminaPercent(bonus / 100)
        }
    }

    func onCheckpoint() {
        if equipped.contains(.shadowStep) {
            let def = PerkCatalog.def(.shadowStep)
            shadowTimer = def.shadowDuration
            shadowDecayMult = def.shadowDecayMultiplier
        }
    }

    func update(delta: TimeInterval) {
        if shadowTimer > 0 {
            shadowTimer -= delta
            if shadowTimer <= 0 {
                shadowTimer = 0
                shadowDecayMult = 1.0
            }
        }

        // Apply shadow decay multiplier to scent system decay (safe: overwrite each frame)
        scene?.perkScentDecayMultiplier = shadowDecayMult
    }

    func rareFoodExtraChance() -> CGFloat {
        rareFoodBonusChance
    }
}
