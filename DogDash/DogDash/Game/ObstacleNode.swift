import SpriteKit

enum ObstacleType: CaseIterable {
    case rock   // jump
    case log    // slide
    case root   // jump

    /// Map biome obstacle IDs to ObstacleType
    static func from(id: String) -> ObstacleType {
        switch id.lowercased() {
        case "log", "mud": return .log
        case "root", "branch": return .root
        case "rock", "trashcan", "fence", "cone", "bicycle", "pallet", "pipe", "crate", "barrel", "puddle", "fallenSign", "wire": return .rock
        default: return .rock
        }
    }

    var color: SKColor {
        switch self {
        case .rock: return .gray
        case .log:  return .brown
        case .root: return .orange
        }
    }

    var size: CGSize {
        switch self {
        case .rock: return CGSize(width: 90, height: 70)
        case .log:  return CGSize(width: 130, height: 60)
        case .root: return CGSize(width: 110, height: 55)
        }
    }

    var requiredMove: String {
        switch self {
        case .rock: return "JUMP"
        case .log:  return "SLIDE"
        case .root: return "JUMP"
        }
    }
}

final class ObstacleNode: SKSpriteNode {
    let obstacleType: ObstacleType

    init(type: ObstacleType) {
        self.obstacleType = type
        super.init(texture: nil, color: type.color, size: type.size)
        name = "obstacle"
        zPosition = 5

        physicsBody = SKPhysicsBody(rectangleOf: type.size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.contactTestBitMask = PhysicsCategory.dog
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
