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

        // 保存作品编辑器外部变更记录

        GameEditorExternalChangeManager.shared.set(key: .updateSceneTitle, value: scene.uuid)

        if let handler = handler {
            handler()
        }
    }

    /// 保存尺寸比例类型
    func saveAspectRatioType(_ aspectRatioType: MetaSceneAspectRatioType, completion handler: (() -> Void)? = nil) {

        sceneBundle.aspectRatioType = aspectRatioType
        MetaSceneBundleManager.shared.save(sceneBundle)

        if let handler = handler {
            handler()
        }
    }
}
