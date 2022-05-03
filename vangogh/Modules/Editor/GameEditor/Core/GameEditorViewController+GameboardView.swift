///
/// GameEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

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
    func sceneViewAt(_ index: Int) -> GameEditorSceneView {

        let scene: MetaScene = gameBundle.scenes[index]
        let sceneView: GameEditorSceneView = GameEditorSceneView(scene: scene)
        sceneView.delegate = self

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let s = self else { return }
            let url = MetaThumbManager.shared.getThumbImageFileURL(uuid: sceneView.scene.uuid, gameUUID: s.gameBundle.uuid)
            if FileManager.default.fileExists(atPath: url.path) {
                DispatchQueue.main.async {
                    sceneView.thumbImageView.kf.setImage(with: url)
                }
            }
        }

        return sceneView
    }

    /// 设置「穿梭器视图」数量
    func numberOfTransitionViews() -> Int {

        return gameBundle.transitions.count
    }

    /// 设置「穿梭器视图」
    func transitionViewAt(_ index: Int) -> GameEditorTransitionView {

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

extension GameEditorViewController: GameEditorSceneViewDelegate {

    func sceneViewDidTap(_ sceneView: GameEditorSceneView) {

        selectSceneView(sceneView, animated: true)
    }

    func sceneViewIsMoving(scene: MetaScene) {

        // 移动场景视图到边缘时，停止移动

        var location: CGPoint = scene.center

        let minX: CGFloat = GameEditorSceneView.VC.width
        let maxX: CGFloat = GameEditorGameboardView.VC.contentViewWidth - GameEditorSceneView.VC.width
        if location.x < minX {
            location.x = minX
        } else if location.x > maxX {
            location.x = maxX
        }

        let minY: CGFloat = GameEditorSceneView.VC.height
        let maxY: CGFloat = GameEditorGameboardView.VC.contentViewHeight - GameEditorSceneView.VC.height
        if location.y < minY {
            location.y = minY
        } else if location.y > maxY {
            location.y = maxY
        }

        scene.center = location

        // 更新「当前被移动场景」相关的穿梭器视图的位置
// FIXME
//        for transitionView in transitionViewList {
//            if transitionView.startScene.index == scene.index {
//                transitionView.startScene = scene
//                transitionView.updateView()
//            } else if transitionView.endScene.index == scene.index {
//                transitionView.endScene = scene
//                transitionView.updateView()
//            }
//        }
    }

    func sceneViewDidPan(scene: MetaScene) {

        print("[GameEditor] did pan gameEditorSceneView")

        // 保存「当前被移动场景」的位置

        gameBundle.updateScene(scene)
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let s = self else { return }
            MetaGameBundleManager.shared.save(s.gameBundle)
        }
    }

    func sceneViewDidLongPress(_ sceneView: GameEditorSceneView) {

        UIImpactFeedbackGenerator().impactOccurred()

        // 创建提示框

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // 「编辑场景标题」操作

        let editSceneTitleAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("EditTitle", comment: ""), style: .default) { [weak self] _ in
            guard let s = self else { return }
            s.updateSceneTitleLabel()
        }
        alert.addAction(editSceneTitleAction)

        // 「删除场景」操作

        let deleteSceneAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .default) { [weak self] _ in
            guard let s = self else { return }
            s.deleteSceneView()
        }
        alert.addAction(deleteSceneAction)

        // 「取消」操作

        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
        }
        alert.addAction(cancelAction)

        // 兼容 iPad 应用

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sceneView
            popoverController.sourceRect = sceneView.bounds
        }

        // 展示提示框

        present(alert, animated: true, completion: nil)
    }
}
