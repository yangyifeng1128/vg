///
/// GameEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AwaitToast
import OSLog
import UIKit

extension GameEditorViewController {

    @objc func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }

    @objc func publishButtonDidTap() {

        pushPublicationVC()
    }

    @objc func gameSettingsButtonDidTap() {

        pushGameSettingsVC()
    }

    @objc func gameboardViewDidTap(_ sender: UITapGestureRecognizer) {

        // 添加场景方式一

        if willAddScene {
            let location: CGPoint = sender.location(in: sender.view)
            doAddScene(center: location)
        } else {
            closeScene()
        }
    }

    @objc func gameboardViewDidLongPress(_ sender: UILongPressGestureRecognizer) {

        if !willAddScene {

            let location: CGPoint = sender.location(in: sender.view)
            addSceneIndicatorView.center = CGPoint(x: location.x, y: location.y - AddSceneIndicatorView.VC.height / 2)
            addSceneIndicatorView.isHidden = false // 显示「添加场景提示器视图」
        }
    }

    @objc func addTransitionDiagramViewDidTap() {

        addTransition()
    }
}

extension GameEditorViewController {

    /// 显示消息
    func showMessage() {

        if let sceneSavedMessage = sceneSavedMessage {
            let toast = Toast.default(text: sceneSavedMessage)
            toast.show()
            self.sceneSavedMessage = nil
        }
    }

    /// 提示草稿已保存
    func sendDraftSavedMessage() {

        let title: String = (game.title.count > 8) ? game.title.prefix(8) + "..." : game.title
        if let parent = navigationController?.viewControllers[0] as? CompositionViewController {
            parent.draftSavedMessage = title + " " + NSLocalizedString("SavedToDrafts", comment: "")
        }
    }

    /// 取消高亮显示「先前选中场景」相关的场景视图
    func unhighlightSelectionRelatedViews() {

        let previousSelectedSceneIndex = gameBundle.selectedSceneIndex
        let previousSelectedSceneView = sceneViewList.first(where: { $0.scene.index == previousSelectedSceneIndex })
        previousSelectedSceneView?.isActive = false
        unhighlightRelatedSceneViews(sceneView: previousSelectedSceneView)
        unhighlightRelatedTransitionViews(sceneView: previousSelectedSceneView)
    }

    /// 外观切换后更新视图
    func updateViewsWhenTraitCollectionChanged() {

        // 更新「作品标题标签」的图层阴影颜色

        gameTitleLabel.layer.shadowColor = UIColor.secondarySystemBackground.cgColor

        // 重置全部「穿梭器视图」

        for transitionView in transitionViewList {
            transitionView.unhighlight()
        }

        // 更新「当前选中场景」相关的穿梭器视图、场景视图

        if gameBundle.selectedSceneIndex != 0 {
            let sceneView = sceneViewList.first(where: { $0.scene.index == gameBundle.selectedSceneIndex })
            highlightRelatedTransitionViews(sceneView: sceneView) // 高亮显示「当前选中场景」相关的穿梭器视图
            highlightRelatedSceneViews(sceneView: sceneView) // 高亮显示「当前选中场景」相关的场景视图
        }

        // 隐藏「添加场景提示器视图」

        addSceneIndicatorView.isHidden = true
    }
}

extension GameEditorViewController {

    /// 跳转至「发布作品控制器」
    func pushPublicationVC() {

        let publicationVC = PublicationViewController(game: game)
        publicationVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(publicationVC, animated: true)
    }

    /// 跳转至「作品设置控制器」
    func pushGameSettingsVC() {

        let gameSettingsVC = GameSettingsViewController(game: game)
        gameSettingsVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(gameSettingsVC, animated: true)
    }

    /// 添加场景
    func addScene(center: CGPoint) -> GameEditorSceneView? {

        let scene = gameBundle.addScene(center: center)
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let s = self else { return }
            MetaGameBundleManager.shared.save(s.gameBundle)
        }

        let sceneView: GameEditorSceneView = GameEditorSceneView(scene: scene)
        sceneView.delegate = self
        gameboardView.addSubview(sceneView)
        sceneViewList.append(sceneView)

