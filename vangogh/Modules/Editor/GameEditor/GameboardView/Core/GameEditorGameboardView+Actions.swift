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

    @objc func addSceneIndicatorViewDidTap(_ sender: UITapGestureRecognizer) {

        guard let view = sender.view as? AddSceneIndicatorView else { return }
        let location: CGPoint = CGPoint(x: view.center.x, y: view.center.y + AddSceneIndicatorView.VC.closeButtonWidth / 4)
        gameDelegate?.addSceneIndicatorViewDidTap(location: location)
    }

    @objc func addSceneIndicatorViewDidPan(_ sender: UIPanGestureRecognizer) {

        guard let view = sender.view else { return }

        switch sender.state {
        case .began:
            break
        case .changed:
            view.center = sender.location(in: superview)
            break
        case .ended:
            break
        default:
            break
        }
    }

    @objc func addSceneIndicatorCloseButtonDidTap() {

        gameDelegate?.addSceneIndicatorCloseButtonDidTap()
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

        // 隐藏「添加场景提示器视图」

        if let addSceneIndicatorView = addSceneIndicatorView {
            addSceneIndicatorView.isHidden = true
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

        // 确保「添加场景提示器视图」置于最顶层

        if let addSceneIndicatorView = addSceneIndicatorView {
            contentView.bringSubviewToFront(addSceneIndicatorView)
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

        let visibleAreaCenter: CGPoint = CGPoint(x: contentOffset.x + bounds.width / 2, y: contentOffset.y + bounds.height / 2)
        let xOffset: CGFloat = visibleAreaCenter.x - scene.center.x
        contentOffset.x = contentOffset.x - xOffset
        let yOffset: CGFloat = visibleAreaCenter.y - scene.center.y
        contentOffset.y = contentOffset.y - yOffset

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            guard let s = self else { return }
            s.setContentOffset(s.contentOffset, animated: animated)
        }, completion: nil)

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

extension GameEditorGameboardView {

    /// 隐藏「添加场景提示器视图」
    func showAddSceneIndicatorView(location: CGPoint) {

        guard let view = addSceneIndicatorView else { return }
        view.center = CGPoint(x: location.x, y: location.y - AddSceneIndicatorView.VC.height / 2)
        view.isHidden = false
    }

    /// 隐藏「添加场景提示器视图」
    func hideAddSceneIndicatorView() {

        guard let view = addSceneIndicatorView else { return }
        view.isHidden = true
    }
}
