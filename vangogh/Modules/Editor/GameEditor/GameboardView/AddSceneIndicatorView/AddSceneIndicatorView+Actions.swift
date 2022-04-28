///
/// AddSceneIndicatorView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension AddSceneIndicatorView {

    @objc func tap(_ sender: UIPanGestureRecognizer) {

        guard let view = sender.view as? AddSceneIndicatorView else { return }

        delegate?.addSceneIndicatorViewDidTap(view)
    }

    @objc func pan(_ sender: UIPanGestureRecognizer) {

        guard let view = sender.view else { return }

        switch sender.state {
        case .began:
            break
        case .changed:
            view.center = sender.location(in: superview)
            break
        case .ended:
            break
        default:
            break
        }
    }

    @objc func closeButtonDidTap() {

        delegate?.addSceneIndicatorViewCloseButtonDidTap()
    }
}
