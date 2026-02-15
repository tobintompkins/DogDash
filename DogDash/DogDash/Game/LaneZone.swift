import SpriteKit

enum LaneZoneType: String {
    case safe
    case risk
    case shortcut
}

final class LaneZone: SKNode {
    let type: LaneZoneType
    let laneIndex: Int // 0,1,2

    init(type: LaneZoneType, laneIndex: Int, length: CGFloat) {
        self.type = type
        self.laneIndex = laneIndex
        super.init()

        name = "laneZone_\(type.rawValue)_\(laneIndex)"

        // Invisible physics trigger rectangle
        let box = SKSpriteNode(color: .clear, size: CGSize(width: length, height: 220))
        box.alpha = 0.001
        box.position = .zero
        box.name = "laneZoneBody"

        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
        box.physicsBody?.isDynamic = false
        box.physicsBody?.categoryBitMask = PhysicsCategory.laneZone
        box.physicsBody?.contactTestBitMask = PhysicsCategory.dog
        box.physicsBody?.collisionBitMask = 0

        addChild(box)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
