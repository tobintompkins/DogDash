import SpriteKit

final class CameraRig {
    private let cameraNode: SKCameraNode
    private weak var target: SKNode?

    init(cameraNode: SKCameraNode, target: SKNode?) {
        self.cameraNode = cameraNode
        self.target = target
    }

    func update(worldOffsetY: CGFloat = 0) {
        guard let t = target else { return }
        // Keep camera centered around the dog (account for world scroll)
        cameraNode.position = CGPoint(x: 0, y: worldOffsetY + t.position.y + 140)
    }
}
