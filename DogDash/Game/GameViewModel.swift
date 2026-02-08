import Foundation
import SwiftUI

enum GamePhase {
    case ready
    case running
    case gameOver
    case won
}

final class GameViewModel: ObservableObject {
    @Published var phase: GamePhase = .ready

    @Published private(set) var score: Int = 0
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var isHiding: Bool = false
    @Published private(set) var catcher: Double = 1.0
    @Published private(set) var homeProgress: Double = 0.0   // 0...1
    @Published private(set) var checkpointCount: Int = 0
    @Published private(set) var hunger: Double = 1.0   // 0...1
    @Published private(set) var stamina: Double = 1.0  // 0...1
    @Published private(set) var activeEffectsText: String = ""
    @Published private(set) var weatherText: String = "Clear"
    @Published private(set) var coverTimerText: String = ""
    @Published private(set) var weatherHintText: String = ""
    @Published private(set) var speedMultiplier: CGFloat = 1

    let gameState = GameState()

    private let hideDuration: TimeInterval = 2.2
    private let hideCatcherDrainPerSecond: Double = 0.20
    private var hideEndTime: TimeInterval = 0

    private let homeProgressPerCheckpoint: Double = 0.12  // ~8-9 checkpoints to win
    private let checkpointCatcherRelief: Double = 0.10
    private let checkpointHungerBoost: Double = 0.18
    private let checkpointStaminaBoost: Double = 0.12
    private let baseStaminaRegenPerSecond: Double = 0.08
    private let obstacleCatcherBump: Double = 0.18
    private let jumpStaminaCost: Double = 0.10
    private let slideStaminaCost: Double = 0.07

    var isGameOver: Bool { phase == .gameOver }
    var isWon: Bool { phase == .won }

    var scoreText: String { "\(score)" }
    var timeText: String {
        let seconds = Int(elapsed.rounded(.down))
        return "\(seconds)s"
    }

    func startIfNeeded() {
        if phase == .ready { phase = .running }
    }

    func triggerGameOver() {
        phase = .gameOver
    }

    func triggerWin() {
        phase = .won
    }

    func forceStaminaForAdrenalineStart() {
        stamina = min(stamina, 0.15)
    }

    func addStaminaCapacityBonus(_ bonus: CGFloat) {
        stamina = min(1.0, stamina + Double(bonus) / 100)
    }

    func reset() {
        phase = .ready
        score = 0
        elapsed = 0
        isHiding = false
        catcher = 1.0
        hideEndTime = 0
        homeProgress = 0.0
        checkpointCount = 0
        hunger = 1.0
        stamina = gameState.runModifiers.startWithAdrenaline ? 0.15 : 1.0
        activeEffectsText = ""
        weatherText = "Clear"
        coverTimerText = ""
        weatherHintText = ""
        speedMultiplier = 1
        gameState.pawPointsEarnedThisRun = 0
        gameState.distanceThisRun = 0
        gameState.homeProgress = 0
        gameState.speedMultiplier = 1
        gameState.isAdrenalineActive = false
        gameState.scent = 0
        gameState.catcherPressure = 1.0
        gameState.currentLaneZone = "safe"
        gameState.weather = "clear"
        gameState.visibilityAlpha = 1.0
        gameState.scentGainMultiplier = 1.0
        gameState.scentDecayMultiplier = 1.0
    }

    func beginHide(nowElapsed: TimeInterval) {
        beginHide(type: nil, nowElapsed: nowElapsed)
    }

    func beginHide(type: HideSpotType?, nowElapsed: TimeInterval) {
        guard phase == .running, !gameState.runModifiers.noHiding else { return }
        isHiding = true
        hideEndTime = nowElapsed + hideDuration
        catcher = clamp01(catcher - 0.06)
    }

    func exitHiding() {
        isHiding = false
    }

    func shouldPauseSpawns() -> Bool {
        isHiding
    }

