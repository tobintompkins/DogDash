import SpriteKit

enum HideSpotType: CaseIterable {
    case bush
    case shed
    case tree
    case house
    case culvert

    var color: SKColor {
        switch self {
        case .bush: return .init(red: 0.3, green: 0.5, blue: 0.2, alpha: 1)
        case .shed: return .cyan
        case .tree: return .green
        case .house: return .blue
        case .culvert: return .gray
        }
    }

    var size: CGSize {
        switch self {
        case .bush: return CGSize(width: 80, height: 70)
        case .shed: return CGSize(width: 120, height: 100)
        case .tree: return CGSize(width: 95, height: 130)
        case .house: return CGSize(width: 140, height: 110)
        case .culvert: return CGSize(width: 130, height: 70)
        }
    }

    var label: String {
        switch self {
        case .bush: return "Bush"
        case .shed: return "Shed"
        case .tree: return "Tree"
        case .house: return "House"
        case .culvert: return "Culvert"
        }
    }

    var requiresSlide: Bool {
        switch self {
        case .culvert: return true
        default: return false
        }
    }

    /// Scent reduction when hiding (12...40, better hide = more reduction)
    var scentReduceStrength: CGFloat {
        switch self {
        case .bush: return 12
        case .tree: return 20
        case .shed: return 28
        case .house: return 34
        case .culvert: return 40
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
