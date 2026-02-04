import SpriteKit

final class MooseNode: SKSpriteNode {
    init(y: CGFloat) {
        super.init(texture: nil, color: .darkGray, size: CGSize(width: 170, height: 110))
        name = "moose"
        zPosition = 6

        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.animal
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.contactTestBitMask = PhysicsCategory.dog

        position = CGPoint(x: -560, y: y)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func runFastCross() {
        let move = SKAction.moveTo(x: 560, duration: 0.70)
        move.timingMode = .easeIn
        run(.sequence([move, .removeFromParent()]))
    }
}
