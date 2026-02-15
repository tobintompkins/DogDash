import Foundation

final class DailyChallengeSystem {

    // Simple deterministic daily pick using yyyyMMdd + seed
    func todaysChallenge() -> DailyChallenge {
        let key = dateKey()
        let seed = stableHash(key)

        let list = DailyChallenge.presets

        // Pick deterministic index
        let idx = abs(seed) % list.count
        return list[idx]
    }

    private func dateKey() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: Date())
    }

    private func stableHash(_ s: String) -> Int {
        // FNV-1a-ish stable hash (simple)
        var hash: UInt64 = 1469598103934665603
        let prime: UInt64 = 1099511628211
        for b in s.utf8 {
            hash ^= UInt64(b)
            hash &*= prime
        }
        return Int(truncatingIfNeeded: hash)
    }
}
