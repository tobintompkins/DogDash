import SpriteKit

final class CheckpointSystem {
    private weak var scene: GameScene?
    private var timer: TimeInterval = 0
    private let spawnInterval: TimeInterval = 45

    init(scene: GameScene) {
        self.scene = scene
    }

    func update(delta: TimeInterval) {
        timer += delta
        if timer >= spawnInterval {
            spawnCheckpoint()
            timer = 0
        }
    }

    private func spawnCheckpoint() {
        guard let scene else { return }

        let gate = SKSpriteNode(color: .purple, size: CGSize(width: 60, height: 200))
        gate.name = "checkpoint"
        gate.position = CGPoint(x: scene.cameraNode.position.x + 500, y: 0)
        gate.zPosition = 5

        gate.physicsBody = SKPhysicsBody(rectangleOf: gate.size)
        gate.physicsBody?.isDynamic = false
        gate.physicsBody?.categoryBitMask = PhysicsCategory.checkpoint
        gate.physicsBody?.collisionBitMask = PhysicsCategory.none
        gate.physicsBody?.contactTestBitMask = PhysicsCategory.dog

        scene.addChild(gate)
    }
}
