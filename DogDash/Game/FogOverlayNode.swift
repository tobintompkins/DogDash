import SpriteKit

final class FogOverlayNode: SKSpriteNode {
    init(size: CGSize) {
        super.init(texture: nil, color: .white, size: size)
        name = "fogOverlay"
        zPosition = 999
        alpha = 0.0
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setFogAmount(_ amount: CGFloat) {
        alpha = max(0, min(0.65, amount * 0.65))
    }
}
