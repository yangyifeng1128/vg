///
/// SceneEmulatorTransitionViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

extension SceneEmulatorTransitionViewController {

    /// 加载后续场景列表
    func loadNextScenes(completion handler: (() -> Void)? = nil) {

        nextScenes = gameBundle.scenes

        if let handler = handler {
            handler()
        }
    }

    func saveCurrentTime() {

    }

    /// 保存场景资源包
    func saveCurrentTimeMilliseconds(_ milliseconds: Int64) {

        sceneBundle.currentTimeMilliseconds = milliseconds
        MetaSceneBundleManager.shared.save(sceneBundle)
    }
}
