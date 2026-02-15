import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var store = ProgressionStore()
    @StateObject private var gc = GameCenterManager.shared

    @State private var pendingVC: UIViewController? = nil

    var body: some View {
        NavigationStack {
            MainMenuView(store: store)
                .onAppear {
                    gc.authenticate()
                }
                .onReceive(NotificationCenter.default.publisher(for: .gcNeedsPresentAuthVC)) { note in
                    if let vc = note.object as? UIViewController {
                        pendingVC = vc
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .gcNeedsPresentGCVC)) { note in
                    if let vc = note.object as? UIViewController {
                        pendingVC = vc
                    }
                }
        }
        .background(
            GameCenterPresenter(presentVC: $pendingVC)
                .frame(width: 0, height: 0)
        )
    }
}
    