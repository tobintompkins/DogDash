import SpriteKit

enum HideSpotType: CaseIterable {
    case shed
    case tree
    case house

    var color: SKColor {
        switch self {
        case .shed: return .cyan
        case .tree: return .green
        case .house: return .blue
        }
    }

    var size: CGSize {
        switch self {
        case .shed: return CGSize(width: 120, height: 100)
        case .tree: return CGSize(width: 95, height: 130)
        case .house: return CGSize(width: 140, height: 110)
        }
    }

    var label: String {
        switch self {
        case .shed: return "Shed"
        case .tree: return "Tree"
        case .house: return "House"
        }
    }
}

final class HideSpotNode: SKSpriteNode {
    let hideType: HideSpotType

    init(type: HideSpotType) {
        self.hideType = type
        super.init(texture: nil, color: type.color, size: type.size)
        name = "hideSpot"
        zPosition = 4

        physicsBody = SKPhysicsBody(rectangleOf: type.size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.hideSpot
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.contactTestBitMask = PhysicsCategory.dog
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
