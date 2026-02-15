import Foundation

final class BiomeSystem {
    private weak var scene: GameScene?

    private(set) var currentBiome: BiomeID = .suburb
    private var unlockedBiomes: [BiomeID] = [.suburb]

    // rotation tuning
    private var checkpointCounter = 0
    private let rotateEveryCheckpoints = 1 // change to 2 if you want slower rotation

    init(scene: GameScene) {
        self.scene = scene
    }

    func configureUnlocked(from store: ProgressionStore?) {
        // unlocked keys are stored like "biome:woods"
        guard let store else {
            unlockedBiomes = [.suburb]
            return
        }

        var list: [BiomeID] = []
        for id in BiomeID.allCases {
            let key = "biome:\(id.rawValue)"
            if store.data.unlocked.contains(key) { list.append(id) }
        }

        // Safety fallback
        if list.isEmpty { list = [.suburb] }
        unlockedBiomes = list

        // Ensure current biome is valid
        if !unlockedBiomes.contains(currentBiome) {
            currentBiome = unlockedBiomes.first ?? .suburb
        }
    }

    func onCheckpointPassed() {
        checkpointCounter += 1
        guard checkpointCounter % rotateEveryCheckpoints == 0 else { return }
        rotateBiome()
    }

    private func rotateBiome() {
        guard let scene else { return }
        guard !unlockedBiomes.isEmpty else { return }

        // pick a different biome if possible
        let candidates = unlockedBiomes.filter { $0 != currentBiome }
        let next = (candidates.randomElement() ?? unlockedBiomes.randomElement()) ?? .suburb
        setBiome(next)

        // A tiny "you entered biome" bump
        scene.onBiomeChanged()
    }

    func setBiome(_ id: BiomeID) {
        currentBiome = id
        applyBiomeEffects()
    }

    func config() -> BiomeConfig {
        BiomeCatalog.config(for: currentBiome)
    }

    private func applyBiomeEffects() {
        guard let scene else { return }
        let cfg = config()

        // Apply biome multipliers into scene knobs
        scene.biomeSpawnMult = cfg.mods.spawnIntensityMult
        scene.biomeStaminaDrainMult = cfg.mods.staminaDrainMult
        scene.biomeHungerDrainMult = cfg.mods.hungerDrainMult
        scene.biomeScentGainMult = cfg.mods.scentGainMult
        scene.biomeFogExtra = cfg.mods.fogExtra

        scene.gameStateRef?.currentBiome = cfg.id.rawValue
    }
}
