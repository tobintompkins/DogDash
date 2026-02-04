import Foundation

enum WeatherState {
    case clear
    case thunderstorm
    case snowstorm
}

final class WeatherSystem {

    private(set) var state: WeatherState = .clear

    // Timing
    var clearMin: TimeInterval = 16
    var clearMax: TimeInterval = 28

    var stormMin: TimeInterval = 14
    var stormMax: TimeInterval = 22

    var snowMin: TimeInterval = 16
    var snowMax: TimeInterval = 26

    // Cover timer (thunder only)
    var coverDeadlineSeconds: TimeInterval = 6.0

    // Chances when leaving CLEAR
    var thunderChance: Double = 0.55
    var snowChance: Double = 0.45

    private var nextStateChangeTime: TimeInterval = 0
    private var stateEndTime: TimeInterval = 0

    // Cover challenge (thunder only)
    private(set) var coverActive: Bool = false
    private(set) var coverRemaining: TimeInterval = 0

    func reset(now: TimeInterval) {
        state = .clear
        coverActive = false
        coverRemaining = 0
        scheduleNextClear(now: now)
    }

    func update(now: TimeInterval, dt: TimeInterval) {
        switch state {
        case .clear:
            if now >= nextStateChangeTime {
                let roll = Double.random(in: 0...1)
                if roll < thunderChance {
                    beginThunder(now: now)
                } else {
                    beginSnow(now: now)
                }
            }

        case .thunderstorm:
            if coverActive {
                coverRemaining = max(0, coverRemaining - dt)
            }
            if now >= stateEndTime {
                endToClear(now: now)
            }

        case .snowstorm:
            if now >= stateEndTime {
                endToClear(now: now)
            }
        }
    }

    private func beginThunder(now: TimeInterval) {
        state = .thunderstorm
        let duration = TimeInterval.random(in: stormMin...stormMax)
        stateEndTime = now + duration

        coverActive = true
        coverRemaining = coverDeadlineSeconds
    }

    private func beginSnow(now: TimeInterval) {
        state = .snowstorm
        let duration = TimeInterval.random(in: snowMin...snowMax)
        stateEndTime = now + duration

        coverActive = false
        coverRemaining = 0
    }

    private func endToClear(now: TimeInterval) {
        state = .clear
        coverActive = false
        coverRemaining = 0
        scheduleNextClear(now: now)
    }

    private func scheduleNextClear(now: TimeInterval) {
        let delay = TimeInterval.random(in: clearMin...clearMax)
        nextStateChangeTime = now + delay
    }

    func playerFoundCover() {
        coverActive = false
        coverRemaining = 0
    }

    func triggerNewCoverChallenge() {
        coverActive = true
        coverRemaining = coverDeadlineSeconds
    }
}
