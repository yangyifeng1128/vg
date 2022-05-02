///
/// GameEditorSceneExplorerViewDataSource
///
/// © 2022 Beijing Mengma Education Technology Co., L
//

protocol GameEditorSceneExplorerViewDataSource: AnyObject {

    func selectedSceneIndex() -> Int

    func numberOfSceneViews() -> Int
    func sceneViewAt(_ index: Int) -> GameEditorSceneView

    func numberOfTransitionViews() -> Int
    func transitionViewAt(_ index: Int) -> GameEditorTransitionView
}
