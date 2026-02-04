import SpriteKit

final class CheckpointSystem {

    // Spawn every 30-60 seconds
    var minInterval: TimeInterval = 30
    var maxInterval: TimeInterval = 60

    private var nextCheckpointTime: TimeInterval = 0
    private var hasActiveCheckpoint: Bool = false

    func reset(now: TimeInterval) {
        scheduleNext(now: now)
        hasActiveCheckpoint = false
    }

    func update(
        now: TimeInterval,
        world: SKNode,
        spawnY: CGFloat
    ) {
        guard now >= nextCheckpointTime else { return }
        guard !hasActiveCheckpoint else { return }

        let cp = CheckpointNode()
        cp.position = CGPoint(x: 0, y: spawnY)
        world.addChild(cp)

        hasActiveCheckpoint = true
    }

    func didTriggerCheckpoint(now: TimeInterval) {
        hasActiveCheckpoint = false
        scheduleNext(now: now)
    }

    private func scheduleNext(now: TimeInterval) {
        let interval = TimeInterval.random(in: minInterval...maxInterval)
        nextCheckpointTime = now + interval
    }
}
