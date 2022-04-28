///
/// GameEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension GameEditorViewController {

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
