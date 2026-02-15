import SwiftUI

struct RankView: View {
    @ObservedObject var store: ProgressionStore

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("Rank")
                        Spacer()
                        Text(store.data.rank.displayName)
                            .font(.headline)
                    }

                    HStack {
                        Text("Total XP")
                        Spacer()
                        Text("\(store.data.totalXP)")
                            .font(.headline)
                    }

                    ProgressView(value: progressToNext())
                }

                Section(header: Text("Unlocked")) {
                    ForEach(store.data.unlocked.sorted(by: { $0 < $1 }), id: \.self) { key in
                        Text(key)
                            .font(.caption)
                            .opacity(0.9)
                    }
                }
            }
            .navigationTitle("Rank & Unlocks")
        }
    }

    private func progressToNext() -> Double {
        let current = store.data.rank
        guard let next = RankCatalog.nextRank(after: current) else { return 1.0 }
        let curDef = RankCatalog.def(for: current)
        let nextDef = RankCatalog.def(for: next)

        let t = Double(store.data.totalXP - curDef.requiredXP)
        let d = Double(nextDef.requiredXP - curDef.requiredXP)
        if d <= 0 { return 1.0 }
        return min(1.0, max(0.0, t / d))
    }
}
