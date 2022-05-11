///
/// SceneEmulatorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVKit
import UIKit

extension SceneEmulatorViewController {

    /// 当时间流逝时更新视图
    func updateViewsWhenTimeElapsed(to time: CMTime) {

        if let duration = player.currentItem?.duration {
            let progress: CGFloat = GVC.maxProgressValue * time.seconds / duration.seconds
            playControlView.seek(to: progress)
        }

        playerView.interactionView.showOrHideNodeViews(at: time)
    }

    /// 展示「场景模拟器穿梭器视图控制器」
    func presentSceneEmulatorTransitionVC() {

        let transitionVC: SceneEmulatorTransitionViewController = SceneEmulatorTransitionViewController(sceneBundle: sceneBundle, gameBundle: gameBundle)
        transitionVC.definesPresentationContext = true
        transitionVC.modalPresentationStyle = .currentContext

        present(transitionVC, animated: true, completion: nil)
    }
}
