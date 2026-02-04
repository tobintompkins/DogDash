import SpriteKit
import UIKit

final class GameScene: SKScene, SKPhysicsContactDelegate {

    let viewModel = GameViewModel()

    private var inputRouter = InputRouter()
    private var laneSystem = LaneSystem(laneOffset: 120)
    private var cameraRig: CameraRig?

    private var spawner = SpawnerSystem()
    private var checkpointSystem = CheckpointSystem()

    private var effects = StatusEffectSystem()
    private var weather = WeatherSystem()
    private var stormTickAccumulator: TimeInterval = 0
    private var fog: FogOverlayNode?
    private var snowSpawnAccumulator: TimeInterval = 0
    private var iceSlipEndTime: TimeInterval = 0
    private var lionPounceQueue: [(triggerTime: TimeInterval, y: CGFloat, lane: Int)] = []

    private let world = SKNode()
    private let ground = SKNode()
    private let cameraNode = SKCameraNode()
    private let dog = DogNode()

    private var scrollSpeedBase: CGFloat = 520
    private var scrollSpeed: CGFloat = 520
    private var currentLane: Int = 0
    private var laneChangeDurationBase: TimeInterval = 0.10
    private var laneChangeDuration: TimeInterval = 0.10

    private var groundY: CGFloat = 0
    private var lastUpdateTime: TimeInterval = 0
    private var currentFrameTime: TimeInterval = 0
    private var shouldRestart = false
    private var difficultyLevel: Int = 0

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
        checkpointSystem.reset(now: 0)
        effects.reset()
        weather.reset(now: 0)
        stormTickAccumulator = 0
        snowSpawnAccumulator = 0
        iceSlipEndTime = 0
        lionPounceQueue.removeAll()
        fog?.setFogAmount(0)

