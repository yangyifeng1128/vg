///
/// SceneEditorPlayerViewDelegate
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

protocol SceneEditorPlayerViewDelegate: AnyObject {

    func nodeViewWillBeginEditing(_ nodeView: MetaNodeView)
    func saveBundleWhenNodeViewChanged(node: MetaNode)
}
