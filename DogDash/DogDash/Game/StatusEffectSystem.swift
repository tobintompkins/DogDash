import Foundation

struct StatusEffect {
    let type: StatusEffectType
    var remaining: TimeInterval
}

final class StatusEffectSystem {

    private(set) var effects: [StatusEffectType: StatusEffect] = [:]

    func reset() {
        effects.removeAll()
    }

    func add(_ type: StatusEffectType, duration: TimeInterval) {
        if var existing = effects[type] {
            existing.remaining = max(existing.remaining, duration)
            effects[type] = existing
        } else {
            effects[type] = StatusEffect(type: type, remaining: duration)
        }
    }

    func update(dt: TimeInterval) {
        guard dt > 0 else { return }
        for (k, var e) in effects {
            e.remaining -= dt
            if e.remaining <= 0 {
                effects.removeValue(forKey: k)
            } else {
                effects[k] = e
            }
        }
    }

    func isActive(_ type: StatusEffectType) -> Bool {
        return effects[type] != nil
    }

    func activeList() -> [StatusEffect] {
        return effects.values.sorted { $0.type.displayName < $1.type.displayName }
    }
}
