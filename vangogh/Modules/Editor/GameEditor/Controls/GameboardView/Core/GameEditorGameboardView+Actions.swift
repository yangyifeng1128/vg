///
/// GameEditorGameboardView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension GameEditorGameboardView {

    @objc func contentViewDidTap(_ sender: UITapGestureRecognizer) {

        let location: CGPoint = sender.location(in: sender.view)
        gameDelegate?.gameboardViewDidTap(location: location)
    }

    @objc func contentViewDidLongPress(_ sender: UILongPressGestureRecognizer) {

        let location: CGPoint = sender.location(in: sender.view)
        gameDelegate?.gameboardViewDidLongPress(location: location)
    }
}

extension GameEditorGameboardView {

    /// 重新加载数据
    func reloadData() {

        reloadAllSceneAndTransitionViews()
    }

    /// 重新加载全部「场景视图」与「穿梭器视图」
    func reloadAllSceneAndTransitionViews() {

        guard let dataSource = gameDataSource else { return }

        sceneViewList.forEach { $0.removeFromSuperview() }
        sceneViewList.removeAll()

        transitionViewList.forEach { $0.removeFromSuperview() }
        transitionViewList.removeAll()

        for index in 0..<dataSource.numberOfSceneViews() {
            let sceneView: GameEditorSceneView = dataSource.sceneView(at: index)
            contentView.insertSubview(sceneView, at: 0)
            sceneViewList.append(sceneView)
        }

        for index in 0..<dataSource.numberOfTransitionViews() {
            let transitionView: GameEditorTransitionView = dataSource.transitionView(at: index)
            contentView.insertSubview(transitionView, at: 0)
            transitionViewList.append(transitionView)
        }
    }
}

extension GameEditorGameboardView {

    /// 外观切换后更新视图
    func updateViewsWhenTraitCollectionChanged() {

        // 取消高亮显示全部「穿梭器视图」

        for transitionView in transitionViewList {
            transitionView.unhighlight()
        }

        // 高亮显示当前选中的「场景视图」相关的视图

        guard let dataSource = gameDataSource else { return }
        let selectedSceneIndex: Int = dataSource.selectedSceneIndex()
        if selectedSceneIndex != 0 {
            let sceneView: GameEditorSceneView? = sceneViewList.first(where: { $0.scene.index == selectedSceneIndex })
            highlightRelatedTransitionViews(sceneView: sceneView)
            highlightRelatedSceneViews(sceneView: sceneView)
        }
    }

    /// 高亮显示当前选中的「场景视图」相关的视图
    func highlightSelectionRelatedViews() {

        guard let dataSource = gameDataSource else { return }
        let selectedSceneIndex: Int = dataSource.selectedSceneIndex()
        let selectedSceneView: GameEditorSceneView? = sceneViewList.first(where: { $0.scene.index == selectedSceneIndex })
        selectedSceneView?.isSelected = true
        highlightRelatedTransitionViews(sceneView: selectedSceneView)
        highlightRelatedSceneViews(sceneView: selectedSceneView)
    }

    /// 取消高亮显示当前选中的「场景视图」相关的视图
    func unhighlightSelectionRelatedViews() {

        guard let dataSource = gameDataSource else { return }
        let selectedSceneIndex: Int = dataSource.selectedSceneIndex()
        let selectedSceneView: GameEditorSceneView? = sceneViewList.first(where: { $0.scene.index == selectedSceneIndex })
        selectedSceneView?.isSelected = false
        unhighlightRelatedSceneViews(sceneView: selectedSceneView)
        unhighlightRelatedTransitionViews(sceneView: selectedSceneView)
    }

    /// 高亮显示相关的「场景视图」
    private func highlightRelatedSceneViews(sceneView: GameEditorSceneView?) {

        guard let sceneView = sceneView, let scene = sceneView.scene else { return }

        for transitionView in transitionViewList {
            if transitionView.startScene.index == scene.index {
                let endSceneView: GameEditorSceneView? = sceneViewList.first(where: { $0.scene.index == transitionView.endScene.index })
                endSceneView?.highlight()
            } else if transitionView.endScene.index == scene.index {
                let startSceneView: GameEditorSceneView? = sceneViewList.first(where: { $0.scene.index == transitionView.startScene.index })
                startSceneView?.highlight()
            }
        }
    }

    /// 取消高亮显示相关的「场景视图」
    private func unhighlightRelatedSceneViews(sceneView: GameEditorSceneView?) {

        guard let sceneView = sceneView, let scene = sceneView.scene else { return }

        for transitionView in transitionViewList {
            if transitionView.startScene.index == scene.index {
                let endSceneView: GameEditorSceneView? = sceneViewList.first(where: { $0.scene.index == transitionView.endScene.index })
                endSceneView?.unhighlight()
            } else if transitionView.endScene.index == scene.index {
                let startSceneView: GameEditorSceneView? = sceneViewList.first(where: { $0.scene.index == transitionView.startScene.index })
                startSceneView?.unhighlight()
            }
        }
    }

