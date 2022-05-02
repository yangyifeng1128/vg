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

    /// 取消高亮显示当前选中的「场景视图」相关的视图
    func unhighlightSelectedSceneView() {

        guard let dataSource = gameDataSource else { return }
        let selectedSceneIndex: Int = dataSource.selectedSceneIndex()
        let selectedSceneView: GameEditorSceneView? = sceneViewList.first(where: { $0.scene.index == selectedSceneIndex })
        selectedSceneView?.isActive = false
        unhighlightRelatedSceneViews(sceneView: selectedSceneView)
        unhighlightRelatedTransitionViews(sceneView: selectedSceneView)
    }

    /// 高亮显示相关的「场景视图」
    func highlightRelatedSceneViews(sceneView: GameEditorSceneView?) {

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
    func unhighlightRelatedSceneViews(sceneView: GameEditorSceneView?) {

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
    func highlightRelatedTransitionViews(sceneView: GameEditorSceneView?) {

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
    func unhighlightRelatedTransitionViews(sceneView: GameEditorSceneView?) {

        guard let sceneView = sceneView, let scene = sceneView.scene else { return }

        for transitionView in transitionViewList {
            if transitionView.startScene.index == scene.index || transitionView.endScene.index == scene.index {
                transitionView.unhighlight()
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

    /// 更新「场景视图」标题
    func updateSceneViewTitle(sceneIndex: Int) {

        let sceneView = sceneViewList.first(where: { $0.scene.index == sceneIndex })
        sceneView?.updateTitleLabelAttributedText()
    }

    /// 更新「场景视图」标题
    func updateSceneViewTitle(sceneUUID: String) {

        let sceneView = sceneViewList.first(where: { $0.scene.uuid == sceneUUID })
        sceneView?.updateTitleLabelAttributedText()
    }

    /// 更新「场景视图」缩略图
    func updateSceneViewThumbImage(sceneUUID: String, thumbImage: UIImage) {

        let sceneView = sceneViewList.first(where: { $0.scene.uuid == sceneUUID })
        sceneView?.thumbImageView.image = thumbImage
    }

    /// 添加「穿梭器视图」
//    func addTransitionView(_ transition: MetaTransition) {
//
//        guard let startScene = gameBundle.findScene(index: transition.from), let endScene = gameBundle.findScene(index: transition.to) else { return }
//        let transitionView = GameEditorTransitionView(startScene: startScene, endScene: endScene)
//        contentView.addSubview(transitionView)
//        transitionViewList.append(transitionView)
//    }
    func addTransitionView(startScene: MetaScene, endScene: MetaScene) {

        let transitionView = GameEditorTransitionView(startScene: startScene, endScene: endScene)
        contentView.addSubview(transitionView)
        transitionViewList.append(transitionView)
    }
}
