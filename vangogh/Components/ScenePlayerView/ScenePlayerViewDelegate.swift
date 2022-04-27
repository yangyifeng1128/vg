///
/// ScenePlayerViewDelegate
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

protocol ScenePlayerViewDelegate: AnyObject {

    func nodeViewWillBeginEditing(_ nodeView: MetaNodeView)
    func saveBundleWhenNodeViewChanged(node: MetaNode)
}
