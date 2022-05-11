///
/// SceneEmulatorPlayerView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import CoreMedia
import SnapKit
import UIKit

class SceneEmulatorPlayerView: UIView {

    /// 视图布局常量枚举值
    enum VC {
        static let backgroundColor: UIColor = .systemGroupedBackground
    }

    /// 数据源
    weak var dataSource: SceneEmulatorPlayerViewDataSource? {
        didSet { reloadData() }
    }
    /// 代理
    weak var delegate: SceneEmulatorPlayerViewDelegate?

    /// 渲染视图
    var rendererView: SceneEmulatorRendererView!
    /// 交互视图
    var interactionView: SceneEmulatorInteractionView!

    /// 渲染尺寸
    var renderSize: CGSize = .zero
    /// 渲染对齐方式
    var renderAlignment: RenderAlignment = .center
    /// 渲染缩放比例
    var renderScale: CGFloat = 1

    /// 初始化
    init() {

        super.init(frame: .zero)

        backgroundColor = VC.backgroundColor
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }
}
