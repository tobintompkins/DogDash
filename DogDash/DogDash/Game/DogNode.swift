import SpriteKit

final class DogNode: SKSpriteNode {

    enum Stance {
        case run
        case slide
    }

    private(set) var stance: Stance

    // Tunables
    var jumpImpulse: CGFloat = 820
    var slideDuration: TimeInterval = 0.55

    // State
    private var isGrounded: Bool = false
    private var slideEndTime: TimeInterval = 0

    convenience init() {
        let size = CGSize(width: 70, height: 90)
        self.init(texture: nil, color: .white, size: size)
        stance = .run
        name = "dog"
        zPosition = 10

        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.allowsRotation = false
        physicsBody?.restitution = 0.0
        physicsBody?.friction = 0.6
        physicsBody?.linearDamping = 0.2
        physicsBody?.categoryBitMask = PhysicsCategory.dog
        physicsBody?.collisionBitMask = PhysicsCategory.ground
        physicsBody?.contactTestBitMask =
            PhysicsCategory.ground
            | PhysicsCategory.obstacle
            | PhysicsCategory.food
            | PhysicsCategory.hideSpot
            | PhysicsCategory.checkpoint
            | PhysicsCategory.animal
            | PhysicsCategory.hazardZone
            | PhysicsCategory.bear
            | PhysicsCategory.coverZone
            | PhysicsCategory.lightningZone
            | PhysicsCategory.icePatch
    }

    func markGrounded(_ grounded: Bool) {
        isGrounded = grounded
    }

    func jump() {
        guard isGrounded, stance != .slide else { return }
        physicsBody?.velocity.dy = 0
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))
        isGrounded = false
    }

    func beginSlide(now: TimeInterval) {
        guard isGrounded else { return }
        stance = .slide
        slideEndTime = now + slideDuration

        // Make hitbox shorter while sliding
        let slideSize = CGSize(width: size.width, height: size.height * 0.55)
        self.size = slideSize
        physicsBody = SKPhysicsBody(rectangleOf: slideSize)
        physicsBody?.allowsRotation = false
        physicsBody?.restitution = 0.0
        physicsBody?.friction = 0.8
        physicsBody?.linearDamping = 0.2
        physicsBody?.categoryBitMask = PhysicsCategory.dog
        physicsBody?.collisionBitMask = PhysicsCategory.ground
        physicsBody?.contactTestBitMask =
            PhysicsCategory.ground
            | PhysicsCategory.obstacle
            | PhysicsCategory.food
            | PhysicsCategory.hideSpot
            | PhysicsCategory.checkpoint
            | PhysicsCategory.animal
            | PhysicsCategory.hazardZone
            | PhysicsCategory.bear
            | PhysicsCategory.coverZone
            | PhysicsCategory.lightningZone
            | PhysicsCategory.icePatch
    }

    func update(now: TimeInterval) {
        if stance == .slide, now >= slideEndTime {
            endSlide()
        }
    }

    func endSlide() {
        stance = .run

        let runSize = CGSize(width: 70, height: 90)
        self.size = runSize
        physicsBody = SKPhysicsBody(rectangleOf: runSize)
        physicsBody?.allowsRotation = false
        physicsBody?.restitution = 0.0
        physicsBody?.friction = 0.6
        physicsBody?.linearDamping = 0.2
        physicsBody?.categoryBitMask = PhysicsCategory.dog
        physicsBody?.collisionBitMask = PhysicsCategory.ground
        physicsBody?.contactTestBitMask =
            PhysicsCategory.ground
            | PhysicsCategory.obstacle
            | PhysicsCategory.food
            | PhysicsCategory.hideSpot
            | PhysicsCategory.checkpoint
            | PhysicsCategory.animal
            | PhysicsCategory.hazardZone
            | PhysicsCategory.bear
            | PhysicsCategory.coverZone
            | PhysicsCategory.lightningZone
            | PhysicsCategory.icePatch
    }
}
