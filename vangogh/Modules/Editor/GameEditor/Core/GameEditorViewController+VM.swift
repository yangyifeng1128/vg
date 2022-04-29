///
/// GameEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension GameEditorViewController {

    /// 保存作品资源包
    func saveGameBundle() {

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let s = self else { return }
            MetaGameBundleManager.shared.save(s.gameBundle)
        }
    }

    /// 保存场景标题
    func saveSceneTitle(_ gameBundle: MetaGameBundle, newTitle: String, completion handler: (() -> Void)? = nil) {

        guard let scene = gameBundle.selectedScene() else { return }
        scene.title = newTitle
        gameBundle.updateScene(scene)
        DispatchQueue.global(qos: .background).async {
            MetaGameBundleManager.shared.save(gameBundle)
        }

        if let handler = handler {
            DispatchQueue.main.async {
                handler()
            }
        }
    }
}
