import SpriteKit

final class SkunkNode: SKSpriteNode {
    init(y: CGFloat, lane: Int, laneSystem: LaneSystem) {
        super.init(texture: nil, color: .magenta, size: CGSize(width: 85, height: 65))
        name = "skunk"
        zPosition = 6
        position = CGPoint(x: laneSystem.x(for: lane), y: y)

        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.animal
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.contactTestBitMask = PhysicsCategory.dog
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
