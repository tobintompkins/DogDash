import SpriteKit

final class LionWarningNode: SKSpriteNode {
    init(y: CGFloat, lane: Int, laneSystem: LaneSystem) {
        super.init(texture: nil, color: .red, size: CGSize(width: 90, height: 30))
        name = "lionWarning"
        zPosition = 50
        alpha = 0.55
        position = CGPoint(x: laneSystem.x(for: lane), y: y)

        physicsBody = nil

        let pulse = SKAction.sequence([
            .fadeAlpha(to: 0.15, duration: 0.18),
            .fadeAlpha(to: 0.55, duration: 0.18)
        ])
        run(.repeatForever(pulse))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
