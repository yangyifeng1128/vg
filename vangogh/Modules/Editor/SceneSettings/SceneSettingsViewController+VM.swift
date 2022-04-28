///
/// SceneSettingsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension SceneSettingsViewController {

    /// 保存场景标题
    func saveSceneTitle(_ gameBundle: MetaGameBundle, newTitle: String, completion handler: (() -> Void)? = nil) {

        guard let scene = gameBundle.selectedScene() else { return }
        scene.title = newTitle
        gameBundle.updateScene(scene)
        DispatchQueue.global(qos: .background).async {
            MetaGameBundleManager.shared.save(gameBundle)
        }

        GameboardViewExternalChangeManager.shared.set(key: .updateSceneTitle, value: scene.uuid) // 保存「作品板视图外部变更记录字典」

        if let handler = handler {
            DispatchQueue.main.async {
                handler()
            }
        }
    }
}
