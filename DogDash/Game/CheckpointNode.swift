import SpriteKit

final class CheckpointNode: SKNode {

    override init() {
        super.init()
        name = "checkpoint"
        zPosition = 3

        // Visual gate
        let gate = SKSpriteNode(color: .purple, size: CGSize(width: 360, height: 30))
        gate.position = CGPoint(x: 0, y: 0)
        addChild(gate)

        // Add "posts"
        let leftPost = SKSpriteNode(color: .purple, size: CGSize(width: 30, height: 180))
        leftPost.position = CGPoint(x: -165, y: 75)
        addChild(leftPost)

        let rightPost = SKSpriteNode(color: .purple, size: CGSize(width: 30, height: 180))
        rightPost.position = CGPoint(x: 165, y: 75)
        addChild(rightPost)

        // Physics sensor (wide)
        let sensor = SKNode()
        sensor.name = "checkpointSensor"
        sensor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 380, height: 120))
        sensor.physicsBody?.isDynamic = false
        sensor.physicsBody?.categoryBitMask = PhysicsCategory.checkpoint
        sensor.physicsBody?.collisionBitMask = PhysicsCategory.none
        sensor.physicsBody?.contactTestBitMask = PhysicsCategory.dog
        addChild(sensor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
