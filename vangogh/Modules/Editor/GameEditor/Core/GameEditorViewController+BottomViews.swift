///
/// GameEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension GameEditorViewController: GameEditorToolBarViewDelegate, GameEditorWillAddSceneViewDelegate, GameEditorSceneExplorerViewDelegate {

    func addSceneButtonDidTap() {

        print("[GameEditor] did tap addSceneButton")

//        willAddScene = true
//        resetBottomView(sceneSelected: false, animated: true)
        reloadWillAddSceneView(animated: true)
    }

    func cancelAddingSceneButtonDidTap() {

        print("[GameEditor] did tap cancelAddingSceneButton")

//        willAddScene = false
//        resetBottomView(sceneSelected: false, animated: true)
        reloadToolBarView(animated: false)
    }

    func closeSceneButtonDidTap() {

        closeSceneView()
    }

    func deleteSceneButtonDidTap() {

        print("[GameEditor] did tap deleteSceneButton")

        deleteScene()
    }

    func editSceneTitleButtonDidTap() {

        print("[GameEditor] did tap editSceneTitleButton")

        editSceneTitle()
    }

    func sceneTitleLabelDidTap() {

        print("[GameEditor] did tap editSceneTitleButton")

        editSceneTitle()
    }

    func manageTransitionsButtonDidTap() {

        print("[GameEditor] did tap manageTransitionsButton")

        manageTransitions()
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
