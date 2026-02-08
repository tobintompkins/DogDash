import Foundation

enum StatusEffectType: CaseIterable {
    case slowed
    case stink
    case panic

    var displayName: String {
        switch self {
        case .slowed: return "Slowed"
        case .stink: return "Stink"
        case .panic: return "Panic"
        }
    }
}
