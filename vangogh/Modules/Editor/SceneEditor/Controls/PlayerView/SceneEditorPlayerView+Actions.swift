///
/// SceneEditorPlayerView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension SceneEditorPlayerView {

    @objc func nodeViewWillBeginEditing(_ sender: UITapGestureRecognizer) {

        guard let nodeView: MetaNodeView = sender.view as? MetaNodeView else { return }

        delegate?.nodeViewWillBeginEditing(nodeView)
    }

    func saveBundleWhenNodeViewChanged(node: MetaNode) {

        delegate?.saveBundleWhenNodeViewChanged(node: node)
    }
}

extension SceneEditorPlayerView {

    /// 重新加载数据
    func reloadData() {

        updateRenderOptions() { [weak self] in
            guard let s = self else { return }
            s.reloadRendererView()
            s.reloadNodeViews()
        }
    }

    /// 更新渲染参数
    func updateRenderOptions(completion handler: (() -> Void)? = nil) {

//        guard let dataSource = dataSource else { return }

//        let aspectRatioType: MetaSceneAspectRatioType = dataSource.aspectRatioType()

//        (renderSize, renderAlignment, renderScale) = RenderOptionsManager.shared.calculateRenderOptions(aspectRatioType: aspectRatioType)

        if let handler = handler {
            handler()
        }
    }

    /// 重新加载「渲染器视图」
    func reloadRendererView() {

        if rendererView != nil {
            rendererView.removeFromSuperview()
            rendererView = nil
        }

        rendererView = SceneEditorRendererView(renderScale: scale)
        addSubview(rendererView)
        rendererView.snp.makeConstraints { make -> Void in
            make.width.equalTo(renderSize.width)
            make.height.equalTo(renderSize.height)
            make.center.equalToSuperview()
        }
    }

    /// 重新加载「组件视图」
    func reloadNodeViews() {

        if nodeViewContainer != nil {
            nodeViewContainer.removeFromSuperview()
            nodeViewContainer = nil
        }

        nodeViewContainer = RoundedView(cornerRadius: GVC.standardDeviceCornerRadius * scale)
        addSubview(nodeViewContainer)
        nodeViewContainer.snp.makeConstraints { make -> Void in
            make.edges.equalTo(rendererView)
        }
    }
}

extension SceneEditorPlayerView {

}
