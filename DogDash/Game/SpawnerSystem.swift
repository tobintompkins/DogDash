import SpriteKit

final class SpawnerSystem {

    var spawnInterval: TimeInterval = 1.10
    var lanes: [Int] = [-1, 0, 1]

    var foodChance: Double = 0.18
    var hideSpotChance: Double = 0.10 // 10% spawns are hide spots

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
        nextSpawnTime = now + spawnInterval

        let lane = lanes.randomElement() ?? 0
        let roll = Double.random(in: 0...1)

        // Hide spot roll
        if roll < hideSpotChance {
            let type = HideSpotType.allCases.randomElement() ?? .shed
            let hide = HideSpotNode(type: type)
            hide.position = CGPoint(x: laneSystem.x(for: lane), y: spawnY)
            world.addChild(hide)
            return
        }

        // Food roll
        if roll < hideSpotChance + foodChance {
            let food = FoodNode()
            food.position = CGPoint(x: laneSystem.x(for: lane), y: spawnY)
            world.addChild(food)
            return
        }

        // Obstacle
        let type = ObstacleType.allCases.randomElement() ?? .rock
        let obstacle = ObstacleNode(type: type)
        obstacle.position = CGPoint(x: laneSystem.x(for: lane), y: spawnY)
        world.addChild(obstacle)
    }
}
