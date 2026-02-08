import SpriteKit

final class RiskLaneSystem {
    private weak var scene: GameScene?
    private var timer: TimeInterval = 0

    // Tuning
    private let minInterval: TimeInterval = 18
    private let maxInterval: TimeInterval = 28
    private var nextSpawnIn: TimeInterval = 22

    private let zoneLength: CGFloat = 800

    init(scene: GameScene) {
        self.scene = scene
        rollNext()
    }

    func update(delta: TimeInterval) {
        guard let scene else { return }
        timer += delta
        if timer >= nextSpawnIn {
            spawnZoneSet(spawnY: scene.spawnY)
            timer = 0
            rollNext()
        }
    }

    private func rollNext() {
        nextSpawnIn = TimeInterval.random(in: minInterval...maxInterval)
    }

    private func spawnZoneSet(spawnY: CGFloat) {
        guard let scene else { return }

        var lanes: [LaneZoneType]
        if scene.isRiskOnlyChallenge {
            lanes = [.risk, .risk, .risk]
        } else {
            lanes = [.safe, .risk, .shortcut]
            lanes.shuffle()
        }

        let baseX: CGFloat = 0

        for laneIndex in 0..<3 {
            let type = lanes[laneIndex]
            let zone = LaneZone(type: type, laneIndex: laneIndex, length: zoneLength)

            zone.position = CGPoint(x: baseX, y: spawnY + scene.yForLane(laneIndex))
            zone.zPosition = 1
            scene.worldNode.addChild(zone)

            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.fontSize = 16
            label.text = type == .risk ? "RISK" : (type == .shortcut ? "SHORTCUT" : "SAFE")
            label.alpha = 0.25
            label.position = CGPoint(x: 0, y: 120)
            zone.addChild(label)
        }
    }
}
