import SpriteKit

final class MountainLionNode: SKSpriteNode {
    init(y: CGFloat, lane: Int, laneSystem: LaneSystem) {
        super.init(texture: nil, color: .orange, size: CGSize(width: 120, height: 85))
        name = "mountainLion"
        zPosition = 7
        position = CGPoint(x: laneSystem.x(for: lane), y: y)

        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.animal
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.contactTestBitMask = PhysicsCategory.dog
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
