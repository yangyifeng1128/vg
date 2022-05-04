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

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let s = self else { return }
            s.sceneBundle.currentTimeMilliseconds = s.currentTime.milliseconds() // 保存当前播放时刻
            MetaSceneBundleManager.shared.save(s.sceneBundle)
            MetaGameBundleManager.shared.save(s.gameBundle)
        }
    }
}
