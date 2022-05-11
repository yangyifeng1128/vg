///
/// GameEditorGameboardViewDataSource
///
/// © 2022 Beijing Mengma Education Technology Co., L
//

protocol GameEditorGameboardViewDataSource: AnyObject {

    func selectedSceneIndex() -> Int

    func numberOfSceneViews() -> Int
    func sceneView(at index: Int) -> GameEditorSceneView

    func numberOfTransitionViews() -> Int
    func transitionView(at index: Int) -> GameEditorTransitionView
}
