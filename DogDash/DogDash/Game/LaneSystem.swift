import CoreGraphics

struct LaneSystem {
    let laneOffset: CGFloat
    private let minLane = -1
    private let maxLane = 1

    init(laneOffset: CGFloat = 120) {
        self.laneOffset = laneOffset
    }

    func x(for lane: Int) -> CGFloat {
        CGFloat(clampedLane(lane)) * laneOffset
    }

    func clampedLane(_ lane: Int) -> Int {
        min(max(lane, minLane), maxLane)
    }
}
