///
/// GameEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension GameEditorViewController {

    /// 添加场景
    func addScene(center location: CGPoint, completion handler: ((MetaScene) -> Void)? = nil) {

        let gridWidth: CGFloat = GameEditorGameboardView.VC.gridWidth
        let snappedLocation = CGPoint(x: gridWidth * floor(location.x / gridWidth), y: gridWidth * floor(location.y / gridWidth))

        let scene: MetaScene = gameBundle.addScene(center: snappedLocation)
        MetaGameBundleManager.shared.save(gameBundle)

        if let handler = handler {
            handler(scene)
        }
    }

    /// 保存作品资源包
    func saveGameBundle(completion handler: (() -> Void)? = nil) {

        MetaGameBundleManager.shared.save(gameBundle)

        if let handler = handler {
            handler()
        }
    }

    /// 保存场景标题
    func saveSceneTitle(_ gameBundle: MetaGameBundle, newTitle: String, completion handler: (() -> Void)? = nil) {

        guard let scene = gameBundle.selectedScene() else { return }
        scene.title = newTitle
        gameBundle.updateScene(scene)
        MetaGameBundleManager.shared.save(gameBundle)

        if let handler = handler {
            handler()
        }
    }

    /// 保存内容偏移量
    func saveContentOffset(_ contentOffset: CGPoint) {

        gameBundle.contentOffset = contentOffset
        MetaGameBundleManager.shared.save(gameBundle)
    }

    /// 删除当前选中的场景
    func deleteSelectedScene(completion handler: (() -> Void)? = nil) {

        guard let selectedScene = gameBundle.selectedScene() else { return }
        let selectedSceneUUID: String = selectedScene.uuid

        gameBundle.deleteSelectedScene()
        MetaGameBundleManager.shared.save(gameBundle)

        MetaSceneBundleManager.shared.delete(sceneUUID: selectedSceneUUID, gameUUID: gameBundle.uuid)

        if let handler = handler {
            handler()
        }
    }
}
