import Foundation
import SwiftUI

struct PlayerProgression: Codable {
    var pawPoints: Int = 0
    var upgrades: [UpgradeID: Int] = [:] // level map
    var bestDistance: Int = 0
}

final class ProgressionStore: ObservableObject {
    @Published private(set) var data: PlayerProgression

    private let key = "DogDash_Progression_v1"

    init() {
        self.data = PlayerProgression()
        load()
    }

    func load() {
        guard let raw = UserDefaults.standard.data(forKey: key) else { return }
        do {
            let decoded = try JSONDecoder().decode(PlayerProgression.self, from: raw)
            self.data = decoded
        } catch {
            // If decode fails, keep defaults
        }
    }

    func save() {
        do {
            let raw = try JSONEncoder().encode(data)
            UserDefaults.standard.set(raw, forKey: key)
        } catch {
            // ignore save errors for now
        }
    }

    func level(for id: UpgradeID) -> Int {
        data.upgrades[id, default: 0]
    }

    func canBuy(_ id: UpgradeID) -> Bool {
        let def = UpgradeCatalog.definition(for: id)
        let current = level(for: id)
        guard current < def.maxLevel else { return false }
        let nextLevel = current + 1
        return data.pawPoints >= def.cost(for: nextLevel)
    }

    func buy(_ id: UpgradeID) -> Bool {
        guard canBuy(id) else { return false }
        let def = UpgradeCatalog.definition(for: id)
        let current = level(for: id)
        let nextLevel = current + 1
        let cost = def.cost(for: nextLevel)

        data.pawPoints -= cost
        data.upgrades[id] = nextLevel
        save()
        objectWillChange.send()
        return true
    }

    func addPawPoints(_ amount: Int) {
        guard amount > 0 else { return }
        data.pawPoints += amount
        save()
        objectWillChange.send()
    }

    func submitRun(distance: Int) {
        if distance > data.bestDistance {
            data.bestDistance = distance
        }
        save()
        objectWillChange.send()
    }
}
