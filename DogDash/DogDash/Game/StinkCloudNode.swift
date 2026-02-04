import SpriteKit

final class StinkCloudNode: SKSpriteNode {
    init(y: CGFloat, lane: Int, laneSystem: LaneSystem) {
        super.init(texture: nil, color: .purple, size: CGSize(width: 150, height: 120))
        name = "stinkCloud"
        zPosition = 2
        alpha = 0.45
        position = CGPoint(x: laneSystem.x(for: lane), y: y)

        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.hazardZone
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.contactTestBitMask = PhysicsCategory.dog
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
