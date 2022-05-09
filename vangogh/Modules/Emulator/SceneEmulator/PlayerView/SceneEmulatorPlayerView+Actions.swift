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

        calculateRenderOptions()
        reloadRendererView()
        reloadNodeViews()
    }

    /// 更新「作品板按钮信息标签」
//    func updateGameboardButtonInfoLabel() {
//
//        gameboardButton.infoLabel.attributedText = prepareGameboardButtonInfoLabelAttributedText()
//        gameboardButton.infoLabel.numberOfLines = 1
//        gameboardButton.infoLabel.lineBreakMode = .byTruncatingTail
//    }

    /// 计算渲染尺寸
    func calculateRenderOptions() {

        guard let dataSource = dataSource else { return }

        let aspectRatioType = dataSource.aspectRatioType()

        let renderHeight: CGFloat
        var renderWidth: CGFloat
        if UIDevice.current.userInterfaceIdiom == .phone { // 如果是手机设备
            renderWidth = UIScreen.main.bounds.width // 宽度适配：视频渲染宽度 = 屏幕宽度
            renderHeight = MetaSceneAspectRatioTypeManager.shared.calculateHeight(width: renderWidth, aspectRatioType: aspectRatioType) // 按照场景尺寸比例计算视频渲染高度
            if aspectRatioType == .h16w9 { // 如果场景尺寸比例 = 16:9
                let deviceAspectRatio: CGFloat = UIScreen.main.bounds.width / UIScreen.main.bounds.height
                if deviceAspectRatio <= 0.5 {
                    renderAlignment = .topCenter
                } else {
                    renderAlignment = .center // 兼容 iPhone 8, 8 Plus
                }
            } else { // 如果场景尺寸比例 = 4:3或其他
                renderAlignment = .center
            }
        } else { // 如果是平板或其他类型设备
            renderHeight = UIScreen.main.bounds.height // 高度适配：视频渲染高度 = 屏幕高度
            renderWidth = MetaSceneAspectRatioTypeManager.shared.calculateWidth(height: renderHeight, aspectRatioType: aspectRatioType) // 按照场景尺寸比例计算视频渲染宽度
            renderAlignment = .center // 不管场景尺寸比例是什么，在平板或其他类型设备上都进行居中对齐
        }
        renderSize = CGSize(width: renderWidth, height: renderHeight)

        // 计算渲染缩放比例

        var multiplier: CGFloat = 1
        if UIDevice.current.userInterfaceIdiom == .pad {
            multiplier = 768 / GVC.standardDeviceSize.width // 计算 multiplier，以兼容不同设备（phone、pad）之间的标准设备尺寸
        }
        renderScale = (renderSize.height / (GVC.standardDeviceSize.height * multiplier)).rounded(toPlaces: 4) // 以高度为基准，计算渲染缩放比例
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

    /// 重新加载「组件视图」
    func reloadNodeViews() {

        if nodeViewContainer != nil {
            nodeViewContainer.removeFromSuperview()
            nodeViewContainer = nil
        }

        nodeViewContainer = RoundedView(cornerRadius: GVC.standardDeviceCornerRadius * renderScale)
        addSubview(nodeViewContainer)
        nodeViewContainer.snp.makeConstraints { make -> Void in
            make.edges.equalTo(rendererView)
        }
    }
}

extension SceneEmulatorPlayerView {

}
