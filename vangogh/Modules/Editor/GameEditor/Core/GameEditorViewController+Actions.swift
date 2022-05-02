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

    @objc func addTransitionDiagramViewDidTap() {

        pushTargetScenesVC()
    }
}

extension GameEditorViewController {

    /// 重置父视图控制器
    func resetParentViewControllers() {

        // 如果刚刚从 NewGameViewController 跳转过来，则在返回上级时直接跳过 NewGameViewController

        if parentType == .new {
            guard var viewControllers = navigationController?.viewControllers else { return }
            viewControllers.remove(at: viewControllers.count - 2)
            navigationController?.setViewControllers(viewControllers, animated: false)
            parentType = .draft
        }
    }

    /// 重新加载外部变更记录
    func reloadExternalChanges() {

        let changes = GameEditorExternalChangeManager.shared.get()
        for (key, value) in changes {
            switch key {
            case .updateGameTitle:
                gameTitleLabel.text = game.title
                break
            case .updateSceneViewTitle:
                guard let sceneUUID = value as? String else { continue }
                gameboardView.updateSceneViewTitle(sceneUUID: sceneUUID)
                break
            case .updateSceneViewThumbImage:
                guard let sceneUUID = value as? String else { continue }
                if let thumbImage = MetaThumbManager.shared.loadSceneThumbImage(sceneUUID: sceneUUID, gameUUID: gameBundle.uuid) {
                    gameboardView.updateSceneViewThumbImage(sceneUUID: sceneUUID, thumbImage: thumbImage)
                }
                break
            case .addTransitionView:
                guard let transition = value as? MetaTransition, let startScene = gameBundle.findScene(index: transition.from), let endScene = gameBundle.findScene(index: transition.to) else { continue }
                gameboardView.addTransitionView(startScene: startScene, endScene: endScene)
                break
            }
        }

        GameEditorExternalChangeManager.shared.removeAll()
    }

    /// 重新加载作品资源包会话状态
    func reloadGameBundleSession() {

        // 重新加载「底部视图」

        if gameBundle.selectedSceneIndex == 0 {
            reloadToolBarView(animated: false)
        } else {
            reloadSceneExplorerView(animated: false)
        }

        // 设置内容偏移量

        var contentOffset: CGPoint = gameBundle.contentOffset
        if contentOffset == GVC.defaultGameboardViewContentOffset {
            contentOffset = CGPoint(x: (GameEditorGameboardView.VC.contentViewWidth - view.bounds.width) / 2, y: (GameEditorGameboardView.VC.contentViewHeight - view.bounds.height) / 2)
        }
        gameboardView.contentOffset = contentOffset
    }

    /// 显示消息
    func showMessage() {

        if let sceneSavedMessage = sceneSavedMessage {
            let toast = Toast.default(text: sceneSavedMessage)
            toast.show()
            self.sceneSavedMessage = nil
        }
    }

    /// 提示作品已保存
    func sendGameSavedMessage() {

        let title: String = (game.title.count > 8) ? game.title.prefix(8) + "..." : game.title
        if let parent = navigationController?.viewControllers[0] as? CompositionViewController {
            parent.draftSavedMessage = title + " " + NSLocalizedString("SavedToDrafts", comment: "")
        }
    }

    /// 外观切换后更新视图
    func updateViewsWhenTraitCollectionChanged() {

        // 更新「作品标题标签」的图层阴影颜色

        gameTitleLabel.layer.shadowColor = UIColor.secondarySystemBackground.cgColor
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

    /// 跳转至「目标场景视图控制器」
    func pushTargetScenesVC() {

        let targetScenesVC = TargetScenesViewController(gameBundle: gameBundle)
        targetScenesVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(targetScenesVC, animated: true)
    }

    /// 跳转至「穿梭器编辑器视图控制器」
    func pushTransitionEditorVC(transition: MetaTransition) {

        let transitionEditorVC = TransitionEditorViewController(gameBundle: gameBundle, transition: transition)
        transitionEditorVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(transitionEditorVC, animated: true)
    }

    /// 展示「场景模拟器视图控制器」
    func presentSceneEmulatorVC() {

        guard let selectedScene = gameBundle.selectedScene(), let selectedSceneBundle = MetaSceneBundleManager.shared.load(sceneUUID: selectedScene.uuid, gameUUID: gameBundle.uuid) else { return }
        let sceneEmulatorVC = SceneEmulatorViewController(sceneBundle: selectedSceneBundle, gameBundle: gameBundle)
        sceneEmulatorVC.definesPresentationContext = false
        sceneEmulatorVC.modalPresentationStyle = .currentContext

        present(sceneEmulatorVC, animated: true, completion: nil)
    }

    /// 展示「场景编辑器视图控制器」
    func presentSceneEditorVC() {

        guard let selectedScene = gameBundle.selectedScene(), let selectedSceneBundle = MetaSceneBundleManager.shared.load(sceneUUID: selectedScene.uuid, gameUUID: gameBundle.uuid) else { return }
        let sceneEditorVC = SceneEditorViewController(sceneBundle: selectedSceneBundle, gameBundle: gameBundle)
        let sceneEditorNav = UINavigationController(rootViewController: sceneEditorVC)
        sceneEditorNav.definesPresentationContext = false
        sceneEditorNav.modalPresentationStyle = .currentContext

        present(sceneEditorNav, animated: true, completion: nil)
    }
}

extension GameEditorViewController {

