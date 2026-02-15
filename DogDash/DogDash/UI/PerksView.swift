import SwiftUI

struct PerksView: View {
    @ObservedObject var store: ProgressionStore

    @State private var equipped: [PerkID] = []

    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("Equip up to 2 perks. Perks only work if unlocked by rank.")
                        .font(.caption)
                        .opacity(0.85)

                    HStack {
                        Text("Equipped")
                        Spacer()
                        Text(equipped.map { $0.rawValue }.joined(separator: ", "))
                            .font(.caption)
                            .opacity(0.8)
                    }
                }

                Section(header: Text("Perks")) {
                    ForEach(PerkCatalog.all, id: \.id) { def in
                        let unlocked = store.data.unlocked.contains(def.unlockKey)
                        let isEquipped = equipped.contains(def.perkId)

                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(def.name)
                                    .font(.headline)

                                Spacer()

                                Text(unlocked ? "UNLOCKED" : "LOCKED")
                                    .font(.caption.bold())
                                    .opacity(unlocked ? 0.9 : 0.5)
                            }

                            Text(def.description)
                                .font(.caption)
                                .opacity(0.85)

                            HStack {
                                Spacer()
                                Button(isEquipped ? "Unequip" : "Equip") {
                                    toggle(def.perkId, unlocked: unlocked)
                                }
                                .disabled(!unlocked)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("Perks")
            .onAppear {
                equipped = store.data.perkLoadout
            }
            .onDisappear {
                store.setPerkLoadout(equipped)
            }
        }
    }

    private func toggle(_ id: PerkID, unlocked: Bool) {
        guard unlocked else { return }

        if let idx = equipped.firstIndex(of: id) {
            equipped.remove(at: idx)
        } else {
            if equipped.count >= 2 { return } // max 2
            equipped.append(id)
        }
    }
}