        difficultyLevel = 0
        scrollSpeedBase = 520
        scrollSpeed = scrollSpeedBase
        laneChangeDurationBase = 0.10
        laneChangeDuration = laneChangeDurationBase
    }

    private func setupCamera() {
        camera = cameraNode
        addChild(cameraNode)
        cameraRig = CameraRig(cameraNode: cameraNode, target: dog)

        fog?.removeFromParent()
        let f = FogOverlayNode(size: CGSize(width: size.width * 1.2, height: size.height * 1.2))
        f.position = .zero
        cameraNode.addChild(f)
        fog = f
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
                if self.viewModel.canSpendStamina(0.10) {
                    self.viewModel.spendForJump()
                    self.dog.jump()
                }
            case .swipeDown:
                if self.viewModel.canSpendStamina(0.07) {
                    self.viewModel.spendForSlide()
                    self.dog.beginSlide(now: self.currentFrameTime)
                }
            case .swipeLeft:
                self.changeLane(by: -1)
            case .swipeRight:
                self.changeLane(by: +1)
            }
        }

        inputRouter.attach(to: view)
    }

    private func changeLane(by delta: Int) {
        if currentFrameTime < iceSlipEndTime { return }

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

        let dt: TimeInterval
        if lastUpdateTime == 0 { dt = 1.0/60.0 } else { dt = currentTime - lastUpdateTime }
        lastUpdateTime = currentTime
        currentFrameTime = currentTime

        let spawnY: CGFloat = (dog.position.y - world.position.y) + size.height * 0.9

        // Update effects
        effects.update(dt: dt)
        applyEffectModifiers()

        weather.update(now: currentTime, dt: dt)
        viewModel.setWeather(state: weather.state)

        if weather.state == .thunderstorm, weather.coverActive {
            viewModel.setCoverTimer(weather.coverRemaining)
        } else {
            viewModel.setCoverTimer(nil)
        }

        if weather.state == .thunderstorm {
            stormTickAccumulator += dt

            if stormTickAccumulator >= 1.8 {
                stormTickAccumulator = 0

                let lane = [-1, 0, 1].randomElement() ?? 0
                let y = spawnY + 120

                if Bool.random() {
                    let lz = LightningZoneNode(y: y, lane: lane, laneSystem: laneSystem)
                    world.addChild(lz)
                } else {
                    let cz = CoverZoneNode(y: y, lane: lane, laneSystem: laneSystem)
                    world.addChild(cz)
                }
            }

            if weather.coverActive && weather.coverRemaining <= 0.01 {
                viewModel.onStormFailPenalty()
                weather.triggerNewCoverChallenge()
            }
        } else {
            stormTickAccumulator = 0
        }

        if weather.state == .snowstorm {
            fog?.setFogAmount(1.0)
            viewModel.setWeatherHint("Low visibility • Slippery lanes")

            snowSpawnAccumulator += dt

            if snowSpawnAccumulator >= 1.6 {
                snowSpawnAccumulator = 0
                let lane = [-1, 0, 1].randomElement() ?? 0
                let y = spawnY + 120
                let ice = IcePatchNode(y: y, lane: lane, laneSystem: laneSystem)
                world.addChild(ice)
            }

            spawner.animalChance = max(0.06, spawner.animalChance * 0.70)
            spawner.foodChance = max(0.10, spawner.foodChance * 0.92)
        } else {
            fog?.setFogAmount(0.0)
            viewModel.setWeatherHint("")
            snowSpawnAccumulator = 0
        }

        // Scroll world
        world.position.y -= scrollSpeed * CGFloat(dt)

        // Score/time + meters tick
        let points = Int((scrollSpeed * CGFloat(dt)) / 8.0)
        viewModel.tick(deltaTime: dt, distancePoints: max(1, points))

        // Spawn ahead
        spawner.update(
            now: currentTime,
            in: world,
            laneSystem: laneSystem,
            spawnY: spawnY,
            pauseSpawns: viewModel.shouldPauseSpawns()
        )

        // Checkpoint system
        checkpointSystem.update(now: currentTime, world: world, spawnY: spawnY + 260)

        // Replace animal markers with actual animals
        convertAnimalMarkers(currentTime: currentTime)
        processLionPounces(currentTime: currentTime)

        dog.update(now: currentTime)

        viewModel.updateHiding(dt: dt, elapsed: viewModel.elapsed)
        viewModel.updateStaminaRegen(dt: dt)

        cleanupOffscreenNodes()
        cameraRig?.update(worldOffsetY: world.position.y)

        // Effects text for HUD
        let txt = effects.activeList().map { "\($0.type.displayName)(\(Int($0.remaining))s)" }.joined(separator: ", ")
        viewModel.setActiveEffectsText(txt)

        if dog.position.y + world.position.y < -size.height {
            triggerGameOver()
        }

        if viewModel.isGameOver {
            triggerGameOver()
        }
    }

    private func applyEffectModifiers() {
        scrollSpeed = scrollSpeedBase
        laneChangeDuration = laneChangeDurationBase

        if effects.isActive(.slowed) {
            scrollSpeed = scrollSpeedBase * 0.78
        }
        if effects.isActive(.panic) {
            laneChangeDuration = laneChangeDurationBase * 1.6
        }
        if weather.state == .snowstorm {
            scrollSpeed = scrollSpeedBase * 0.86
            laneChangeDuration = laneChangeDurationBase * 1.35
        }
    }

    private func convertAnimalMarkers(currentTime: TimeInterval) {
        let markers = world.children.filter { $0.name == "spawnAnimalMarker" || $0.name == "spawnPredatorMarker" }

        for m in markers {
            let y = m.position.y

            let lane: Int
            if m.position.x < -40 { lane = -1 }
            else if m.position.x > 40 { lane = 1 }
            else { lane = 0 }

            let isPredator = (m.name == "spawnPredatorMarker")
            m.removeFromParent()

            if isPredator {
                if Bool.random() {
                    let moose = MooseNode(y: y)
                    world.addChild(moose)
                    moose.runFastCross()
                } else {
                    let warn = LionWarningNode(y: y, lane: lane, laneSystem: laneSystem)
                    world.addChild(warn)

                    let trigger = currentTime + 0.9
                    lionPounceQueue.append((triggerTime: trigger, y: y, lane: lane))

                    warn.run(.sequence([.wait(forDuration: 1.0), .removeFromParent()]))
                }
                continue
            }

            let roll = Int.random(in: 0...99)
            if roll < 40 {
                let deer = DeerNode(crossingLane: 0, laneSystem: laneSystem)
                deer.runCross(atY: y)
                world.addChild(deer)
            } else if roll < 70 {
                let skunk = SkunkNode(y: y, lane: lane, laneSystem: laneSystem)
                world.addChild(skunk)

                let cloud = StinkCloudNode(y: y - 40, lane: lane, laneSystem: laneSystem)
                world.addChild(cloud)
            } else {
                let req: BearRequirement = Bool.random() ? .jump : .slide
                let bear = BearNode(requirement: req, y: y, lane: lane, laneSystem: laneSystem)
                world.addChild(bear)
            }
        }
    }

    private func processLionPounces(currentTime: TimeInterval) {
        guard !lionPounceQueue.isEmpty else { return }

        let ready = lionPounceQueue.filter { $0.triggerTime <= currentTime }
        if ready.isEmpty { return }

        lionPounceQueue.removeAll { $0.triggerTime <= currentTime }

        for item in ready {
            let lion = MountainLionNode(y: item.y, lane: item.lane, laneSystem: laneSystem)
            world.addChild(lion)

            lion.setScale(0.9)
            lion.alpha = 0.0
            let pop = SKAction.group([
                .fadeIn(withDuration: 0.08),
                .scale(to: 1.0, duration: 0.10)
            ])
            let settle = SKAction.moveBy(x: 0, y: -40, duration: 0.12)
            settle.timingMode = .easeOut
            lion.run(.sequence([pop, settle]))
        }
    }

    private func cleanupOffscreenNodes() {
        let cutoffY = (dog.position.y - world.position.y) - size.height * 1.2
        for node in world.children {
            if node.name == "obstacle" || node.name == "food" || node.name == "hideSpot" || node.name == "checkpoint"
                || node.name == "deer" || node.name == "moose" || node.name == "skunk" || node.name == "stinkCloud" || node.name == "bear"
                || node.name == "coverZone" || node.name == "lightningZone" || node.name == "icePatch" || node.name == "lionWarning" || node.name == "mountainLion" {
                if node.position.y < cutoffY {
                    node.removeFromParent()
                }
            }
        }
    }

    private func applyCheckpointRewardsAndDifficulty(currentTime: TimeInterval) {
        let rewardY = (dog.position.y - world.position.y) + size.height * 0.55

        let food1 = FoodNode()
        food1.position = CGPoint(x: laneSystem.x(for: 0), y: rewardY)
        world.addChild(food1)

        if Bool.random() {
            let food2 = FoodNode()
            let lane = [-1, 1].randomElement() ?? 1
            food2.position = CGPoint(x: laneSystem.x(for: lane), y: rewardY + 60)
            world.addChild(food2)
        }

        let checkpointHides: [HideSpotType] = [.shed, .house, .culvert, .tree]
        let type = checkpointHides.randomElement() ?? .shed
        let hide = HideSpotNode(type: type)
        hide.position = CGPoint(x: laneSystem.x(for: 0), y: rewardY + 120)
        world.addChild(hide)

        difficultyLevel += 1

        scrollSpeedBase = min(scrollSpeedBase + 35, 820)
        scrollSpeed = scrollSpeedBase

        spawner.spawnInterval = max(0.70, spawner.spawnInterval - 0.04)
        spawner.hideSpotChance = max(0.06, spawner.hideSpotChance - 0.004)
        spawner.foodChance = max(0.12, spawner.foodChance - 0.002)
        spawner.animalChance = min(0.22, spawner.animalChance + 0.01)

        if difficultyLevel % 3 == 0 {
            effects.add(.panic, duration: 2.0)
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
            viewModel.onObstacleHit()
            effects.add(.panic, duration: 2.5)
            if viewModel.isGameOver { triggerGameOver() }
            return
        }

        let isFood = (a.categoryBitMask == PhysicsCategory.food) || (b.categoryBitMask == PhysicsCategory.food)
        if isFood {
            if a.categoryBitMask == PhysicsCategory.food { a.node?.removeFromParent() }
            if b.categoryBitMask == PhysicsCategory.food { b.node?.removeFromParent() }
            viewModel.onFoodPickup()
            return
        }

        let isHideSpot = (a.categoryBitMask == PhysicsCategory.hideSpot) || (b.categoryBitMask == PhysicsCategory.hideSpot)
        if isHideSpot {
            let hideNode = (a.categoryBitMask == PhysicsCategory.hideSpot ? a.node : b.node) as? HideSpotNode

            if let hide = hideNode, hide.hideType.requiresSlide {
                if dog.stance != .slide {
                    viewModel.onObstacleHit()
                    hideNode?.removeFromParent()
                    return
                }
            }

            hideNode?.removeFromParent()
            if let hide = hideNode {
                viewModel.beginHide(type: hide.hideType, nowElapsed: viewModel.elapsed)
            }
            return
        }

        let isCheckpoint = (a.categoryBitMask == PhysicsCategory.checkpoint) || (b.categoryBitMask == PhysicsCategory.checkpoint)
        if isCheckpoint {
            if let nodeA = a.node, nodeA.name == "checkpointSensor" { nodeA.parent?.removeFromParent() }
            if let nodeB = b.node, nodeB.name == "checkpointSensor" { nodeB.parent?.removeFromParent() }

            viewModel.onCheckpointReached()
            checkpointSystem.didTriggerCheckpoint(now: currentFrameTime)
            applyCheckpointRewardsAndDifficulty(currentTime: currentFrameTime)
            return
        }

        let isAnimal = (a.categoryBitMask == PhysicsCategory.animal) || (b.categoryBitMask == PhysicsCategory.animal)
        if isAnimal {
            if a.node?.name == "moose" || b.node?.name == "moose" || a.node?.name == "mountainLion" || b.node?.name == "mountainLion" {
                effects.add(.slowed, duration: 2.5)
            }
            viewModel.onObstacleHit()
            effects.add(.panic, duration: 3.0)
            if viewModel.isGameOver { triggerGameOver() }
            return
        }

        let isZone = (a.categoryBitMask == PhysicsCategory.hazardZone) || (b.categoryBitMask == PhysicsCategory.hazardZone)
        if isZone {
            effects.add(.stink, duration: 4.0)
            return
        }

        let isBear = (a.categoryBitMask == PhysicsCategory.bear) || (b.categoryBitMask == PhysicsCategory.bear)
        if isBear {
            let bearNode = (a.categoryBitMask == PhysicsCategory.bear ? a.node : b.node) as? BearNode
            if let bear = bearNode {
                switch bear.requirement {
                case .jump:
                    if dog.stance == .slide {
                        viewModel.onObstacleHit()
                    }
                case .slide:
                    if dog.stance != .slide {
                        viewModel.onObstacleHit()
                    }
                }
                bear.removeFromParent()
                if viewModel.isGameOver { triggerGameOver() }
            }
            return
        }

        let isCover = (a.categoryBitMask == PhysicsCategory.coverZone) || (b.categoryBitMask == PhysicsCategory.coverZone)
        if isCover {
            if a.categoryBitMask == PhysicsCategory.coverZone { a.node?.removeFromParent() }
            if b.categoryBitMask == PhysicsCategory.coverZone { b.node?.removeFromParent() }
            weather.playerFoundCover()
            viewModel.onFoodPickup()
            return
        }

        let isLightning = (a.categoryBitMask == PhysicsCategory.lightningZone) || (b.categoryBitMask == PhysicsCategory.lightningZone)
        if isLightning {
            if a.categoryBitMask == PhysicsCategory.lightningZone { a.node?.removeFromParent() }
            if b.categoryBitMask == PhysicsCategory.lightningZone { b.node?.removeFromParent() }
            effects.add(.slowed, duration: 3.0)
            effects.add(.panic, duration: 2.0)
            viewModel.onObstacleHit()
            return
        }

        let isIce = (a.categoryBitMask == PhysicsCategory.icePatch) || (b.categoryBitMask == PhysicsCategory.icePatch)
        if isIce {
            if a.categoryBitMask == PhysicsCategory.icePatch { a.node?.removeFromParent() }
            if b.categoryBitMask == PhysicsCategory.icePatch { b.node?.removeFromParent() }

            effects.add(.slowed, duration: 2.8)
            effects.add(.panic, duration: 1.8)
            viewModel.onObstacleHit()

            iceSlipEndTime = currentFrameTime + 1.2
            return
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
    }
}
