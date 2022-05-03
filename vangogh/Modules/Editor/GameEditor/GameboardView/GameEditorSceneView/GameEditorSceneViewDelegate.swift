///
/// GameEditorSceneView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

protocol GameEditorSceneViewDelegate: AnyObject {

    func sceneViewDidTap(_ sceneView: GameEditorSceneView)
    func sceneViewIsMoving(scene: MetaScene)
    func sceneViewDidPan(scene: MetaScene)
}
