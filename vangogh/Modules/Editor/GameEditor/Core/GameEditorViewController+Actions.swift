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

    /// 添加「场景视图」
    func addSceneView(center location: CGPoint, forceSelection: Bool = false) {

        addScene(center: location) { [weak self] scene in
            guard let s = self else { return }
            s.gameboardView.addSceneView(scene: scene) { sceneView in
                sceneView.delegate = self
                if forceSelection {
                    s.selectSceneView(sceneView, animated: true)
                } else {
                    s.reloadToolBarView(animated: false) { [weak self] in
                        guard let s = self else { return }
                        s.saveSelectedSceneIndex(0)
                    }
                }
                Logger.gameEditor.info("added scene view: \(sceneView.scene)")
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
                    Logger.gameEditor.info("selected scene view: \(sceneView.scene)")
                }
            }
        }
    }

    /// 关闭「场景视图」
    func closeSceneView() {

        let previousSelectedScene: MetaScene? = gameBundle.selectedScene() // 暂存先前选中的场景

        // 重置「底部视图」

        reloadToolBarView(animated: true) { [weak self] in
            guard let s = self else { return }
            s.saveSelectedSceneIndex(0)
            if let scene = previousSelectedScene {
                s.gameboardView.centerSceneView(scene: scene, animated: true) { contentOffset in
                    s.saveContentOffset(contentOffset)
                }
                Logger.gameEditor.info("closed scene view: \(scene)")
            }
        }
    }

    /// 更新「作品标题标签」
    func updateSceneTitleLabel() {

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

            s.saveSelectedSceneTitle(title) {
                s.reloadSceneExplorerView(animated: true)
                s.gameboardView.updateSceneViewTitleLabel(sceneIndex: s.gameBundle.selectedSceneIndex)
                Logger.composition.info("updated scene title: \"\(title)\"")
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

    /// 删除「场景视图」
    func deleteSceneView() {

        // 创建提示框

        let alert = UIAlertController(title: NSLocalizedString("DeleteScene", comment: ""), message: NSLocalizedString("DeleteSceneInfo", comment: ""), preferredStyle: .alert)

        // 「确认」操作

        let confirmAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { [weak self] _ in

            guard let s = self else { return }
            let previousSelectedScene: MetaScene? = s.gameBundle.selectedScene() // 暂存先前选中的场景
            s.gameboardView.deleteSelectionRelatedViews() {
                s.deleteSelectedScene() {
                    s.reloadToolBarView(animated: true) {
                        s.saveSelectedSceneIndex(0)
                        if let scene = previousSelectedScene {
                            Logger.gameEditor.info("deleted scene view: \(scene)")
                        }
                    }
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
