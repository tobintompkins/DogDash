import SpriteKit

final class JuiceFXSystem {
    private weak var scene: GameScene?

    init(scene: GameScene) { self.scene = scene }

    func checkpointBurst(at pos: CGPoint) {
        guard let scene else { return }

        let ring = SKShapeNode(circleOfRadius: 18)
        ring.strokeColor = .purple
        ring.lineWidth = 5
        ring.alpha = 0.9
        ring.position = pos
        ring.zPosition = 2000

        let sparkle = SKEmitterNode(fileNamed: "CheckpointSpark") ?? JuiceFXSystem.fallbackSpark()
        sparkle.position = pos
        sparkle.zPosition = 2001
        sparkle.targetNode = scene

        scene.addChild(ring)
        scene.addChild(sparkle)

        let expand = SKAction.group([
            SKAction.scale(to: 3.0, duration: 0.22),
            SKAction.fadeOut(withDuration: 0.22)
        ])
        ring.run(.sequence([expand, .removeFromParent()]))

        sparkle.run(.sequence([.wait(forDuration: 0.35), .removeFromParent()]))
    }

    func smallImpact(at pos: CGPoint) {
        guard let scene else { return }
        let puff = SKEmitterNode(fileNamed: "DustPuff") ?? JuiceFXSystem.fallbackPuff()
        puff.position = pos
        puff.zPosition = 1500
        puff.targetNode = scene
        scene.addChild(puff)
        puff.run(.sequence([.wait(forDuration: 0.25), .removeFromParent()]))
    }

    // MARK: - Fallback emitters (no assets required)

    private static func fallbackSpark() -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleTexture = SKTexture(imageNamed: "spark") // ok if missing
        e.particleBirthRate = 220
        e.particleLifetime = 0.35
        e.particleLifetimeRange = 0.2
        e.particleSpeed = 220
        e.particleSpeedRange = 120
        e.particleScale = 0.08
        e.particleScaleRange = 0.06
        e.emissionAngleRange = .pi * 2
        e.particleAlpha = 0.9
        e.particleAlphaRange = 0.2
        e.particleAlphaSpeed = -2.5
        e.particleColor = .purple
        e.particleColorBlendFactor = 1.0
        e.numParticlesToEmit = 60
        return e
    }

    private static func fallbackPuff() -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleTexture = SKTexture(imageNamed: "spark")
        e.particleBirthRate = 160
        e.particleLifetime = 0.25
        e.particleSpeed = 140
        e.particleSpeedRange = 90
        e.particleScale = 0.10
        e.particleScaleRange = 0.08
        e.emissionAngleRange = .pi * 2
        e.particleAlpha = 0.35
        e.particleAlphaSpeed = -2.8
        e.particleColor = .white
        e.particleColorBlendFactor = 1.0
        e.numParticlesToEmit = 40
        return e
    }
}
