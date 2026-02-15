import Foundation

enum WeightedPicker {
    static func pick(_ items: [WeightedItem]) -> String? {
        let total = items.reduce(0) { $0 + max(0, $1.weight) }
        guard total > 0 else { return nil }
        let roll = Int.random(in: 1...total)
        var run = 0
        for it in items {
            run += max(0, it.weight)
            if roll <= run { return it.id }
        }
        return items.last?.id
    }
}
