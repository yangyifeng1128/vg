///
/// SceneEmulatorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension SceneEmulatorViewController {

    /// 展示「场景模拟器视图控制器」
    func presentSceneEmulatorTransitionVC() {

        let transitionVC: SceneEmulatorTransitionViewController = SceneEmulatorTransitionViewController(gameBundle: gameBundle)
        transitionVC.definesPresentationContext = false
        transitionVC.modalPresentationStyle = .currentContext
        transitionVC.modalTransitionStyle = .crossDissolve

        present(transitionVC, animated: true, completion: nil)
    }
}
