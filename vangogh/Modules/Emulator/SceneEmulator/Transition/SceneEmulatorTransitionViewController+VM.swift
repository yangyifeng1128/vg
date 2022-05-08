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
}
