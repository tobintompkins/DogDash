import Foundation

final class DailyMissionSystem {
    private let key = "DogDash_DailyMissions_v1"
    private let keyDate = "DogDash_DailyMissionsDate_v1"

    func loadOrGenerateMissions() -> [Mission] {
        let today = dateKey()

        if UserDefaults.standard.string(forKey: keyDate) == today,
           let raw = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Mission].self, from: raw) {
            return decoded
        }

        let missions = generateForToday()
        if let raw = try? JSONEncoder().encode(missions) {
            UserDefaults.standard.set(raw, forKey: key)
            UserDefaults.standard.set(today, forKey: keyDate)
        }
        return missions
    }

    private func generateForToday() -> [Mission] {
        let seed = stableHash(dateKey())
        var rng = SeededRNG(seed: UInt64(bitPattern: Int64(seed)))

        // Pick 3 mission types (no duplicates)
        var types = MissionType.allCases
        types.shuffle(using: &rng)
        let picked = Array(types.prefix(3))

        return picked.map { type in
            buildMission(type: type, rng: &rng)
        }
    }

    private func buildMission(type: MissionType, rng: inout SeededRNG) -> Mission {
        switch type {
        case .passCheckpoints:
            let target = [2, 3, 4].randomElement(using: &rng) ?? 3
            return Mission(
                id: "cp_\(target)",
                type: .passCheckpoints,
                title: "Pass \(target) checkpoints",
                target: target,
                rewardPP: 60 + target * 15
            )

        case .successfulHides:
            let target = [3, 4, 5].randomElement(using: &rng) ?? 4
            return Mission(
                id: "hide_\(target)",
                type: .successfulHides,
                title: "Hide successfully \(target) times",
                target: target,
                rewardPP: 65 + target * 12
            )

        case .collectFood:
            let target = [5, 6, 7].randomElement(using: &rng) ?? 6
            return Mission(
                id: "food_\(target)",
                type: .collectFood,
                title: "Collect \(target) food",
                target: target,
                rewardPP: 55 + target * 10
            )

        case .surviveSeconds:
            let target = [60, 75, 90].randomElement(using: &rng) ?? 75
            return Mission(
                id: "survive_\(target)",
                type: .surviveSeconds,
                title: "Survive \(target)s",
                target: target,
                rewardPP: 80 + (target / 15) * 10
            )

        case .reachDistance:
            let target = [600, 800, 1000].randomElement(using: &rng) ?? 800
            return Mission(
                id: "dist_\(target)",
                type: .reachDistance,
                title: "Reach distance \(target)",
                target: target,
                rewardPP: 90 + (target / 200) * 20
            )
        }
    }

    private func dateKey() -> String {
        let f = DateFormatter()
        f.calendar = Calendar.current
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        f.dateFormat = "yyyyMMdd"
        return f.string(from: Date())
    }

    private func stableHash(_ s: String) -> Int {
        var hash: UInt64 = 1469598103934665603
        let prime: UInt64 = 1099511628211
        for b in s.utf8 {
            hash ^= UInt64(b)
            hash &*= prime
        }
        return Int(truncatingIfNeeded: hash)
    }
}

/// Deterministic RNG (so daily missions are stable)
struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 0x12345678ABCDEF01 : seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
