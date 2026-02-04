import SpriteKit

final class DeerNode: SKSpriteNode {
    // Deer crosses lanes horizontally at a certain Y and can hit the dog if dog is in the crossing lane.

    let crossingLane: Int
    let laneSystem: LaneSystem

    init(crossingLane: Int, laneSystem: LaneSystem) {
        self.crossingLane = crossingLane
        self.laneSystem = laneSystem
        super.init(texture: nil, color: .white, size: CGSize(width: 110, height: 70))
        name = "deer"
        zPosition = 6

        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.animal
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.contactTestBitMask = PhysicsCategory.dog
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func runCross(atY y: CGFloat) {
        position = CGPoint(x: -520, y: y)
        let targetX = 520
        let move = SKAction.moveTo(x: CGFloat(targetX), duration: 1.1)
        move.timingMode = .easeInEaseOut
        run(.sequence([move, .removeFromParent()]))
    }
}
