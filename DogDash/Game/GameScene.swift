import SpriteKit
import UIKit

final class GameScene: SKScene, SKPhysicsContactDelegate {

    let viewModel = GameViewModel()
    weak var progressionStore: ProgressionStore?

    private var inputRouter = InputRouter()
    private var laneSystem = LaneSystem(laneOffset: 120)
    private var cameraRig: CameraRig?

    private var spawner = SpawnerSystem()
    private var checkpointSystem: CheckpointSystem!
    private var adrenalineSystem: AdrenalineSystem!
    private var scentSystem: ScentSystem!
    private var riskLaneSystem: RiskLaneSystem!
    private var activeLaneType: LaneZoneType = .safe

    private var effects = StatusEffectSystem()
    private var weatherSystem: WeatherSystem!
    private var currentWeatherMods = WeatherModifiers(
        scentGainMultiplier: 1, scentDecayMultiplier: 1,
        staminaDrainPerSec: 0, hungerDrainPerSec: 0,
        spawnIntensityMult: 1, visibilityAlpha: 1
    )
    private var fogOverlay: SKSpriteNode?
    private var iceSlipEndTime: TimeInterval = 0
    private var lionPounceQueue: [(triggerTime: TimeInterval, y: CGFloat, lane: Int)] = []

    private let world = SKNode()
    private let ground = SKNode()
    let cameraNode = SKCameraNode()
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

    private var baseSpawnRate: CGFloat = 1.0
    private var spawnIntensityMult: CGFloat = 1.0

    // Defaults
    var foodSpawnMultiplier: CGFloat = 1.0
    var fogStrengthMultiplier: CGFloat = 1.0
    var scoreMultiplier: CGFloat = 1.0

    var upgrades = AppliedUpgrades()
    var pickupSpawnMultiplier: CGFloat = 1.0
    var staminaDrainMultiplier: CGFloat = 1.0
    var hungerDrainMultiplier: CGFloat = 1.0

    private let baseStaminaDrainPerSec: CGFloat = 0.8
    private let baseHungerDrainPerSec: CGFloat = 0.7

    var isRiskOnlyChallenge: Bool = false
    var hidingDisabled: Bool = false

    private let dailyChallengeSystem = DailyChallengeSystem()
    private var currentChallenge: DailyChallenge?

    // AdrenalineSystem interface
    var stamina: Double { viewModel.stamina }
    var forwardSpeed: CGFloat {
        get { scrollSpeed }
        set { scrollSpeed = newValue }
    }
    var jumpPower: CGFloat {
        get { dog.jumpImpulse }
        set { dog.jumpImpulse = newValue }
    }
    var gameState: GameState { viewModel.gameState }
    var isSprinting: Bool = true
    var worldNode: SKNode { world }

    var spawnY: CGFloat { (dog.position.y - world.position.y) + size.height * 0.9 }

    var obstacleIntensity: CGFloat {
        switch activeLaneType {
        case .safe: return 1.0
        case .risk: return 1.35
        case .shortcut: return 1.15
        }
    }

    func rewardMultiplier() -> CGFloat {
        switch activeLaneType {
        case .safe: return 1.0
        case .risk: return 1.6
        case .shortcut: return 1.25
        }
    }

    func configureProgression(_ store: ProgressionStore) {
        progressionStore = store
        upgrades = UpgradeApplier.build(from: store)

        staminaDrainMultiplier = upgrades.staminaDrainMultiplier
        hungerDrainMultiplier = upgrades.hungerDrainMultiplier
        pickupSpawnMultiplier = upgrades.pickupSpawnMultiplier

        viewModel.addStaminaCapacityBonus(upgrades.maxStaminaBonus)

        scentSystem.scentGainMultiplier *= upgrades.scentGainMultiplier
    }

    private func canAwardRewardsInCurrentLane() -> Bool {
        if !isRiskOnlyChallenge { return true }
        return activeLaneType == .risk
    }

    func yForLane(_ lane: Int) -> CGFloat {
        switch lane {
        case 0: return -120
        case 1: return 0
        default: return 120
        }
    }

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

        let challenge = dailyChallengeSystem.todaysChallenge()
        currentChallenge = challenge

        gameState.dailyTitle = challenge.title
        gameState.dailyDescription = challenge.description
        gameState.runModifiers = challenge.modifiers

        viewModel.reset()
        applyRunModifiers(challenge.modifiers)
        viewModel.startIfNeeded()

        lastUpdateTime = 0
        checkpointSystem = CheckpointSystem(scene: self)
        adrenalineSystem = AdrenalineSystem(scene: self)
        scentSystem = ScentSystem(scene: self)
        riskLaneSystem = RiskLaneSystem(scene: self)
        weatherSystem = WeatherSystem(scene: self)

        setupFogOverlayIfNeeded()

