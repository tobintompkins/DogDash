import Foundation

final class StreakTracker: ObservableObject {
    @Published private(set) var streakCount: Int = 0

    private let keyStreak = "DogDash_StreakCount_v1"
    private let keyLastDate = "DogDash_LastLoginDate_v1"

    init() {
        load()
        bumpIfNeededForToday()
    }

    func multiplier() -> Double {
        // +5% per day, max 7 days => +35%
        let capped = min(streakCount, 7)
        return 1.0 + (Double(capped) * 0.05)
    }

    private func bumpIfNeededForToday() {
        let today = dateKey(Date())
        let last = UserDefaults.standard.string(forKey: keyLastDate)

        if last == nil {
            streakCount = 1
            save(todayKey: today)
            return
        }

        if last == today {
            // already counted today
            return
        }

        let yesterdayKey = dateKey(Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())
        if last == yesterdayKey {
            streakCount += 1
        } else {
            streakCount = 1
        }

        save(todayKey: today)
    }

    private func load() {
        streakCount = UserDefaults.standard.integer(forKey: keyStreak)
        if streakCount <= 0 { streakCount = 0 }
    }

    private func save(todayKey: String) {
        UserDefaults.standard.set(streakCount, forKey: keyStreak)
        UserDefaults.standard.set(todayKey, forKey: keyLastDate)
    }

    private func dateKey(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar.current
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        f.dateFormat = "yyyyMMdd"
        return f.string(from: date)
    }
}
