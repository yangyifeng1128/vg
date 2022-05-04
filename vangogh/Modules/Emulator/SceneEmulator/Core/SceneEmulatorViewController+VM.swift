///
/// SceneEmulatorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension SceneEmulatorViewController {

    func isSceneBundleEmpty() -> Bool {

        return sceneBundle.footages.isEmpty && sceneBundle.nodes.isEmpty
    }

    /// 保存资源包
    func saveSceneBundle() {

        sceneBundle.currentTimeMilliseconds = currentTime.milliseconds()
        MetaSceneBundleManager.shared.save(sceneBundle)

        MetaGameBundleManager.shared.save(gameBundle)
    }
}