        spawner.reset(now: 0)
        baseSpawnRate = spawner.spawnRate
        effects.reset()
        weatherSystem.reset()
        currentWeatherMods = weatherSystem.modifiers(for: weatherSystem.current)
        scentSystem.scentGainMultiplier = currentWeatherMods.scentGainMultiplier
        scentSystem.scentDecayMultiplier = currentWeatherMods.scentDecayMultiplier
        spawnIntensityMult = currentWeatherMods.spawnIntensityMult
        spawner.spawnRate = baseSpawnRate * spawnIntensityMult
        iceSlipEndTime = 0
        lionPounceQueue.removeAll()
        fogOverlay?.alpha = 0

        difficultyLevel = 0
        isSprinting = true
        activeLaneType = .safe
        scrollSpeedBase = 520
        scrollSpeed = scrollSpeedBase
        laneChangeDurationBase = 0.10
        laneChangeDuration = laneChangeDurationBase
    }

    private func setupCamera() {
        camera = cameraNode
        addChild(cameraNode)
        cameraRig = CameraRig(cameraNode: cameraNode, target: dog)
    }

    private func setupFogOverlayIfNeeded() {
        fogOverlay?.removeFromParent()
        let overlay = SKSpriteNode(color: .white, size: CGSize(width: 5000, height: 2000))
        overlay.zPosition = 999
        overlay.alpha = 0.0
        overlay.position = CGPoint(x: cameraNode.position.x, y: 0)
        overlay.name = "fogOverlay"
        overlay.blendMode = .alpha
        addChild(overlay)
        fogOverlay = overlay
    }

    private func updateFogOverlay(alpha: CGFloat) {
        // alpha input is 0..1 where higher means more fog
        let strength = fogStrengthMultiplier
        fogOverlay?.alpha = max(0, min(0.50, alpha * 0.35 * strength))
        fogOverlay?.position.x = cameraNode.position.x
    }

    private func applyRunModifiers(_ mods: RunModifiers) {
        foodSpawnMultiplier = mods.foodSpawnMultiplier
        fogStrengthMultiplier = mods.fogMultiplier
        isRiskOnlyChallenge = mods.riskOnly
        hidingDisabled = mods.noHiding

        if mods.startWithAdrenaline {
            viewModel.forceStaminaForAdrenalineStart()
        }

        scoreMultiplier = mods.scoreMultiplier
        gameState.runModifiers = mods

        if hidingDisabled { spawner.hideSpotChance = 0 }
        spawner.foodSpawnMultiplier = foodSpawnMultiplier * pickupSpawnMultiplier
    }

    private func applySpawnIntensity(_ mult: CGFloat) {
        spawnIntensityMult = mult
        let spawnRate = baseSpawnRate * spawnIntensityMult
        spawner.spawnRate = spawnRate
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
                    self.scentSystem.onJump()
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

        let delta: TimeInterval
        if lastUpdateTime == 0 { delta = 1.0/60.0 } else { delta = currentTime - lastUpdateTime }
        checkpointSystem.update(delta: delta)
        isSprinting = viewModel.phase == .running && !viewModel.isHiding

        adrenalineSystem.update(delta: delta)
        scentSystem.update(delta: delta)
        // gameState.scent kept in sync by ScentSystem (writes directly)

        // Optional: use catcherPressure to nudge difficulty live
        // Example: spawnRate *= (1 / catcherPressure)  // only if you want constant ramp

        if dog.stance == .slide {
            scentSystem.onSlide(delta: delta)
        }
        lastUpdateTime = currentTime
        currentFrameTime = currentTime

        let spawnY: CGFloat = (dog.position.y - world.position.y) + size.height * 0.9

        riskLaneSystem.update(delta: delta)

        // Update effects
        effects.update(dt: delta)
        applyEffectModifiers()

        weatherSystem.update(delta: delta)
        viewModel.setWeatherText(gameState.weather)

        let mods = weatherSystem.modifiers(for: weatherSystem.current)
        currentWeatherMods = mods

        scentSystem.scentGainMultiplier = mods.scentGainMultiplier * upgrades.scentGainMultiplier
        scentSystem.scentDecayMultiplier = mods.scentDecayMultiplier

        let totalStaminaDrain = (baseStaminaDrainPerSec + mods.staminaDrainPerSec) * staminaDrainMultiplier
        let totalHungerDrain = (baseHungerDrainPerSec + mods.hungerDrainPerSec) * hungerDrainMultiplier
        viewModel.applyStaminaHungerDrain(dt: delta, staminaDrainPerSec: totalStaminaDrain, hungerDrainPerSec: totalHungerDrain)

        updateFogOverlay(alpha: 1.0 - mods.visibilityAlpha)

        applySpawnIntensity(mods.spawnIntensityMult)

        if hidingDisabled { spawner.hideSpotChance = 0 }
        spawner.foodSpawnMultiplier = foodSpawnMultiplier * pickupSpawnMultiplier

        // Scroll world
        world.position.y -= scrollSpeed * CGFloat(delta)

        // Score/time + meters tick
        let points = Int((scrollSpeed * CGFloat(delta)) / 8.0)
        viewModel.tick(deltaTime: delta, distancePoints: max(1, points))

        // Spawn ahead
        spawner.update(
            now: currentTime,
            in: world,
            laneSystem: laneSystem,
            spawnY: spawnY,
            pauseSpawns: viewModel.shouldPauseSpawns()
        )

        // Replace animal markers with actual animals
        convertAnimalMarkers(currentTime: currentTime)
        processLionPounces(currentTime: currentTime)

        dog.update(now: currentTime)

        viewModel.updateHiding(dt: delta, elapsed: viewModel.elapsed)
        viewModel.updateStaminaRegen(dt: delta)

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
        if adrenalineSystem.isActive {
            scrollSpeed *= 1.25
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
                || node.name == "coverZone" || node.name == "lightningZone" || node.name == "icePatch" || node.name == "lionWarning" || node.name == "mountainLion"
                || (node.name?.hasPrefix("laneZone_") == true) {
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
        spawner.hideSpotChance = hidingDisabled ? 0 : max(0.06, spawner.hideSpotChance - 0.004)
        spawner.foodChance = max(0.12, spawner.foodChance - 0.002)
        spawner.animalChance = min(0.22, spawner.animalChance + 0.01)

        if difficultyLevel % 3 == 0 {
            effects.add(.panic, duration: 2.0)
        }
    }

    private func handleCheckpoint(_ contact: SKPhysicsContact) {
        let node = contact.bodyA.node?.name == "checkpoint"
            ? contact.bodyA.node
            : contact.bodyB.node
        node?.removeFromParent()

        guard canAwardRewardsInCurrentLane() else { return }

        // Boost meters (stamina, hunger, catcher relief, home progress)
        viewModel.onCheckpointReached()

        // Difficulty ramp + spawn rewards
        applyCheckpointRewardsAndDifficulty(currentTime: currentFrameTime)

        if viewModel.gameState.homeProgress >= 1 {
            triggerWin()
        }
    }

    private func triggerWin() {
        guard viewModel.phase != .won else { return }
        finalizeRun(distance: gameState.distanceThisRun)
        viewModel.triggerWin()
        isPaused = true
        print("YOU MADE IT HOME 🏠🐕")
    }

    private func handleLaneZoneContact(_ contact: SKPhysicsContact) {
        // LaneZone is parent of the physics trigger node
        let zoneNode = (contact.bodyA.node?.parent as? LaneZone) ?? (contact.bodyB.node?.parent as? LaneZone)
        guard let zone = zoneNode else { return }

        // Set active lane type
        activeLaneType = zone.type
        gameState.currentLaneZone = zone.type.rawValue

        if activeLaneType == .shortcut, canAwardRewardsInCurrentLane() {
            viewModel.setHomeProgress(viewModel.homeProgress + 0.03)
        }
    }

    private func triggerGameOver() {
        guard viewModel.phase != .gameOver else { return }
        finalizeRun(distance: gameState.distanceThisRun)
        viewModel.triggerGameOver()
        dog.physicsBody?.velocity = .zero
        dog.physicsBody?.isDynamic = false
    }

    private func finalizeRun(distance: Int) {
        gameState.distanceThisRun = distance

        // Add PP to account + update best
        progressionStore?.addPawPoints(gameState.pawPointsEarnedThisRun)
        progressionStore?.submitRun(distance: distance)
    }

    // MARK: - Contacts

    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA
        let b = contact.bodyB

        let dogBody = (a.categoryBitMask == PhysicsCategory.dog) ? a : (b.categoryBitMask == PhysicsCategory.dog ? b : nil)
        guard dogBody != nil else { return }

        let names = [contact.bodyA.node?.name, contact.bodyB.node?.name]
        if names.contains(where: { $0 == "checkpoint" }) {
            handleCheckpoint(contact)
            return
        }

        if (a.categoryBitMask == PhysicsCategory.laneZone) || (b.categoryBitMask == PhysicsCategory.laneZone) {
            handleLaneZoneContact(contact)
            return
        }

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
            if canAwardRewardsInCurrentLane() {
                viewModel.onFoodPickup()
            }
            return
        }

        let isHideSpot = (a.categoryBitMask == PhysicsCategory.hideSpot) || (b.categoryBitMask == PhysicsCategory.hideSpot)
        if isHideSpot {
            if hidingDisabled { return }

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
                let baseReduce = hide.hideType.scentReduceStrength
                let boosted = baseReduce * upgrades.hideScentBonusMultiplier
                scentSystem.reduceFromHide(strength: boosted)
            }
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
            weatherSystem.playerFoundCover()
            if canAwardRewardsInCurrentLane() {
                viewModel.onFoodPickup()
            }
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
