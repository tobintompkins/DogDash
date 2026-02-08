import SpriteKit

enum BearRequirement {
    case jump
    case slide
}

final class BearNode: SKSpriteNode {
    let requirement: BearRequirement

    init(requirement: BearRequirement, y: CGFloat, lane: Int, laneSystem: LaneSystem) {
        self.requirement = requirement
        super.init(texture: nil, color: .brown, size: CGSize(width: 150, height: 120))
        name = "bear"
        zPosition = 6
        position = CGPoint(x: laneSystem.x(for: lane), y: y)

        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.bear
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.contactTestBitMask = PhysicsCategory.dog
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
