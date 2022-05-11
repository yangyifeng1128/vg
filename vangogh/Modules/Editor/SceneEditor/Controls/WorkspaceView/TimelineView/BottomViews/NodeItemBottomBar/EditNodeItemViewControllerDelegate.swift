///
/// EditNodeItemViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

protocol EditNodeItemViewControllerDelegate: AnyObject {

    func saveBundleWhenNodeItemViewChanged(node: MetaNode, rules: [MetaRule])
    func deleteMetaNodeFromEditNodeItemViewController(node: MetaNode)
}
