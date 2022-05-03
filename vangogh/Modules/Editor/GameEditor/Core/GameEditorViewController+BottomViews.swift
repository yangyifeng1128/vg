///
/// GameEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension GameEditorViewController: GameEditorToolBarViewDelegate, GameEditorWillAddSceneViewDelegate, GameEditorSceneExplorerViewDelegate {

    func addSceneButtonDidTap() {

        print("[GameEditor] did tap addSceneButton")

        reloadWillAddSceneView(animated: true) { [weak self] in
            guard let s = self else { return }
            s.gameboardView.unhighlightSelectionRelatedViews()
        }
    }

    func cancelAddingSceneButtonDidTap() {

        print("[GameEditor] did tap cancelAddingSceneButton")

        reloadToolBarView(animated: false)
    }

    func closeSceneButtonDidTap() {

        closeSceneView()
    }

    func deleteSceneButtonDidTap() {

        deleteSceneView()
    }

    func editSceneTitleButtonDidTap() {

        updateSceneTitleLabel()
    }

    func sceneTitleLabelDidTap() {

        updateSceneTitleLabel()
    }

    func manageTransitionsButtonDidTap() {

        print("[GameEditor] did tap manageTransitionsButton")
    }

    func previewSceneButtonDidTap() {

        presentSceneEmulatorVC()
    }

    func editSceneButtonDidTap() {

        presentSceneEditorVC()
    }

    func transitionWillDelete(_ transition: MetaTransition, completion: @escaping () -> Void) {

        print("[GameEditor] will delete transition: \(transition)")

        deleteTransitionView(transition, completion: completion)
    }

    func transitionDidSelect(_ transition: MetaTransition) {

        pushTransitionEditorVC(transition: transition)
    }
}
