///
/// SceneEmulatorTransitionViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

extension SceneEmulatorTransitionViewController {

    /// 加载后续场景提示器列表
    func loadNextSceneIndicators(completion handler: (() -> Void)? = nil) {

        guard let selectedScene = gameBundle.selectedScene(), let selectedSceneTitle = selectedScene.title else { return }
        let defaultNextSceneIndicator: NextSceneIndicator = NextSceneIndicator(type: .loop, title: selectedSceneTitle)
        nextSceneIndicators.append(defaultNextSceneIndicator)

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
