import Foundation
import SwiftUI

struct PlayerProgression: Codable {
    var pawPoints: Int = 0
    var upgrades: [UpgradeID: Int] = [:]
    var bestDistance: Int = 0
    var bestCheckpoints: Int = 0
    var bestPPRun: Int = 0

    var totalXP: Int = 0
    var rank: PlayerRank = .stray
    var unlocked: Set<String> = ["biome:suburb"]

    // Ramp F
    var perkLoadout: [PerkID] = []

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        pawPoints = try c.decodeIfPresent(Int.self, forKey: .pawPoints) ?? 0
        upgrades = try c.decodeIfPresent([UpgradeID: Int].self, forKey: .upgrades) ?? [:]
        bestDistance = try c.decodeIfPresent(Int.self, forKey: .bestDistance) ?? 0
        bestCheckpoints = try c.decodeIfPresent(Int.self, forKey: .bestCheckpoints) ?? 0
        bestPPRun = try c.decodeIfPresent(Int.self, forKey: .bestPPRun) ?? 0
        totalXP = try c.decodeIfPresent(Int.self, forKey: .totalXP) ?? 0
        rank = try c.decodeIfPresent(PlayerRank.self, forKey: .rank) ?? .stray
        let arr = try c.decodeIfPresent([String].self, forKey: .unlocked) ?? []
        unlocked = Set(arr.isEmpty ? ["biome:suburb"] : arr)
        let loadoutRaw = try c.decodeIfPresent([String].self, forKey: .perkLoadout) ?? []
        perkLoadout = loadoutRaw.compactMap { PerkID(rawValue: $0) }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(pawPoints, forKey: .pawPoints)
        try c.encode(upgrades, forKey: .upgrades)
        try c.encode(bestDistance, forKey: .bestDistance)
        try c.encode(bestCheckpoints, forKey: .bestCheckpoints)
        try c.encode(bestPPRun, forKey: .bestPPRun)
        try c.encode(totalXP, forKey: .totalXP)
        try c.encode(rank, forKey: .rank)
        try c.encode(Array(unlocked), forKey: .unlocked)
        try c.encode(perkLoadout.map { $0.rawValue }, forKey: .perkLoadout)
    }

    private enum CodingKeys: String, CodingKey {
        case pawPoints
        case upgrades
        case bestDistance
        case bestCheckpoints
        case bestPPRun
        case rank
        case totalXP
        case unlocked
        case perkLoadout
    }
}

final class ProgressionStore: ObservableObject {
    @Published private(set) var data: PlayerProgression

    private let key = "DogDash_Progression_v1"

    init() {
        self.data = PlayerProgression()
        load()
    }

    func load() {
        guard let raw = UserDefaults.standard.data(forKey: key) else { return }
        do {
            let decoded = try JSONDecoder().decode(PlayerProgression.self, from: raw)
            self.data = decoded
        } catch {
            // If decode fails, keep defaults
        }
    }

    func save() {
        do {
            let raw = try JSONEncoder().encode(data)
            UserDefaults.standard.set(raw, forKey: key)
        } catch {
            // ignore save errors for now
        }
    }

    func level(for id: UpgradeID) -> Int {
        data.upgrades[id, default: 0]
    }

    func canBuy(_ id: UpgradeID) -> Bool {
        let def = UpgradeCatalog.definition(for: id)
        let current = level(for: id)
        guard current < def.maxLevel else { return false }
        let nextLevel = current + 1
        return data.pawPoints >= def.cost(for: nextLevel)
    }

    func buy(_ id: UpgradeID) -> Bool {
        guard canBuy(id) else { return false }
        let def = UpgradeCatalog.definition(for: id)
        let current = level(for: id)
        let nextLevel = current + 1
        let cost = def.cost(for: nextLevel)

        data.pawPoints -= cost
        data.upgrades[id] = nextLevel
        save()
        objectWillChange.send()
        return true
    }

    func setPerkLoadout(_ perks: [PerkID]) {
        data.perkLoadout = Array(perks.prefix(2))
        save()
        objectWillChange.send()
    }

    func equippedPerks() -> [PerkID] {
        Array(data.perkLoadout.prefix(2))
    }

    func addPawPoints(_ amount: Int) {
        guard amount > 0 else { return }
        data.pawPoints += amount
        save()
        objectWillChange.send()
    }

    func addPawPointsWithMultiplier(_ base: Int, mult: Double) {
        let amount = Int(Double(base) * mult)
        addPawPoints(amount)
    }

    func submitRunStats(distance: Int, checkpoints: Int, ppEarnedThisRun: Int) {
        if distance > data.bestDistance { data.bestDistance = distance }
        if checkpoints > data.bestCheckpoints { data.bestCheckpoints = checkpoints }
        if ppEarnedThisRun > data.bestPPRun { data.bestPPRun = ppEarnedThisRun }
        save()
        objectWillChange.send()
    }

    func isUnlocked(_ item: UnlockItem) -> Bool {
        data.unlocked.contains(item.hashValueStable)
    }

    func unlock(_ item: UnlockItem) {
        data.unlocked.insert(item.hashValueStable)
        save()
        objectWillChange.send()
    }

    func unlockMany(_ items: [UnlockItem]) {
        for i in items { data.unlocked.insert(i.hashValueStable) }
        save()
        objectWillChange.send()
    }

    func applyRankRewardsIfNeeded(previousRank: PlayerRank, newRank: PlayerRank) -> (pp: Int, unlocks: [UnlockItem]) {
        var totalPP = 0
        var gained: [UnlockItem] = []

        let all = PlayerRank.allCases
        guard let fromIdx = all.firstIndex(of: previousRank),
              let toIdx = all.firstIndex(of: newRank),
              toIdx >= fromIdx else { return (0, []) }

        if fromIdx == toIdx { return (0, []) }

        for idx in (fromIdx + 1)...toIdx {
            let r = all[idx]
            let def = RankCatalog.def(for: r)
            totalPP += def.rewardsPP
            gained.append(contentsOf: def.unlocks)
        }

        if totalPP > 0 { data.pawPoints += totalPP }
        unlockMany(gained)
        save()
        objectWillChange.send()
        return (totalPP, gained)
    }

    func addXPAndRecalcRank(_ xp: Int) -> (didRankUp: Bool, newRank: PlayerRank, rewardsPP: Int, unlocks: [UnlockItem]) {
        guard xp > 0 else { return (false, data.rank, 0, []) }

        let previousRank = data.rank

        data.totalXP += xp
        let rankSystem = RankSystem()
        let newRank = rankSystem.currentRank(for: data.totalXP)
        data.rank = newRank
        save()
        objectWillChange.send()

        if newRank != previousRank {
            let rewards = applyRankRewardsIfNeeded(previousRank: previousRank, newRank: newRank)
            return (true, newRank, rewards.pp, rewards.unlocks)
        } else {
            return (false, newRank, 0, [])
        }
    }

}
