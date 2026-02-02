enum PhysicsCategory {
    static let none: UInt32     = 0
    static let dog: UInt32      = 1 << 0
    static let ground: UInt32   = 1 << 1
    static let obstacle: UInt32 = 1 << 2
    static let food: UInt32     = 1 << 3
    static let hideSpot: UInt32 = 1 << 4
}
