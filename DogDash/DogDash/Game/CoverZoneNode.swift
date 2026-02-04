import SpriteKit

final class CoverZoneNode: SKSpriteNode {
    init(y: CGFloat, lane: Int, laneSystem: LaneSystem) {
        super.init(texture: nil, color: .systemTeal, size: CGSize(width: 160, height: 140))
        name = "coverZone"
        zPosition = 2
        alpha = 0.35
        position = CGPoint(x: laneSystem.x(for: lane), y: y)

        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.coverZone
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.contactTestBitMask = PhysicsCategory.dog
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
