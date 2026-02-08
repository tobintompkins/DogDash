import Foundation

final class ScentSystem {
    private weak var scene: GameScene?

    var scentGainMultiplier: CGFloat = 1.0
    var scentDecayMultiplier: CGFloat = 1.0

    // Tuning
    private let passiveDecayPerSecond: CGFloat = 2.0
    private let sprintGainPerSecond: CGFloat = 4.0
    private let jumpGain: CGFloat = 6.0
    private let slideGainPerSecond: CGFloat = 3.0

    init(scene: GameScene) {
        self.scene = scene
    }

    func update(delta: TimeInterval) {
        guard let scene else { return }
        var scent = scene.gameState.scent

        scent = max(0, scent - (passiveDecayPerSecond * scentDecayMultiplier) * CGFloat(delta))

        if self.scene?.isSprinting == true {
            scent = min(100, scent + (sprintGainPerSecond * scentGainMultiplier) * CGFloat(delta))
        }

        scene.gameState.scent = scent
        applyPressure()
    }

    func onJump() {
        guard let scene else { return }
        var scent = scene.gameState.scent
        scent = min(100, scent + (jumpGain * scentGainMultiplier))
        scene.gameState.scent = scent
    }

    func onSlide(delta: TimeInterval) {
        guard let scene else { return }
        var scent = scene.gameState.scent
        scent = min(100, scent + (slideGainPerSecond * scentGainMultiplier) * CGFloat(delta))
        scene.gameState.scent = scent
    }

    func reduceFromHide(strength: CGFloat) {
        guard let scene else { return }
        scene.gameState.scent = max(0, scene.gameState.scent - strength)
    }

    private func applyPressure() {
        guard let scene else { return }
        let t = scene.gameState.scent / 100
        scene.gameState.catcherPressure = 1.0 + (0.35 * t)
    }
}
