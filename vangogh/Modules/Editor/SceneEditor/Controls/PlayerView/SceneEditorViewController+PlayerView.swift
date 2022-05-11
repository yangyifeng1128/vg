///
/// SceneEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension SceneEditorViewController: SceneEditorPlayerViewDataSource {

    func aspectRatioType() -> MetaSceneAspectRatioType {

        return sceneBundle.aspectRatioType
    }
}

extension SceneEditorViewController: SceneEditorPlayerViewDelegate {

    func nodeViewWillBeginEditing(_ nodeView: MetaNodeView) {

        guard let node = nodeView.node, let nodeTypeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: node.nodeType) else { return }
        print("[SceneEditor] \"\(nodeTypeTitle) \(node.index)\" will begin editing")

        // 暂停并保存资源包

        if !timeline.videoChannel.isEmpty {
            pause()
        }
        saveSceneBundle()

        // 激活「时间线-组件项」视图

        timelineView.activateNodeItemView(node: nodeView.node)

        // 展示「编辑组件项 Sheet 视图控制器」

        presentEditNodeItemSheetViewController(node: nodeView.node)
    }

    func saveBundleWhenNodeViewChanged(node: MetaNode) {

        guard let nodeTypeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: node.nodeType) else { return }
        print("[SceneEditor] save bundle when \"\(nodeTypeTitle) \(node.index)\" changed")

        // 更新组件数据

        sceneBundle.updateNode(node)

        // 保存资源包

        saveSceneBundle()
    }
}
