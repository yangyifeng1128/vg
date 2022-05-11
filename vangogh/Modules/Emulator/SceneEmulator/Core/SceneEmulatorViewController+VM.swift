///
/// SceneEmulatorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

extension SceneEmulatorViewController {

    /// 保存资源包
    func saveSceneBundle() {

        sceneBundle.currentTimeMilliseconds = currentTime.milliseconds()
        MetaSceneBundleManager.shared.save(sceneBundle)

        MetaGameBundleManager.shared.save(gameBundle)
    }
}
