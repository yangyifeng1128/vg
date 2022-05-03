///
/// GameEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension GameEditorViewController: GameEditorSceneExplorerViewDataSource {

    func selectedScene() -> MetaScene? {

        return gameBundle.selectedScene()
    }

    func numberOfTransitionTableViewCells() -> Int {

        return gameBundle.selectedTransitions().count
    }

    func transitionTableViewCell(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

        let transitions: [MetaTransition] = gameBundle.selectedTransitions()
        guard let startScene = gameBundle.selectedScene() else { fatalError("Unexpected start scene") }
        guard let endScene = gameBundle.findScene(index: transitions[indexPath.row].to) else {
            fatalError("Unexpected end scene")
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: GameEditorTransitionTableViewCell.reuseId) as? GameEditorTransitionTableViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备「条件标题标签」

        cell.prepareConditionsTitleLabelAttributedText(startScene: startScene, conditions: transitions[indexPath.row].conditions)

        // 准备「缩略图视图」

        if let thumbImage = MetaThumbManager.shared.loadSceneThumbImage(sceneUUID: endScene.uuid, gameUUID: gameBundle.uuid) {
            cell.endSceneThumbImageView.image = thumbImage
        } else {
            cell.endSceneThumbImageView.image = .sceneBackgroundThumb
        }

        // 准备「结束场景标题标签」

        cell.prepareEndSceneTitleLabelAttributedText(endScene: endScene)

        // 准备「删除按钮」

        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(transitionWillDelete), for: .touchUpInside)

        return cell
    }

    /// 即将删除穿梭器
    @objc func transitionWillDelete(sender: UIButton) {

        let index = sender.tag
        let transitions: [MetaTransition] = gameBundle.selectedTransitions()
        deleteTransitionView(transitions[index])
    }
}

extension GameEditorViewController: GameEditorSceneExplorerViewDelegate {

    func closeSceneButtonDidTap() {

        closeSceneView()
    }

    func deleteSceneButtonDidTap() {

        deleteSceneView()
    }

    func sceneTitleLabelDidTap() {

        updateSceneTitleLabel()
    }

    func manageTransitionsButtonDidTap() {

    }

    func previewSceneButtonDidTap() {

        presentSceneEmulatorVC()
    }

    func editSceneButtonDidTap() {

        presentSceneEditorVC()
    }

    func transitionTableViewCellDidSelect(_ tableView: UITableView, indexPath: IndexPath) {

        let transitions: [MetaTransition] = gameBundle.selectedTransitions()
        pushTransitionEditorVC(transition: transitions[indexPath.row])
    }
}
