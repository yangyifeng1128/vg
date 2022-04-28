///
/// GameEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension GameEditorViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        // 滚动到边缘时，停止滚动

        var contentOffset = scrollView.contentOffset

        let minX: CGFloat = 0
        let maxX: CGFloat = VC.gameboardViewWidth - scrollView.bounds.width
        if contentOffset.x < minX {
            contentOffset.x = minX
        } else if contentOffset.x > maxX {
            contentOffset.x = maxX
        }

        let minY: CGFloat = 0
        let maxY: CGFloat = VC.gameboardViewHeight - scrollView.bounds.height
        if contentOffset.y < minY {
            contentOffset.y = minY
        } else if contentOffset.y > maxY {
            contentOffset.y = maxY
        }

        // 滚动视图

        scrollView.contentOffset = contentOffset

        // 异步保存内容偏移量

        gameBundle.contentOffset = contentOffset
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let s = self else { return }
            MetaGameBundleManager.shared.save(s.gameBundle)
        }
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {

        return gameboardView
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {

        scrollView.setZoomScale(1, animated: true)
    }
}

extension GameEditorViewController: GameEditorSceneViewDelegate {

    func sceneViewDidTap(_ sceneView: GameEditorSceneView) {

        print("[GameEditor] did tap gameEditorSceneView")

        selectScene(sceneView, animated: true)
    }

    func sceneViewIsMoving(scene: MetaScene) {

        // 移动场景视图到边缘时，停止移动

        var location: CGPoint = scene.center

        let minX: CGFloat = GameEditorSceneView.VC.width
        let maxX: CGFloat = VC.gameboardViewWidth - GameEditorSceneView.VC.width
        if location.x < minX {
            location.x = minX
        } else if location.x > maxX {
            location.x = maxX
        }

        let minY: CGFloat = GameEditorSceneView.VC.height
        let maxY: CGFloat = VC.gameboardViewHeight - GameEditorSceneView.VC.height
        if location.y < minY {
            location.y = minY
        } else if location.y > maxY {
            location.y = maxY
        }

        scene.center = location

        // 更新「当前被移动场景」相关的穿梭器视图的位置

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

    func sceneViewDidPan(scene: MetaScene) {

        print("[GameEditor] did pan gameEditorSceneView")

        // 异步保存「当前被移动场景」的位置

        gameBundle.updateScene(scene)
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let s = self else { return }
            MetaGameBundleManager.shared.save(s.gameBundle)
        }
    }

    func sceneViewDidLongPress(_ sceneView: GameEditorSceneView) {

        print("[GameEditor] did long press gameEditorSceneView")

        UIImpactFeedbackGenerator().impactOccurred()

        // 创建提示框

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // 「编辑场景标题」操作

        let editSceneTitleAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("EditTitle", comment: ""), style: .default) { [weak self] _ in
            guard let s = self else { return }
            s.editSceneTitle()
        }
        alert.addAction(editSceneTitleAction)

        // 「删除场景」操作

        let deleteSceneAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .default) { [weak self] _ in
            guard let s = self else { return }
            s.deleteScene()
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

extension GameEditorViewController: AddSceneIndicatorViewDelegate {

    func addSceneIndicatorViewDidTap(_ view: AddSceneIndicatorView) {

        print("[GameEditor] did tap AddSceneIndicatorView")

        // 添加场景方式二

        let location = CGPoint(x: view.center.x, y: view.center.y + AddSceneIndicatorView.VC.closeButtonWidth / 4)
        doAddScene(center: location, forceSelection: true)
    }

    func addSceneIndicatorViewCloseButtonDidTap() {

        print("[GameEditor] did tap AddSceneIndicatorView's closeButton")

        // 隐藏「添加场景提示器视图」

        addSceneIndicatorView.isHidden = true
    }
}
