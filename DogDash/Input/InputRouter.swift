import UIKit

enum RunnerInput {
    case tap
    case swipeLeft
    case swipeRight
    case swipeDown
}

final class InputRouter {
    var onInput: ((RunnerInput) -> Void)?

    func attach(to view: UIView) {
        view.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)

        let left = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        left.direction = .left
        view.addGestureRecognizer(left)

        let right = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        right.direction = .right
        view.addGestureRecognizer(right)

        let down = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        down.direction = .down
        view.addGestureRecognizer(down)
    }

    @objc private func handleTap() {
        onInput?(.tap)
    }

    @objc private func handleSwipe(_ gr: UISwipeGestureRecognizer) {
        switch gr.direction {
        case .left: onInput?(.swipeLeft)
        case .right: onInput?(.swipeRight)
        case .down: onInput?(.swipeDown)
        default: break
        }
    }
}
