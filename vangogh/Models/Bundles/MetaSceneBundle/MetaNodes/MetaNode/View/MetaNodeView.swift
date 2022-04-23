///
/// MetaNodeView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaNodeView: UIView {

    /// 视图布局常量枚举值
    enum ViewLayoutConstants {
        static let borderLayerWidth: CGFloat = 4
        static let progressViewHeight: CGFloat = 4
        static let progressViewMarginBottom: CGFloat = 16
    }

    weak var playerView: ScenePlayerView?

    private(set) var node: MetaNode!

    var isActive: Bool = false { // 激活状态
        willSet {
            if newValue {
                activate() // 激活
            } else {
                deactivate() // 取消激活
            }
        }
    }

    init() {

        super.init(frame: .zero)

        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    func layout(parent: UIView) {

        fatalError("Method \"layout\" must be overriden")
    }

    func activate() {

        addBorderLayer()
    }

    func deactivate() {

        removeBorderLayer()
    }

    private func addBorderLayer() {

        layer.borderColor = UIColor.accent?.cgColor
        layer.borderWidth = ViewLayoutConstants.borderLayerWidth
    }

    private func removeBorderLayer() {

        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 0
    }
}
