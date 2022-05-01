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

        GameEditorExternalChangeManager.shared.set(key: .updateSceneViewTitle, value: scene.uuid) // 保存作品编辑器外部变更字典

        if let handler = handler {
            handler()
        }
    }
}
