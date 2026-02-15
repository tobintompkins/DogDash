import AudioToolbox
import SpriteKit

final class JuiceAudioSystem {
    private weak var scene: SKScene?

    init(scene: SKScene) { self.scene = scene }

    func playCheckpoint() {
        // lightweight system sound (replace with your own later)
        AudioServicesPlaySystemSound(1104) // "Tock"
    }

    func playWhoosh() {
        AudioServicesPlaySystemSound(1156) // "Swipe"
    }

    func playHeartbeat() {
        AudioServicesPlaySystemSound(1073) // "Low"
    }

    func playNearMiss() {
        AudioServicesPlaySystemSound(1057) // "Pop"
    }
}
