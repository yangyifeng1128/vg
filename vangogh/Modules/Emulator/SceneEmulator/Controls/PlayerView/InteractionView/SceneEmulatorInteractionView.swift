///
/// SceneEmulatorInteractionView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class SceneEmulatorInteractionView: RoundedView {

    /// 渲染缩放比例
    var renderScale: CGFloat!

    /// 组件视图列表
    var nodeViewList: [MetaNodeView] = []

    /// 初始化
    init(renderScale: CGFloat) {

        super.init(cornerRadius: GVC.standardDeviceCornerRadius * renderScale)

        self.renderScale = renderScale

        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }
}
