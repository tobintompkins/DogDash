import SpriteKit

final class FoodNode: SKSpriteNode {

    init() {
        let size = CGSize(width: 50, height: 50)
        super.init(texture: nil, color: .yellow, size: size)
        name = "food"
        zPosition = 4

        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.food
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.contactTestBitMask = PhysicsCategory.dog
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
