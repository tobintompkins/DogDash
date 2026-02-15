enum PhysicsCategory {
    static let none: UInt32      = 0
    static let dog: UInt32       = 1 << 0
    static let ground: UInt32    = 1 << 1
    static let obstacle: UInt32  = 1 << 2
    static let food: UInt32      = 1 << 3
    static let hideSpot: UInt32  = 1 << 4
    static let checkpoint: UInt32 = 1 << 5
    static let animal: UInt32     = 1 << 6
    static let hazardZone: UInt32 = 1 << 7
    static let bear: UInt32       = 1 << 8
    static let coverZone: UInt32     = 1 << 9
    static let lightningZone: UInt32 = 1 << 10
    static let icePatch: UInt32 = 1 << 11

    // Batch 11
    static let laneZone: UInt32 = 1 << 12
}
