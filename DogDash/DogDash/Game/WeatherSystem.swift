import Foundation
import SpriteKit

enum WeatherType: String, CaseIterable {
    case clear
    case rain
    case snow
    case fog
    case heat
}

struct WeatherModifiers {
    var scentGainMultiplier: CGFloat      // multiplies scent gains (jump/slide/sprint)
    var scentDecayMultiplier: CGFloat     // multiplies scent passive decay
    var staminaDrainPerSec: CGFloat // extra drain per second
    var hungerDrainPerSec: CGFloat  // extra drain per second
    var spawnIntensityMult: CGFloat // affects obstacle spawn rate/intensity
    var visibilityAlpha: CGFloat    // 1.0 normal, lower = fog overlay stronger
}

final class WeatherSystem {
    private weak var scene: GameScene?
    private var timer: TimeInterval = 0
    private var nextChangeIn: TimeInterval = 30

    private(set) var current: WeatherType = .clear

    init(scene: GameScene) {
        self.scene = scene
        rollNextInterval()
        applyWeather(.clear)
    }

    func update(delta: TimeInterval) {
        timer += delta
        if timer >= nextChangeIn {
            timer = 0
            rollNextInterval()
            let newWeather = WeatherType.allCases.randomElement() ?? .clear
            applyWeather(newWeather)
        }
    }

    func modifiers(for weather: WeatherType) -> WeatherModifiers {
        switch weather {
        case .clear:
            return .init(scentGainMultiplier: 1.0, scentDecayMultiplier: 1.0,
                         staminaDrainPerSec: 0.0, hungerDrainPerSec: 0.0,
                         spawnIntensityMult: 1.0, visibilityAlpha: 1.0)

        case .rain:
            return .init(scentGainMultiplier: 0.85, scentDecayMultiplier: 1.35,
                         staminaDrainPerSec: 0.6, hungerDrainPerSec: 0.2,
                         spawnIntensityMult: 1.05, visibilityAlpha: 1.0)

        case .snow:
            return .init(scentGainMultiplier: 0.95, scentDecayMultiplier: 1.05,
                         staminaDrainPerSec: 1.2, hungerDrainPerSec: 0.8,
                         spawnIntensityMult: 0.92, visibilityAlpha: 1.0)

        case .fog:
            return .init(scentGainMultiplier: 1.05, scentDecayMultiplier: 1.0,
                         staminaDrainPerSec: 0.4, hungerDrainPerSec: 0.3,
                         spawnIntensityMult: 0.95, visibilityAlpha: 0.65)

        case .heat:
            return .init(scentGainMultiplier: 1.10, scentDecayMultiplier: 0.90,
                         staminaDrainPerSec: 1.3, hungerDrainPerSec: 1.1,
                         spawnIntensityMult: 1.12, visibilityAlpha: 1.0)
        }
    }

    var currentModifiers: WeatherModifiers {
        modifiers(for: current)
    }

    private func rollNextInterval() {
        nextChangeIn = TimeInterval.random(in: 25...45)
    }

    func reset() {
        current = .clear
        timer = 0
        rollNextInterval()
        applyWeather(.clear)
    }

    func playerFoundCover() {
        // Optional: apply temporary cover benefit when in CoverZone
    }

    private func applyWeather(_ weather: WeatherType) {
        current = weather
        guard let scene else { return }
        let mods = modifiers(for: weather)

        scene.gameState.weather = weather.rawValue
        scene.gameState.visibilityAlpha = mods.visibilityAlpha
        scene.gameState.scentGainMultiplier = mods.scentGainMultiplier
        scene.gameState.scentDecayMultiplier = mods.scentDecayMultiplier
    }
}
