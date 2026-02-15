import SpriteKit

final class CameraJuiceSystem {
    private weak var scene: GameScene?

    private var targetZoom: CGFloat = 1.0
    private var currentZoom: CGFloat = 1.0

    private var shakeTime: TimeInterval = 0
    private var shakeIntensity: CGFloat = 0

    init(scene: GameScene) { self.scene = scene }

    func setAdrenaline(active: Bool) {
        targetZoom = active ? 0.92 : 1.0
    }

    func bumpShake(intensity: CGFloat, duration: TimeInterval) {
        shakeIntensity = max(shakeIntensity, intensity)
        shakeTime = max(shakeTime, duration)
    }

    func update(delta: TimeInterval) {
        guard let scene else { return }

        // Smooth zoom
        let speed: CGFloat = 6.5
        currentZoom += (targetZoom - currentZoom) * min(1, CGFloat(delta) * speed)
        scene.cameraNode.setScale(currentZoom)

        // Shake
        if shakeTime > 0 {
            shakeTime -= delta
            let dx = CGFloat.random(in: -shakeIntensity...shakeIntensity)
            let dy = CGFloat.random(in: -shakeIntensity...shakeIntensity)
            scene.cameraNode.position.x += dx
            scene.cameraNode.position.y += dy

            // decay
            shakeIntensity *= 0.86
        }
    }
}
