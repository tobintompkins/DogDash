import Foundation
import SpriteKit

final class AdrenalineSystem {
    private weak var scene: GameScene?

    private(set) var isActive: Bool = false
    private var activeTimer: TimeInterval = 0
    private var cooldownTimer: TimeInterval = 0

    // Tuning
    private let triggerStaminaThreshold: Double = 0.18  // 0...1 scale
    private let activeDuration: TimeInterval = 4.0
    private let cooldownDuration: TimeInterval = 10.0

    // Buffs
    private let speedBoost: CGFloat = 1.25
    private let jumpBoost: CGFloat = 1.15

    init(scene: GameScene) {
        self.scene = scene
    }

    func update(delta: TimeInterval) {
        guard let scene else { return }

        if cooldownTimer > 0 {
            cooldownTimer = max(0, cooldownTimer - delta)
        }

        // Auto-trigger when stamina low
        if !isActive, cooldownTimer == 0, scene.stamina <= triggerStaminaThreshold {
            activate()
        }

        if isActive {
            activeTimer += delta
            if activeTimer >= activeDuration {
                deactivate()
            }
        }
    }

    private func activate() {
        guard let scene else { return }
        isActive = true
        activeTimer = 0

        scene.jumpPower *= jumpBoost
        scene.gameState.isAdrenalineActive = true
    }

    private func deactivate() {
        guard let scene else { return }
        isActive = false
        cooldownTimer = cooldownDuration

        scene.jumpPower /= jumpBoost
        scene.gameState.isAdrenalineActive = false
    }
}
