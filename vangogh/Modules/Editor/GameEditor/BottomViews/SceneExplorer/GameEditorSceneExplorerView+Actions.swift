///
/// GameEditorSceneExplorerView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension GameEditorSceneExplorerView {

    @objc func closeSceneButtonDidTap() {

        delegate?.closeSceneButtonDidTap()
    }

    @objc func deleteSceneButtonDidTap() {

        delegate?.deleteSceneButtonDidTap()
    }

    @objc func editSceneTitleButtonDidTap() {

        delegate?.editSceneTitleButtonDidTap()
    }

    @objc func sceneTitleLabelDidTap() {

        delegate?.sceneTitleLabelDidTap()
    }

    @objc func manageTransitionsButtonDidTap() {

        delegate?.manageTransitionsButtonDidTap()
    }

    @objc func previewSceneButtonDidTap() {

        delegate?.previewSceneButtonDidTap()
    }

    @objc func editSceneButtonDidTap() {

        delegate?.editSceneButtonDidTap()
    }

    @objc func transitionWillDelete(sender: UIButton) {

        let index = sender.tag
        let transition = transitions[index]

        delegate?.transitionWillDelete(transition, completion: { [weak self] in

            guard let s = self else { return }

            // 重新加载穿梭器

            s.transitions = s.gameBundle.selectedTransitions()
            s.transitionsTableView.reloadData()
        })
    }
}

extension GameEditorSceneExplorerView {

    func selectTransition(_ transition: MetaTransition) {

        delegate?.transitionDidSelect(transition)
    }
}
