import Foundation
import GameKit
import SwiftUI

@MainActor
final class GameCenterManager: ObservableObject {
    static let shared = GameCenterManager()

    @Published private(set) var isAuthenticated: Bool = false
    @Published private(set) var playerName: String = ""

    private init() {}

    func authenticate() {
        let player = GKLocalPlayer.local
        player.authenticateHandler = { [weak self] vc, error in
            if let vc {
                NotificationCenter.default.post(name: .gcNeedsPresentAuthVC, object: vc)
                return
            }

            if let error {
                print("Game Center auth error:", error.localizedDescription)
            }

            Task { @MainActor in
                self?.isAuthenticated = player.isAuthenticated
                self?.playerName = player.displayName
            }
        }
    }

    func submitScore(_ value: Int, leaderboardID: String) {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        let score = GKScore(leaderboardIdentifier: leaderboardID)
        score.value = Int64(value)
        GKScore.report([score]) { error in
            if let error { print("GC score report error:", error.localizedDescription) }
        }
    }

    func unlockAchievement(_ id: String, percent: Double = 100) {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        let ach = GKAchievement(identifier: id)
        ach.percentComplete = percent
        ach.showsCompletionBanner = true
        GKAchievement.report([ach]) { error in
            if let error { print("GC achievement report error:", error.localizedDescription) }
        }
    }

    func showLeaderboards() {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        let vc = GKGameCenterViewController(state: .leaderboards)
        vc.gameCenterDelegate = GCDelegate.shared
        NotificationCenter.default.post(name: .gcNeedsPresentGCVC, object: vc)
    }

    func showAchievements() {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        let vc = GKGameCenterViewController(state: .achievements)
        vc.gameCenterDelegate = GCDelegate.shared
        NotificationCenter.default.post(name: .gcNeedsPresentGCVC, object: vc)
    }
}

final class GCDelegate: NSObject, GKGameCenterControllerDelegate {
    static let shared = GCDelegate()
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}

extension Notification.Name {
    static let gcNeedsPresentAuthVC = Notification.Name("gcNeedsPresentAuthVC")
    static let gcNeedsPresentGCVC = Notification.Name("gcNeedsPresentGCVC")
}

struct GameCenterPresenter: UIViewControllerRepresentable {
    @Binding var presentVC: UIViewController?

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard let presentVC else { return }
        uiViewController.present(presentVC, animated: true)
        DispatchQueue.main.async { self.presentVC = nil }
    }
}