    /// 高亮显示相关的「穿梭器视图」
    private func highlightRelatedTransitionViews(sceneView: GameEditorSceneView?) {

        guard let sceneView = sceneView, let scene = sceneView.scene else { return }

        var changed: [GameEditorTransitionView] = []

        for transitionView in transitionViewList {
            if transitionView.startScene.index == scene.index {
                transitionView.highlight(isSent: true)
                changed.append(transitionView) // 以当前选中的「场景视图」为起点的「穿梭器视图」在顶层
            } else if transitionView.endScene.index == scene.index {
                transitionView.highlight(isSent: false)
                changed.insert(transitionView, at: 0) // 以当前选中的「场景视图」为终点的「穿梭器视图」在底层
            }
        }

        for transitionView in changed {
            bringRelatedSceneViewsToFront(transitionView: transitionView)
        }
    }

    /// 取消高亮显示相关的「穿梭器视图」
    private func unhighlightRelatedTransitionViews(sceneView: GameEditorSceneView?) {

        guard let sceneView = sceneView, let scene = sceneView.scene else { return }

        for transitionView in transitionViewList {
            if transitionView.startScene.index == scene.index || transitionView.endScene.index == scene.index {
                transitionView.unhighlight()
            }
        }
    }

    /// 更新相关的「穿梭器视图」
    func updateRelatedTransitionViews(scene: MetaScene) {

        for transitionView in transitionViewList {
            if transitionView.startScene.index == scene.index {
                transitionView.startScene = scene
                transitionView.updateView()
            } else if transitionView.endScene.index == scene.index {
                transitionView.endScene = scene
                transitionView.updateView()
            }
        }
    }

    /// 将相关的「场景视图」移动至最上层
    func bringRelatedSceneViewsToFront(transitionView: GameEditorTransitionView) {

        // 将「穿梭器视图」移动至最上层

        contentView.bringSubviewToFront(transitionView)

        // 将相关的「场景视图」移动至最上层

        guard let startSceneView = sceneViewList.first(where: { $0.scene.index == transitionView.startScene.index }) else { return }
        contentView.bringSubviewToFront(startSceneView)

        guard let endSceneView = sceneViewList.first(where: { $0.scene.index == transitionView.endScene.index }) else { return }
        contentView.bringSubviewToFront(endSceneView)
    }

    /// 居中显示「场景视图」
    func centerSceneView(scene: MetaScene, animated: Bool, completion handler: ((CGPoint) -> Void)? = nil) {

        var offset: CGPoint = contentOffset
        let visibleAreaCenter: CGPoint = CGPoint(x: offset.x + bounds.width / 2, y: offset.y + bounds.height / 2)
        let xOffset: CGFloat = visibleAreaCenter.x - scene.center.x
        offset.x = offset.x - xOffset
        let yOffset: CGFloat = visibleAreaCenter.y - scene.center.y
        offset.y = offset.y - yOffset

        setContentOffset(offset, animated: animated)

        if let handler = handler {
            handler(contentOffset)
        }
    }
}

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

    /// 更新「场景视图」标题
    func updateSceneViewTitleLabel(sceneIndex: Int) {

        let sceneView: GameEditorSceneView? = sceneViewList.first(where: { $0.scene.index == sceneIndex })
        sceneView?.updateTitleLabelAttributedText()
    }

    /// 更新「场景视图」标题
    func updateSceneViewTitleLabel(sceneUUID: String) {

        let sceneView: GameEditorSceneView? = sceneViewList.first(where: { $0.scene.uuid == sceneUUID })
        sceneView?.updateTitleLabelAttributedText()
    }

    /// 更新「场景视图」缩略图
    func updateSceneViewThumbImageView(sceneUUID: String, thumbImage: UIImage) {

        let sceneView: GameEditorSceneView? = sceneViewList.first(where: { $0.scene.uuid == sceneUUID })
        sceneView?.thumbImageView.image = thumbImage
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

    /// 添加「穿梭器视图」
    func addTransitionView(startScene: MetaScene, endScene: MetaScene, completion handler: ((GameEditorTransitionView) -> Void)? = nil) {

        let transitionView: GameEditorTransitionView = GameEditorTransitionView(startScene: startScene, endScene: endScene)
        contentView.addSubview(transitionView)
        transitionViewList.append(transitionView)

        bringRelatedSceneViewsToFront(transitionView: transitionView)

        if let handler = handler {
            handler(transitionView)
        }
    }

    /// 删除「穿梭器视图」
    func deleteTransitionView(transition: MetaTransition, completion handler: (() -> Void)? = nil) {

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

        if let handler = handler {
            handler()
        }
    }
}
