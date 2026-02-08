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

    // Run stats (for progression)
    @Published var pawPointsEarnedThisRun: Int = 0
    @Published var distanceThisRun: Int = 0

    // Daily challenge
    @Published var dailyTitle: String = "Normal Run"
    @Published var dailyDescription: String = ""
    @Published var runModifiers: RunModifiers = RunModifiers()

    // Weather
    @Published var weather: String = "clear"
    @Published var visibilityAlpha: CGFloat = 1.0
    @Published var scentGainMultiplier: CGFloat = 1.0
    @Published var scentDecayMultiplier: CGFloat = 1.0
}