        return sceneView
    }

    func selectScene(_ sceneView: GameEditorSceneView?, animated: Bool) {

        guard let sceneView = sceneView else { return }

        gameboardView.bringSubviewToFront(sceneView)

        // 重置「先前选中场景」视图

        let previousSelectedSceneIndex = gameBundle.selectedSceneIndex
        let previousSelectedSceneView = sceneViewList.first(where: { $0.scene.index == previousSelectedSceneIndex })
        previousSelectedSceneView?.isActive = false
        unhighlightRelatedSceneViews(sceneView: previousSelectedSceneView) // 取消高亮显示「先前选中场景」相关的场景视图
        unhighlightRelatedTransitionViews(sceneView: previousSelectedSceneView) // 取消高亮显示「先前选中场景」相关的穿梭器视图

        // 保存「当前选中场景」的索引

        gameBundle.selectedSceneIndex = sceneView.scene.index
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let s = self else { return }
            MetaGameBundleManager.shared.save(s.gameBundle)
        }

        // 重置底部视图

        willAddScene = false
        resetBottomView(sceneSelected: true, animated: false)

        // 尽量将场景视图置于中央，并保存内容偏移量

        centerScene(sceneView.scene, animated: animated)
    }

    func doAddScene(center location: CGPoint, forceSelection: Bool = false) {

        // 对齐网格

        let gridWidth: CGFloat = GameEditorViewController.VC.gameboardViewGridWidth
        let snappedLocation = CGPoint(x: gridWidth * floor(location.x / gridWidth), y: gridWidth * floor(location.y / gridWidth))

        // 新建场景视图

        guard let sceneView = addScene(center: snappedLocation) else { return }
        print("[GameEditor] do add scene \(sceneView.scene.index)")

        // 重置底部视图

        if forceSelection {

            selectScene(sceneView, animated: true)

        } else {

            willAddScene = false
            if gameBundle.selectedSceneIndex == 0 {
                resetBottomView(sceneSelected: false, animated: false)
            } else {
                resetBottomView(sceneSelected: true, animated: false)
            }
        }

        gameboardView.bringSubviewToFront(addSceneIndicatorView) // 不管采用哪种添加场景方式，都要确保「添加场景提示器视图」置于最顶层
    }

    func closeScene() {

        let previousSelectedScene = gameBundle.selectedScene() // 暂存「先前选中场景」

        // 重置底部视图

        resetBottomView(sceneSelected: false, animated: true)

        // 尽量将「先前选中场景」视图置于中央，并保存内容偏移量

        if let scene = previousSelectedScene {
            centerScene(scene, animated: true)
        }
    }

    func deleteScene() {

        // 创建提示框

        let alert = UIAlertController(title: NSLocalizedString("DeleteScene", comment: ""), message: NSLocalizedString("DeleteSceneInfo", comment: ""), preferredStyle: .alert)

        // 「确认」操作

        let confirmAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { [weak self] _ in

            guard let s = self else { return }

            // 获取「当前选中场景」的索引和 UUID

            let selectedSceneIndex = s.gameBundle.selectedSceneIndex
            guard let selectedScene = s.gameBundle.selectedScene() else { return }
            let selectedSceneUUID = selectedScene.uuid

            // 删除「当前选中场景」相关的全部穿梭器视图

            for (i, transitionView) in s.transitionViewList.enumerated().reversed() { // 倒序遍历元素可保证安全删除

                if transitionView.startScene.index == selectedSceneIndex {

                    // 取消高亮显示「当前选中穿梭器」相关的「结束场景」视图

                    let endSceneView = s.sceneViewList.first(where: { $0.scene.index == transitionView.endScene.index })
                    endSceneView?.unhighlight()

                    // 删除「当前选中穿梭器」

                    transitionView.removeFromSuperview()
                    s.transitionViewList.remove(at: i)

                } else if transitionView.endScene.index == selectedSceneIndex {

                    // 取消高亮显示「当前选中穿梭器」相关的「开始场景」视图

                    let startSceneView = s.sceneViewList.first(where: { $0.scene.index == transitionView.startScene.index })
                    startSceneView?.unhighlight()

                    // 删除「当前选中穿梭器」

                    transitionView.removeFromSuperview()
                    s.transitionViewList.remove(at: i)
                }
            }

            // 删除「当前选中场景」视图

            for (i, sceneView) in s.sceneViewList.enumerated().reversed() { // 倒序遍历元素可保证安全删除
                if sceneView.scene.index == selectedSceneIndex {
                    sceneView.removeFromSuperview()
                    s.sceneViewList.remove(at: i)
                    break // 找到就退出
                }
            }

            // 保存「删除场景」信息

            s.gameBundle.deleteSelectedScene()
            DispatchQueue.global(qos: .background).async {
                MetaGameBundleManager.shared.save(s.gameBundle)
                MetaSceneBundleManager.shared.delete(sceneUUID: selectedSceneUUID, gameUUID: s.gameBundle.uuid)
            }

            // 重置底部视图

            s.resetBottomView(sceneSelected: false, animated: true)
        }
        alert.addAction(confirmAction)

        // 「取消」操作

        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
        }
        alert.addAction(cancelAction)

        // 展示提示框

        present(alert, animated: true, completion: nil)
    }

    /// 编辑作品标题
    func editSceneTitle() {

        // 创建提示框

        let alert = UIAlertController(title: NSLocalizedString("EditSceneTitle", comment: ""), message: nil, preferredStyle: .alert)

        // 输入框

        alert.addTextField { [weak self] textField in

            guard let s = self else { return }

            textField.font = .systemFont(ofSize: GVC.alertTextFieldFontSize, weight: .regular)
            textField.text = s.gameBundle.selectedScene()?.title
            textField.returnKeyType = .done
            textField.delegate = self
        }

        // 「确认」操作

        let confirmAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { [weak self] _ in

            guard let s = self else { return }

            guard let title = alert.textFields?.first?.text, !title.isEmpty else {
                let toast = Toast.default(text: NSLocalizedString("EmptyTitleNotAllowed", comment: ""))
                toast.show()
                return
            }

            // 保存「当前选中场景」的标题

            guard let scene = s.gameBundle.selectedScene() else { return }
            scene.title = title
            s.gameBundle.updateScene(scene)
            DispatchQueue.global(qos: .background).async {
                MetaGameBundleManager.shared.save(s.gameBundle)
            }

            s.saveSceneTitle(s.gameBundle, newTitle: title) {

                // 重置底部视图

                s.resetBottomView(sceneSelected: true, animated: true)

                // 更新「当前选中场景」视图的标题标签

                let sceneView = s.sceneViewList.first(where: { $0.scene.index == s.gameBundle.selectedSceneIndex })
                sceneView?.updateTitleLabelAttributedText()

                Logger.composition.info("saved scene title: \"\(title)\"")
            }
        }
        alert.addAction(confirmAction)

        // 「取消」操作

        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
        }
        alert.addAction(cancelAction)

        // 展示提示框

        present(alert, animated: true, completion: nil)
    }

    func addTransition() {

        let targetScenesVC = TargetScenesViewController(gameBundle: gameBundle)
        targetScenesVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(targetScenesVC, animated: true)
    }

    func manageTransitions() {

    }

    func previewScene() {

        guard let selectedScene = gameBundle.selectedScene(), let selectedSceneBundle = MetaSceneBundleManager.shared.load(sceneUUID: selectedScene.uuid, gameUUID: gameBundle.uuid) else { return }
        let sceneEmulatorVC = SceneEmulatorViewController(sceneBundle: selectedSceneBundle, gameBundle: gameBundle)
        sceneEmulatorVC.definesPresentationContext = false
        sceneEmulatorVC.modalPresentationStyle = .currentContext

        present(sceneEmulatorVC, animated: true, completion: nil)
    }

    func editScene() {

        guard let selectedScene = gameBundle.selectedScene(), let selectedSceneBundle = MetaSceneBundleManager.shared.load(sceneUUID: selectedScene.uuid, gameUUID: gameBundle.uuid) else { return }
        let sceneEditorVC = SceneEditorViewController(sceneBundle: selectedSceneBundle, gameBundle: gameBundle)
        let sceneEditorNav = UINavigationController(rootViewController: sceneEditorVC)
        sceneEditorNav.definesPresentationContext = false
        sceneEditorNav.modalPresentationStyle = .currentContext

        present(sceneEditorNav, animated: true, completion: nil)

    }

    func deleteTransition(_ transition: MetaTransition, completion: @escaping () -> Void) {

        // 创建提示框

        let alert = UIAlertController(title: NSLocalizedString("DeleteTransition", comment: ""), message: NSLocalizedString("DeleteTransitionInfo", comment: ""), preferredStyle: .alert)

        // 「确认」操作

        let confirmAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { [weak self] _ in

            guard let s = self else { return }

            for (i, transitionView) in s.transitionViewList.enumerated().reversed() { // 倒序遍历元素可保证安全删除

                if transitionView.startScene.index == transition.from &&
                    transitionView.endScene.index == transition.to {

                    // 删除「待删除穿梭器」视图

                    transitionView.removeFromSuperview()
                    s.transitionViewList.remove(at: i)

                    // 取消高亮显示「待删除穿梭器」相关的「结束场景」视图

                    let oppositeTransitionView = s.transitionViewList.first(where: {
                        $0.startScene.index == transition.to && $0.endScene.index == transition.from
                    }) // 如果存在反向的穿梭器，就不需要取消高亮显示「结束场景」视图了
                    if oppositeTransitionView == nil {
                        let endSceneView = s.sceneViewList.first(where: { $0.scene.index == transitionView.endScene.index })
                        endSceneView?.unhighlight()
                    }
                }
            }

            // 保存「删除穿梭器」信息

            s.gameBundle.deleteTransition(transition)
            DispatchQueue.global(qos: .background).async {
                MetaGameBundleManager.shared.save(s.gameBundle)
            }

            // 完成之后的回调

            completion()
        }
        alert.addAction(confirmAction)

        // 「取消」操作

        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
        }
        alert.addAction(cancelAction)

        // 展示提示框

        present(alert, animated: true, completion: nil)
    }
}

extension GameEditorViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard let text = textField.text else { return true }
        if range.length + range.location > text.count { return false }
        let newLength = text.count + string.count - range.length
        return newLength <= 255
    }
}
