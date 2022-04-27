///
/// GameEditorSceneBottomViewDelegate
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

protocol GameEditorSceneBottomViewDelegate: AnyObject {

    func closeSceneButtonDidTap()
    func deleteSceneButtonDidTap()
    func editSceneTitleButtonDidTap()
    func sceneTitleLabelDidTap()
    func manageTransitionsButtonDidTap()
    func previewSceneButtonDidTap()
    func editSceneButtonDidTap()
    func transitionWillDelete(_ transition: MetaTransition, completion: @escaping () -> Void)
    func transitionDidSelect(_ transition: MetaTransition)
}
