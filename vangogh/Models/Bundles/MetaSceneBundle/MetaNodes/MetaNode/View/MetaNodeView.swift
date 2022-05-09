///
/// MetaNodeView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaNodeView: UIView {

    /// 视图布局常量枚举值
    enum VC {
        static let borderLayerWidth: CGFloat = 4
        static let progressViewHeight: CGFloat = 4
        static let progressViewMarginBottom: CGFloat = 16
    }

    /// 播放器视图
    weak var playerView: SceneEditorPlayerView?

    /// 组件
    private(set) var node: MetaNode!

    /// 激活状态
    var isActive: Bool = false {
        willSet {
            if newValue {
                activate()
            } else {
                deactivate()
            }
        }
    }

    /// 初始化
    init() {

        super.init(frame: .zero)

        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 布局
    func layout(parent: UIView) {

        fatalError("Method \"layout\" must be overriden")
    }

    /// 激活
    func activate() {

        addBorderLayer()
    }

    /// 取消激活
    func deactivate() {

        removeBorderLayer()
    }

    /// 添加边框图层
    private func addBorderLayer() {

        layer.borderColor = UIColor.accent?.cgColor
        layer.borderWidth = VC.borderLayerWidth
    }

    /// 移除边框图层
    private func removeBorderLayer() {

        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 0
    }
}
