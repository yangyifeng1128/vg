///
/// SceneEmulatorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

extension SceneEmulatorViewController {

    /// 保存场景资源包
    func saveSceneBundle(completion handler: (() -> Void)? = nil) {

        sceneBundle.currentTimeMilliseconds = currentTime.milliseconds()
        MetaSceneBundleManager.shared.save(sceneBundle)

        MetaGameBundleManager.shared.save(gameBundle)

        if let handler = handler {
            handler()
        }
    }
}
