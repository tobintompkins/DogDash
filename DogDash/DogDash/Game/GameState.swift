import SwiftUI

final class GameState: ObservableObject {
    @Published var homeProgress: CGFloat = 0
    @Published var speedMultiplier: CGFloat = 1

    // Batch 10
    @Published var isAdrenalineActive: Bool = false
    @Published var scent: CGFloat = 0
    @Published var catcherPressure: CGFloat = 1.0

    // Batch 11
    @Published var currentLaneZone: String = "safe" // "safe" | "risk" | "shortcut"
    @Published var currentBiome: String = "suburb"  // BiomeID rawValue

    // Run stats (for progression)
    @Published var pawPointsEarnedThisRun: Int = 0
    @Published var distanceThisRun: Int = 0

    // Run end state (synced from GameViewModel)
    @Published var isRunOver: Bool = false
    @Published var didWin: Bool = false

    // Daily challenge
    @Published var dailyTitle: String = "Normal Run"
    @Published var dailyDescription: String = ""
    @Published var runModifiers: RunModifiers = RunModifiers()

    // Daily missions + streak
    @Published var dailyMissions: [Mission] = []
    @Published var streakMultiplier: Double = 1.0
    @Published var ppFromMissionsThisRun: Int = 0
    @Published var missionsCompletedToday: Int = 0

    // Rank-up popup (set when run ends with rank up)
    @Published var showRankUp: Bool = false
    @Published var rankUpNewRank: String = "" // PlayerRank rawValue
    @Published var rankUpRewardPP: Int = 0
    @Published var rankUpUnlocks: [String] = [] // unlock keys for display

    // Juice / feedback
    @Published var dangerIntensity: CGFloat = 0.0   // 0..1
    @Published var lastJuiceEvent: String = ""      // optional debug

    // Weather
    @Published var weather: String = "clear"
    @Published var visibilityAlpha: CGFloat = 1.0
    @Published var scentGainMultiplier: CGFloat = 1.0
    @Published var scentDecayMultiplier: CGFloat = 1.0
}
