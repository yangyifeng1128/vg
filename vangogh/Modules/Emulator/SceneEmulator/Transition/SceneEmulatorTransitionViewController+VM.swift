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

    func redirectToScene(_ nextScene: MetaScene, completion handler: ((MetaSceneBundle, MetaGameBundle) -> Void)? = nil) {

        // 重置当前场景资源包

        sceneBundle.currentTimeMilliseconds = 0
        MetaSceneBundleManager.shared.save(sceneBundle)

        // 重定向至后续场景资源包

        guard let nextSceneBundle = MetaSceneBundleManager.shared.load(sceneUUID: nextScene.uuid, gameUUID: gameBundle.uuid) else { return }
        gameBundle.selectedSceneIndex = nextScene.index
        MetaGameBundleManager.shared.save(gameBundle)

        if let handler = handler {
            handler(nextSceneBundle, gameBundle)
        }
    }
}
