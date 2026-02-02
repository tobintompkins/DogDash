import Foundation

enum GamePhase {
    case ready
    case running
    case gameOver
}

final class GameViewModel: ObservableObject {
    @Published var phase: GamePhase = .ready

    @Published private(set) var score: Int = 0
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var isHiding: Bool = false
    @Published private(set) var catcher: Double = 1.0

    private let hideDuration: TimeInterval = 2.2
    private let hideCatcherDrainPerSecond: Double = 0.20
    private var hideEndTime: TimeInterval = 0

    var isGameOver: Bool { phase == .gameOver }

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

    func reset() {
        phase = .ready
        score = 0
        elapsed = 0
        isHiding = false
        catcher = 1.0
        hideEndTime = 0
    }

    func beginHide(nowElapsed: TimeInterval) {
        guard phase == .running else { return }
        isHiding = true
        hideEndTime = nowElapsed + hideDuration
        // immediate tiny relief when you enter hiding
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
    }

    func addBonusPoints(_ points: Int) {
        guard phase == .running else { return }
        score += points
    }

    func updateHiding(dt: TimeInterval, elapsed: TimeInterval) {
        guard isHiding else { return }
        catcher = clamp01(catcher - hideCatcherDrainPerSecond * dt)
        if elapsed >= hideEndTime {
            isHiding = false
        }
    }
}

private func clamp01(_ value: Double) -> Double {
    min(max(value, 0), 1)
}
