import SpriteKit
import UIKit

final class GameScene: SKScene, SKPhysicsContactDelegate {

    // ViewModel for HUD
    let viewModel = GameViewModel()

    // Systems
    private var inputRouter = InputRouter()
    private var laneSystem = LaneSystem(laneOffset: 120)
    private var cameraRig: CameraRig?
    private var spawner = SpawnerSystem()

    // Nodes
    private let world = SKNode()
    private let ground = SKNode()
    private let cameraNode = SKCameraNode()
    private let dog = DogNode()

    // Runner settings
    private var scrollSpeed: CGFloat = 520
    private var currentLane: Int = 0
    private var laneChangeDuration: TimeInterval = 0.10

    // Ground Y reference
    private var groundY: CGFloat = 0

    // Timing
    private var lastUpdateTime: TimeInterval = 0

    // Restart request flag
    private var shouldRestart = false

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        backgroundColor = .black
        physicsWorld.gravity = CGVector(dx: 0, dy: -30)
        physicsWorld.contactDelegate = self

        removeAllChildren()
        world.removeAllChildren()
        addChild(world)

        setupCamera()
        setupGround()
        setupDog()
        setupInput(on: view)

        viewModel.reset()
        viewModel.startIfNeeded()

        lastUpdateTime = 0
        spawner.reset(now: 0)
    }

    private func setupCamera() {
        camera = cameraNode
        addChild(cameraNode)
        cameraRig = CameraRig(cameraNode: cameraNode, target: dog)
    }

    private func setupGround() {
        world.addChild(ground)

        let groundHeight: CGFloat = 120
        let groundWidth: CGFloat = max(size.width, 800)
        groundY = -size.height * 0.2

        let groundSprite = SKSpriteNode(color: .darkGray, size: CGSize(width: groundWidth, height: groundHeight))
        groundSprite.position = CGPoint(x: 0, y: groundY)
        groundSprite.name = "groundSprite"
        groundSprite.zPosition = 0

        groundSprite.physicsBody = SKPhysicsBody(rectangleOf: groundSprite.size)
        groundSprite.physicsBody?.isDynamic = false
        groundSprite.physicsBody?.categoryBitMask = PhysicsCategory.ground
        groundSprite.physicsBody?.collisionBitMask = PhysicsCategory.dog
        groundSprite.physicsBody?.contactTestBitMask = PhysicsCategory.dog

        ground.addChild(groundSprite)
    }

    private func setupDog() {
        currentLane = 0
        dog.position = CGPoint(x: laneSystem.x(for: currentLane), y: groundY + 120)
        dog.physicsBody?.isDynamic = true
        world.addChild(dog)
    }

    private func setupInput(on view: SKView) {
        inputRouter.onInput = { [weak self] input in
            guard let self else { return }

            if self.viewModel.phase == .gameOver {
                if input == .tap { self.requestRestart() }
                return
            }

            self.viewModel.startIfNeeded()

            switch input {
            case .tap:
                self.dog.jump()
            case .swipeDown:
                self.dog.beginSlide(now: self.lastUpdateTime)
            case .swipeLeft:
                self.changeLane(by: -1)
            case .swipeRight:
                self.changeLane(by: +1)
            }
        }

        inputRouter.attach(to: view)
    }

    private func changeLane(by delta: Int) {
        let target = laneSystem.clampedLane(currentLane + delta)
        guard target != currentLane else { return }
        currentLane = target

        let targetX = laneSystem.x(for: currentLane)
        let move = SKAction.moveTo(x: targetX, duration: laneChangeDuration)
        move.timingMode = .easeOut
        dog.run(move)
    }

    func requestRestart() {
        shouldRestart = true
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        if shouldRestart {
            shouldRestart = false
            didMove(to: view!)
            return
        }

        guard viewModel.phase == .running else { return }

        // Delta time
        let dt: TimeInterval
        if lastUpdateTime == 0 { dt = 1.0/60.0 } else { dt = currentTime - lastUpdateTime }
        lastUpdateTime = currentTime

        // Scroll the world downward to simulate forward motion
        world.position.y -= scrollSpeed * CGFloat(dt)

        // Score: award points based on "distance"
        let points = Int((scrollSpeed * CGFloat(dt)) / 8.0)
        viewModel.tick(deltaTime: dt, distancePoints: max(1, points))

        // Spawn obstacles, hide spots, food (paused while hiding)
        let spawnY: CGFloat = (dog.position.y - world.position.y) + size.height * 0.9
        spawner.update(
            now: currentTime,
            in: world,
            laneSystem: laneSystem,
            spawnY: spawnY,
            pauseSpawns: viewModel.shouldPauseSpawns()
        )

        // Update dog (slide timer)
        dog.update(now: currentTime)

        // Hiding: drains catcher quickly for a short window
        viewModel.updateHiding(dt: dt, elapsed: viewModel.elapsed)

        // Cleanup obstacles that are far below view
        cleanupOffscreenNodes()

        // Keep camera tracking dog
        cameraRig?.update(worldOffsetY: world.position.y)

        // Fail if dog falls far below camera
        if dog.position.y + world.position.y < -size.height {
            triggerGameOver()
        }
    }

    private func cleanupOffscreenNodes() {
        let cutoffY = (dog.position.y - world.position.y) - size.height * 1.2
        for node in world.children {
            let name = node.name
            if name == "obstacle" || name == "food" || name == "hideSpot" {
                if node.position.y < cutoffY {
                    node.removeFromParent()
                }
            }
        }
    }

    private func triggerGameOver() {
        guard viewModel.phase != .gameOver else { return }
        viewModel.triggerGameOver()

        dog.physicsBody?.velocity = .zero
        dog.physicsBody?.isDynamic = false
    }

    // MARK: - Contacts

    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA
        let b = contact.bodyB

        let dogBody = (a.categoryBitMask == PhysicsCategory.dog) ? a : (b.categoryBitMask == PhysicsCategory.dog ? b : nil)
        guard dogBody != nil else { return }

        let isGround = (a.categoryBitMask == PhysicsCategory.ground) || (b.categoryBitMask == PhysicsCategory.ground)
        if isGround {
            dog.markGrounded(true)
            return
        }

        let isObstacle = (a.categoryBitMask == PhysicsCategory.obstacle) || (b.categoryBitMask == PhysicsCategory.obstacle)
        if isObstacle {
            triggerGameOver()
            return
        }

        let isHideSpot = (a.categoryBitMask == PhysicsCategory.hideSpot) || (b.categoryBitMask == PhysicsCategory.hideSpot)
        if isHideSpot {
            // remove the hide spot
            if a.categoryBitMask == PhysicsCategory.hideSpot { a.node?.removeFromParent() }
            if b.categoryBitMask == PhysicsCategory.hideSpot { b.node?.removeFromParent() }

            // begin hiding using elapsed time as a consistent timer
            viewModel.beginHide(nowElapsed: viewModel.elapsed)
            return
        }

        let isFood = (a.categoryBitMask == PhysicsCategory.food) || (b.categoryBitMask == PhysicsCategory.food)
        if isFood {
            let foodNode = (a.node is FoodNode) ? (a.node as? FoodNode) : (b.node as? FoodNode)
            if let food = foodNode {
                viewModel.addBonusPoints(25)
                food.removeFromParent()
            }
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let a = contact.bodyA
        let b = contact.bodyB

        let dogBody = (a.categoryBitMask == PhysicsCategory.dog) ? a : (b.categoryBitMask == PhysicsCategory.dog ? b : nil)
        guard dogBody != nil else { return }

        let isGround = (a.categoryBitMask == PhysicsCategory.ground) || (b.categoryBitMask == PhysicsCategory.ground)
        if isGround {
            dog.markGrounded(false)
        }

        let isHideSpot = (a.categoryBitMask == PhysicsCategory.hideSpot) || (b.categoryBitMask == PhysicsCategory.hideSpot)
        if isHideSpot {
            viewModel.exitHiding()
        }
    }
}
