///
/// GameEditorGameboardView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

extension GameEditorGameboardView {

    /// 添加「场景视图」
    func addSceneView(scene: MetaScene, completion handler: ((GameEditorSceneView) -> Void)? = nil) {

        let sceneView: GameEditorSceneView = GameEditorSceneView(scene: scene)
        contentView.addSubview(sceneView)
        sceneViewList.append(sceneView)

        if let handler = handler {
            handler(sceneView)
        }
    }

    /// 选择「场景视图」
    func selectSceneView(_ sceneView: GameEditorSceneView?, animated: Bool, completion handler: ((GameEditorSceneView) -> Void)? = nil) {

        guard let sceneView = sceneView else { return }
        contentView.bringSubviewToFront(sceneView)

        unhighlightSelectionRelatedViews()

        if let handler = handler {
            handler(sceneView)
        }
    }

    /// 删除「场景视图」
    func deleteSelectionRelatedViews(completion handler: (() -> Void)? = nil) {

        // 获取当前选中的「场景视图」的索引和 UUID

        guard let dataSource = gameDataSource else { return }
        let selectedSceneIndex: Int = dataSource.selectedSceneIndex()

        // 删除当前选中的「场景视图」相关的全部「穿梭器视图」

        for (i, transitionView) in transitionViewList.enumerated().reversed() { // 倒序遍历元素可保证安全删除

            if transitionView.startScene.index == selectedSceneIndex {

                // 取消高亮显示当前选中的「穿梭器视图」相关的「结束场景视图」

                let endSceneView = sceneViewList.first(where: { $0.scene.index == transitionView.endScene.index })
                endSceneView?.unhighlight()

                // 删除当前选中的「穿梭器视图」

                transitionView.removeFromSuperview()
                transitionViewList.remove(at: i)

            } else if transitionView.endScene.index == selectedSceneIndex {

                // 取消高亮显示当前选中的「穿梭器视图」相关的「开始场景视图」

                let startSceneView = sceneViewList.first(where: { $0.scene.index == transitionView.startScene.index })
                startSceneView?.unhighlight()

                // 删除当前选中的「穿梭器视图」

                transitionView.removeFromSuperview()
                transitionViewList.remove(at: i)
            }
        }

        // 删除当前选中的「场景视图」

        for (i, sceneView) in sceneViewList.enumerated().reversed() { // 倒序遍历元素可保证安全删除
            if sceneView.scene.index == selectedSceneIndex {
                sceneView.removeFromSuperview()
                sceneViewList.remove(at: i)
                break // 找到就退出
            }
        }

        if let handler = handler {
            handler()
        }
    }

    /// 删除「穿梭器视图」
    func deleteTransitionView(transition: MetaTransition, completion handler: ((GameEditorSceneView) -> Void)? = nil) {

        for (i, transitionView) in transitionViewList.enumerated().reversed() { // 倒序遍历元素可保证安全删除

            if transitionView.startScene.index == transition.from &&
                transitionView.endScene.index == transition.to {

                // 删除「待删除穿梭器」视图

                transitionView.removeFromSuperview()
                transitionViewList.remove(at: i)

                // 取消高亮显示「待删除穿梭器」相关的「结束场景」视图

                let oppositeTransitionView = transitionViewList.first(where: {
                    $0.startScene.index == transition.to && $0.endScene.index == transition.from
                }) // 如果存在反向的穿梭器，就不需要取消高亮显示「结束场景」视图了
                if oppositeTransitionView == nil {
                    let endSceneView = sceneViewList.first(where: { $0.scene.index == transitionView.endScene.index })
                    endSceneView?.unhighlight()
                }
            }
        }

//        gameBundle.deleteTransition(transition)
//        DispatchQueue.global(qos: .background).async { [weak self] in
//            guard let s = self else { return }
//            MetaGameBundleManager.shared.save(s.gameBundle)
//        }
    }
}
