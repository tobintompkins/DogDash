import SpriteKit

final class SlowMoSystem {
    private weak var scene: SKScene?
    private var timer: TimeInterval = 0
    private var active: Bool = false

    init(scene: SKScene) { self.scene = scene }

    func trigger(duration: TimeInterval = 0.18, speed: CGFloat = 0.35) {
        guard let scene else { return }
        timer = duration
        active = true
        scene.speed = speed
    }

    func update(delta: TimeInterval) {
        guard let scene else { return }
        guard active else { return }

        timer -= delta
        if timer <= 0 {
            active = false
            scene.speed = 1.0
        }
    }
}
