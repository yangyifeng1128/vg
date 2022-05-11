///
/// GameEditorSceneView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

protocol GameEditorSceneViewDelegate: AnyObject {

    func sceneViewDidTap(scene: MetaScene)
    func sceneViewIsMoving(scene: MetaScene)
    func sceneViewDidPan(scene: MetaScene)
}
