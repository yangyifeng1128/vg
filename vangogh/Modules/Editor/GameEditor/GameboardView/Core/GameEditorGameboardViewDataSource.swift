///
/// GameEditorGameboardViewDataSource
///
/// © 2022 Beijing Mengma Education Technology Co., L
//

protocol GameEditorGameboardViewDataSource: AnyObject {

    func selectedSceneIndex() -> Int

    func numberOfSceneViews() -> Int
    func sceneViewAt(_ index: Int) -> GameEditorSceneView

    func numberOfTransitionViews() -> Int
    func transitionViewAt(_ index: Int) -> GameEditorTransitionView
}

extension GameEditorGameboardViewDataSource {

    func addSceneIndicatorView() -> AddSceneIndicatorView? {

        return nil
    }
}
