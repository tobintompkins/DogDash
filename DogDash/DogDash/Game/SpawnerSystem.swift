import SpriteKit

final class SpawnerSystem {

    var spawnInterval: TimeInterval = 1.10
    var lanes: [Int] = [-1, 0, 1]
    var spawnRate: CGFloat = 1.0

    /// Called when spawning an obstacle: (lane, spawnY) -> Void. If nil, uses default random ObstacleType.
    var onSpawnObstacle: ((Int, CGFloat) -> Void)?
    /// Called when spawning a pickup: (lane, spawnY) -> Void. If nil, uses default FoodNode.
    var onSpawnPickup: ((Int, CGFloat) -> Void)?
    /// Called when spawning a hide spot: (lane, spawnY) -> Void. If nil or returns without spawning, uses default random HideSpotType.
    var onSpawnHideSpot: ((Int, CGFloat) -> Void)?

    var foodChance: Double = 0.18
    var foodSpawnMultiplier: CGFloat = 1.0
    var hideSpotChance: Double = 0.10  // 10% spawns are hide spots
    var animalChance: Double = 0.10    // 10% spawns are animals/hazards
    var predatorChance: Double = 0.05  // subset of animalChance

    private var nextSpawnTime: TimeInterval = 0

    func reset(now: TimeInterval) {
        nextSpawnTime = now + 0.8
    }

    func update(
        now: TimeInterval,
        in world: SKNode,
        laneSystem: LaneSystem,
        spawnY: CGFloat,
        pauseSpawns: Bool
    ) {
        guard !pauseSpawns else { return }
        guard now >= nextSpawnTime else { return }
        let effectiveInterval = spawnInterval / max(0.1, spawnRate)
        nextSpawnTime = now + effectiveInterval

        let lane = lanes.randomElement() ?? 0
        let roll = Double.random(in: 0...1)

        // Hide spot roll
        if roll < hideSpotChance {
            if let spawn = onSpawnHideSpot {
                spawn(lane, spawnY)
            } else {
                let type = HideSpotType.allCases.randomElement() ?? .shed
                let hide = HideSpotNode(type: type)
                hide.position = CGPoint(x: laneSystem.x(for: lane), y: spawnY)
                world.addChild(hide)
            }
            return
        }

        // Food roll
        let chance = foodChance * Double(foodSpawnMultiplier)
        if Double.random(in: 0...1) < chance {
            if let spawn = onSpawnPickup {
                spawn(lane, spawnY)
            } else {
                let food = FoodNode()
                food.position = CGPoint(x: laneSystem.x(for: lane), y: spawnY)
                world.addChild(food)
            }
            return
        }

        // Animal / Predator roll
        if roll < hideSpotChance + chance + animalChance {
            let marker = SKNode()
            marker.position = CGPoint(x: laneSystem.x(for: lane), y: spawnY)

            if Double.random(in: 0...1) < predatorChance {
                marker.name = "spawnPredatorMarker"
            } else {
                marker.name = "spawnAnimalMarker"
            }

            world.addChild(marker)
            return
        }

        // Obstacle
        if let spawn = onSpawnObstacle {
            spawn(lane, spawnY)
        } else {
            let type = ObstacleType.allCases.randomElement() ?? .rock
            let obstacle = ObstacleNode(type: type)
            obstacle.position = CGPoint(x: laneSystem.x(for: lane), y: spawnY)
            world.addChild(obstacle)
        }
    }
}
