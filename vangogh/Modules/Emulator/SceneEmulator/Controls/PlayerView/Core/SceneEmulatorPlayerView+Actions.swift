///
/// SceneEmulatorPlayerView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension SceneEmulatorPlayerView {
//
//    @objc func playButtonDidTap() {
//
//        delegate?.playButtonDidTap()
//    }
//
//    @objc func gameboardButtonDidTap() {
//
//        delegate?.gameboardButtonDidTap()
//    }
}

extension SceneEmulatorPlayerView {

    /// 重新加载数据
    func reloadData() {

        updateRenderOptions() { [weak self] in
            guard let s = self else { return }
            s.reloadRendererView()
            s.reloadInteractionView()
        }
    }

    /// 更新渲染参数
    func updateRenderOptions(completion handler: (() -> Void)? = nil) {

        guard let dataSource = dataSource else { return }

        let aspectRatioType = dataSource.aspectRatioType()

        (renderSize, renderAlignment, renderScale) = RenderOptionsManager.shared.calculateRenderOptions(aspectRatioType: aspectRatioType)

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

        rendererView = SceneEmulatorRendererView(renderScale: renderScale)
        addSubview(rendererView)
        rendererView.snp.makeConstraints { make -> Void in
            make.width.equalTo(renderSize.width)
            make.height.equalTo(renderSize.height)
            if renderAlignment == .topCenter {
                make.centerX.equalToSuperview()
                make.top.equalTo(safeAreaLayoutGuide.snp.top)
            } else {
                make.center.equalToSuperview()
            }
        }
    }

    /// 重新加载「交互视图」
    func reloadInteractionView() {

        if interactionView != nil {
            interactionView.removeFromSuperview()
            interactionView = nil
        }

        interactionView = SceneEmulatorInteractionView(renderScale: renderScale)
        addSubview(interactionView)
        interactionView.snp.makeConstraints { make -> Void in
            make.edges.equalTo(rendererView)
        }
    }
}

extension SceneEmulatorPlayerView {

}