    /// 添加场景
    func addSceneView(center location: CGPoint, forceSelection: Bool = false) {

        addScene(center: location) { [weak self] scene in
            guard let s = self else { return }
            s.gameboardView.addSceneView(scene: scene) { sceneView in
                sceneView.delegate = self
                if forceSelection {
                    s.selectSceneView(sceneView, animated: true)
                } else {
                    if s.gameBundle.selectedSceneIndex == 0 {
//                        s.resetBottomView(sceneSelected: false, animated: false)
                        s.reloadToolBarView(animated: false)
                    } else {
//                        s.resetBottomView(sceneSelected: true, animated: false)
                        s.reloadSceneExplorerView(animated: false)
                    }
                }
            }
        }
    }

    /// 选择「场景视图」
    func selectSceneView(_ sceneView: GameEditorSceneView?, animated: Bool) {

        gameboardView.selectSceneView(sceneView, animated: animated) { [weak self] sceneView in
            guard let s = self else { return }
            s.saveSelectedSceneIndex(sceneView.scene.index) {
                s.reloadSceneExplorerView(animated: false)
                s.gameboardView.centerSceneView(scene: sceneView.scene, animated: animated) { contentOffset in
                    s.saveContentOffset(contentOffset)
                }
            }
        }
    }

    /// 关闭「场景视图」
    func closeSceneView() {

        let previousSelectedScene = gameBundle.selectedScene() // 暂存先前选中的场景

        // 重置「底部视图」

//        resetBottomView(sceneSelected: false, animated: true)
        reloadToolBarView(animated: true)

        // 尽量将先前选中的「场景视图」置于中央，并保存内容偏移量

        if let scene = previousSelectedScene {
            gameboardView.centerSceneView(scene: scene, animated: true) { [weak self] contentOffset in
                guard let s = self else { return }
                s.saveContentOffset(contentOffset)
            }
        }
    }

    /// 删除「场景视图」
    func deleteScene() {

        // 创建提示框

        let alert = UIAlertController(title: NSLocalizedString("DeleteScene", comment: ""), message: NSLocalizedString("DeleteSceneInfo", comment: ""), preferredStyle: .alert)

        // 「确认」操作

        let confirmAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { [weak self] _ in

            guard let s = self else { return }
            s.gameboardView.deleteSelectedSceneView() {
                s.deleteSelectedScene() {
//                    s.resetBottomView(sceneSelected: false, animated: true)
                    s.reloadToolBarView(animated: true)
                }
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

            s.saveSceneTitle(title) {
//                s.resetBottomView(sceneSelected: true, animated: true)
                s.reloadSceneExplorerView(animated: true)
                s.gameboardView.updateSceneViewTitle(sceneIndex: s.gameBundle.selectedSceneIndex)
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

    /// 管理穿梭器列表
    func manageTransitions() {

    }

    /// 删除「穿梭器视图」
    func deleteTransitionView(_ transition: MetaTransition, completion: @escaping () -> Void) {

        // 创建提示框

        let alert = UIAlertController(title: NSLocalizedString("DeleteTransition", comment: ""), message: NSLocalizedString("DeleteTransitionInfo", comment: ""), preferredStyle: .alert)

        // 「确认」操作

        let confirmAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { [weak self] _ in

            guard let s = self else { return }
            s.gameboardView.deleteTransitionView(transition: transition) { _ in
                completion()
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
}

extension GameEditorViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard let text = textField.text else { return true }
        if range.length + range.location > text.count { return false }
        let newLength = text.count + string.count - range.length
        return newLength <= 255
    }
}
