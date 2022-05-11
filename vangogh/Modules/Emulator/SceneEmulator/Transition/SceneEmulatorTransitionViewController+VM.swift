///
/// SceneEmulatorTransitionViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

extension SceneEmulatorTransitionViewController {

    /// 加载后续场景描述符列表
    func loadNextSceneDescriptors(completion handler: (() -> Void)? = nil) {

        guard let selectedScene = gameBundle.selectedScene() else { return }
        let defaultNextSceneDescriptor: NextSceneDescriptor = NextSceneDescriptor(type: .restart, scene: selectedScene)
        nextSceneDescriptors.append(defaultNextSceneDescriptor)

        gameBundle.scenes.forEach { scene in
            let nextSceneDescriptor: NextSceneDescriptor = NextSceneDescriptor(type: .redirectTo, scene: scene)
            nextSceneDescriptors.append(nextSceneDescriptor)
        }

        if let handler = handler {
            handler()
        }
    }

    func restartSelectedScene(completion handler: ((MetaSceneBundle) -> Void)? = nil) {

        sceneBundle.currentTimeMilliseconds = 0
        MetaSceneBundleManager.shared.save(sceneBundle)

        if let handler = handler {
            handler(sceneBundle)
        }
    }
}
