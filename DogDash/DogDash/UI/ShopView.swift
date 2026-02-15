import SwiftUI

struct ShopView: View {
    @ObservedObject var store: ProgressionStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("Paw Points")
                        Spacer()
                        Text("\(store.data.pawPoints)")
                            .font(.headline)
                    }
                    HStack {
                        Text("Best Distance")
                        Spacer()
                        Text("\(store.data.bestDistance)")
                            .font(.headline)
                    }
                }

                ForEach(UpgradeBranch.allCases, id: \.rawValue) { branch in
                    Section(header: Text(branch.displayName)) {
                        let items = UpgradeCatalog.all.filter { $0.branch == branch }
                        ForEach(items, id: \.id) { def in
                            UpgradeRow(def: def, level: store.level(for: def.id)) {
                                _ = store.buy(def.id)
                            } canBuy: {
                                store.canBuy(def.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Upgrade Shop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct UpgradeRow: View {
    let def: UpgradeDefinition
    let level: Int
    let buy: () -> Void
    let canBuy: () -> Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(def.name)
                    .font(.headline)
                Spacer()
                Text("Lv \(level)/\(def.maxLevel)")
                    .font(.subheadline)
                    .opacity(0.8)
            }

            Text(def.description)
                .font(.caption)
                .opacity(0.85)

            HStack {
                let next = min(level + 1, def.maxLevel)
                let costText = level >= def.maxLevel ? "MAX" : "\(def.cost(for: next)) PP"

                Text(costText)
                    .font(.caption.bold())
                    .opacity(0.9)

                Spacer()

                Button(level >= def.maxLevel ? "Maxed" : "Buy") {
                    buy()
                }
                .disabled(!canBuy())
            }
        }
        .padding(.vertical, 6)
    }
}
