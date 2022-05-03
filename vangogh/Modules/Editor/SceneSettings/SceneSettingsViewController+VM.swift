///
/// SceneSettingsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

extension SceneSettingsViewController {

    /// 保存场景标题
    func saveSceneTitle(_ title: String, completion handler: (() -> Void)? = nil) {

        guard let scene = gameBundle.selectedScene() else { return }
        scene.title = title
        gameBundle.updateScene(scene)
        MetaGameBundleManager.shared.save(gameBundle)

        // 保存作品编辑器外部变更字典

        GameEditorExternalChangeManager.shared.set(key: .updateSceneTitle, value: scene.uuid)

        if let handler = handler {
            handler()
        }
    }
}
