import Foundation

enum PlayerRank: String, Codable, CaseIterable {
    case stray
    case runner
    case streetSmart
    case survivor
    case escapeArtist
    case homebound
    case legend

    var displayName: String {
        switch self {
        case .stray: return "Stray"
        case .runner: return "Runner"
        case .streetSmart: return "Street-Smart"
        case .survivor: return "Survivor"
        case .escapeArtist: return "Escape Artist"
        case .homebound: return "Homebound"
        case .legend: return "Legend"
        }
    }
}

enum UnlockType: String, Codable {
    case biome
    case hideSpot
    case skin
    case perk
}

struct UnlockItem: Codable, Hashable, Identifiable {
    let key: String
    let type: UnlockType
    let name: String
    let description: String

    init(id: String, type: UnlockType, name: String, description: String) {
        self.key = id
        self.type = type
        self.name = name
        self.description = description
    }

    private enum CodingKeys: String, CodingKey {
        case key = "id"
        case type
        case name
        case description
    }

    var hashValueStable: String { "\(type.rawValue):\(key)" }
    var id: String { hashValueStable }
}

struct RankDefinition: Codable {
    let rank: PlayerRank
    let requiredXP: Int
    let rewardsPP: Int
    let unlocks: [UnlockItem]
}

struct RankCatalog {
    static let ranks: [RankDefinition] = [
        .init(rank: .stray, requiredXP: 0, rewardsPP: 0, unlocks: [
            UnlockItem(id: "suburb", type: .biome, name: "Suburbs", description: "Basic neighborhood run.")
        ]),

        .init(rank: .runner, requiredXP: 350, rewardsPP: 120, unlocks: [
            UnlockItem(id: "woods", type: .biome, name: "Woods", description: "Logs, mud, and tighter gaps."),
            UnlockItem(id: "bush", type: .hideSpot, name: "Bush", description: "Low-risk hide option.")
        ]),

        .init(rank: .streetSmart, requiredXP: 850, rewardsPP: 160, unlocks: [
            UnlockItem(id: "tree", type: .hideSpot, name: "Tree", description: "Medium risk, medium reward."),
            UnlockItem(id: "classic", type: .skin, name: "Classic Dog", description: "Default skin variant.")
        ]),

        .init(rank: .survivor, requiredXP: 1500, rewardsPP: 220, unlocks: [
            UnlockItem(id: "industrial", type: .biome, name: "Industrial", description: "Pipes, pallets, and chaos."),
            UnlockItem(id: "shed", type: .hideSpot, name: "Shed", description: "Medium risk, high reward.")
        ]),

        .init(rank: .escapeArtist, requiredXP: 2400, rewardsPP: 280, unlocks: [
            UnlockItem(id: "house", type: .hideSpot, name: "House", description: "High risk, high reward."),
            UnlockItem(id: "agile", type: .perk, name: "Agile Start", description: "Start with a small stamina boost.")
        ]),

        .init(rank: .homebound, requiredXP: 3600, rewardsPP: 350, unlocks: [
            UnlockItem(id: "stormNight", type: .biome, name: "Storm Night", description: "Fog + rain vibe."),
            UnlockItem(id: "culvert", type: .hideSpot, name: "Culvert", description: "High timing, very high reward.")
        ]),

        .init(rank: .legend, requiredXP: 5200, rewardsPP: 500, unlocks: [
            UnlockItem(id: "legend", type: .skin, name: "Legend Coat", description: "Flex skin."),
            UnlockItem(id: "shadow", type: .perk, name: "Shadow Step", description: "Scent decays faster for 10s after checkpoint.")
        ])
    ]

    static func def(for rank: PlayerRank) -> RankDefinition {
        ranks.first(where: { $0.rank == rank })!
    }

    static func nextRank(after rank: PlayerRank) -> PlayerRank? {
        let all = PlayerRank.allCases
        guard let idx = all.firstIndex(of: rank) else { return nil }
        let next = idx + 1
        guard next < all.count else { return nil }
        return all[next]
    }
}
