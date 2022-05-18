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

        // 保存场景资源包

        saveSceneBundle() { [weak self] in

            guard let s = self else { return }

            // 暂停播放

            if !s.timeline.videoChannel.isEmpty {
                s.pause()
            }

            // 激活「时间线-组件项」视图

            s.timelineView.activateNodeItemView(node: nodeView.node)

            // 展示「编辑组件项 Sheet 视图控制器」

            s.presentEditNodeItemSheetViewController(node: nodeView.node)
        }
    }

    func saveBundleWhenNodeViewChanged(node: MetaNode) {

        guard let nodeTypeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: node.nodeType) else { return }
        print("[SceneEditor] save bundle when \"\(nodeTypeTitle) \(node.index)\" changed")

        // 更新组件数据

        sceneBundle.updateNode(node)
        saveSceneBundle()
    }
}