    func tick(deltaTime: TimeInterval, distancePoints: Int) {
        guard phase == .running else { return }
        elapsed += deltaTime
        score += distancePoints
        gameState.distanceThisRun += distancePoints
    }

    func addBonusPoints(_ points: Int) {
        guard phase == .running else { return }
        let mult = gameState.runModifiers.scoreMultiplier
        score += max(0, Int(Double(points) * mult))
    }

    func awardPawPoints(_ amount: Int) {
        guard phase == .running, amount > 0 else { return }
        gameState.pawPointsEarnedThisRun += amount
    }

    func canSpendStamina(_ amount: Double) -> Bool {
        phase == .running && stamina >= amount
    }

    func spendForJump() {
        guard canSpendStamina(jumpStaminaCost) else { return }
        stamina = clamp01(stamina - jumpStaminaCost)
    }

    func spendForSlide() {
        guard canSpendStamina(slideStaminaCost) else { return }
        stamina = clamp01(stamina - slideStaminaCost)
    }

    func onObstacleHit() {
        guard phase == .running else { return }
        let bump = obstacleCatcherBump * Double(gameState.catcherPressure)
        catcher = clamp01(catcher + bump)
        if catcher >= 1.0 { triggerGameOver() }
    }

    func onFoodPickup() {
        addBonusPoints(25)
        awardPawPoints(3)
    }

    func setHomeProgress(_ value: Double) {
        homeProgress = clamp01(value)
        gameState.homeProgress = CGFloat(homeProgress)
    }

    func setSpeedMultiplier(_ value: CGFloat) {
        speedMultiplier = max(0.1, min(value, 3))
        gameState.speedMultiplier = speedMultiplier
    }

    func setActiveEffectsText(_ text: String) {
        activeEffectsText = text
    }

    func setWeatherText(_ text: String) {
        weatherText = text.prefix(1).uppercased() + text.dropFirst()
    }

    func applyStaminaHungerDrain(dt: TimeInterval, staminaDrainPerSec: CGFloat, hungerDrainPerSec: CGFloat) {
        guard phase == .running else { return }
        stamina = max(0, stamina - Double(staminaDrainPerSec) * dt)
        hunger = max(0, hunger - Double(hungerDrainPerSec) * dt)
    }

    func setWeatherHint(_ text: String) {
        weatherHintText = text
    }

    func setCoverTimer(_ t: TimeInterval?) {
        if let t {
            coverTimerText = "Find cover: \(max(0, Int(ceil(t))))s"
        } else {
            coverTimerText = ""
        }
    }

    func onStormFailPenalty() {
        catcher = clamp01(catcher + 0.18)
        stamina = clamp01(stamina - 0.20)
        if catcher >= 1.0 { triggerGameOver() }
    }

    func incrementCheckpoint() {
        checkpointCount += 1
    }

    func onCheckpointReached() {
        guard phase == .running else { return }

        checkpointCount += 1
        homeProgress = clamp01(homeProgress + homeProgressPerCheckpoint)
        gameState.homeProgress = CGFloat(homeProgress)

        // Reward burst
        hunger = clamp01(hunger + checkpointHungerBoost)
        stamina = clamp01(stamina + checkpointStaminaBoost)
        catcher = clamp01(catcher - checkpointCatcherRelief)

        awardPawPoints(50)

        // Win condition handled by GameScene.triggerWin()
    }

    func updateHiding(dt: TimeInterval, elapsed: TimeInterval) {
        guard isHiding else { return }
        catcher = clamp01(catcher - hideCatcherDrainPerSecond * dt)
        if elapsed >= hideEndTime {
            isHiding = false
        }
    }

    func updateStaminaRegen(dt: TimeInterval) {
        guard phase == .running else { return }
        var regen = baseStaminaRegenPerSecond * dt
        // Stink effect reduces stamina regen (extra layer)
        if activeEffectsText.contains("Stink") {
            regen *= 0.55
        }
        stamina = clamp01(stamina + regen)
    }
}

private func clamp01(_ value: Double) -> Double {
    min(max(value, 0), 1)
}
