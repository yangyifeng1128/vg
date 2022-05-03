///
/// GameEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension GameEditorViewController: GameEditorGameboardViewDataSource {

    /// 设置当前选中的场景索引
    func selectedSceneIndex() -> Int {

        return gameBundle.selectedSceneIndex
    }

    /// 设置「场景视图」数量
    func numberOfSceneViews() -> Int {

        return gameBundle.scenes.count
    }

    /// 设置「场景视图」
    func sceneView(at index: Int) -> GameEditorSceneView {

        let scene: MetaScene = gameBundle.scenes[index]
        let sceneView: GameEditorSceneView = GameEditorSceneView(scene: scene)
        sceneView.delegate = self

        if let thumbImage = MetaThumbManager.shared.loadSceneThumbImage(sceneUUID: sceneView.scene.uuid, gameUUID: gameBundle.uuid) {
            sceneView.thumbImageView.image = thumbImage
        }

        return sceneView
    }

    /// 设置「穿梭器视图」数量
    func numberOfTransitionViews() -> Int {

        return gameBundle.transitions.count
    }

    /// 设置「穿梭器视图」
    func transitionView(at index: Int) -> GameEditorTransitionView {

        let transition: MetaTransition = gameBundle.transitions[index]

        guard let startScene = gameBundle.findScene(index: transition.from) else {
            fatalError("Unexpected start scene")
        }
        guard let endScene = gameBundle.findScene(index: transition.to) else {
            fatalError("Unexpected end scene")
        }

        let transitionView: GameEditorTransitionView = GameEditorTransitionView(startScene: startScene, endScene: endScene)

        return transitionView
    }
}

extension GameEditorViewController: GameEditorGameboardViewDelegate {

    func gameboardViewDidTap(location: CGPoint) {

        if willAddScene {
            addSceneView(center: location, forceSelection: false)
        } else {
            closeSceneView()
        }
    }

    func gameboardViewDidLongPress(location: CGPoint) {

    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        // 滚动到边缘时，停止滚动

        var contentOffset = scrollView.contentOffset

        let minX: CGFloat = 0
        let maxX: CGFloat = GameEditorGameboardView.VC.contentViewWidth - scrollView.bounds.width
        if contentOffset.x < minX {
            contentOffset.x = minX
        } else if contentOffset.x > maxX {
            contentOffset.x = maxX
        }

        let minY: CGFloat = 0
        let maxY: CGFloat = GameEditorGameboardView.VC.contentViewHeight - scrollView.bounds.height
        if contentOffset.y < minY {
            contentOffset.y = minY
        } else if contentOffset.y > maxY {
            contentOffset.y = maxY
        }

        // 滚动视图

        scrollView.contentOffset = contentOffset

        // 保存内容偏移量

        saveContentOffset(contentOffset)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {

        return gameboardView.contentView
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {

        scrollView.setZoomScale(1, animated: true)
    }
}

extension GameEditorViewController: GameEditorSceneViewDelegate {

    func sceneViewDidTap(_ sceneView: GameEditorSceneView) {

        selectSceneView(sceneView, animated: true)
    }

    func sceneViewIsMoving(scene: MetaScene) {

        gameboardView.updateSelectionRelatedTransitionViews()
    }

    func sceneViewDidPan(scene: MetaScene) {

        saveScene(scene)
    }
}
