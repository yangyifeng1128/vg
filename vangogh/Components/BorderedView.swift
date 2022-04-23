///
/// BorderedView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class BorderedView: UIView {

    /// 视图侧边枚举值
    enum ViewSide {
        case left, right, top, bottom
    }

    // 视图

    /// 边框图层
    private var borderLayer: CAShapeLayer!
    /// 侧边
    private var side: ViewSide = .bottom
    /// 厚度
    private var thickness: CGFloat = 1.0 / UIScreen.main.scale

    // 生命周期

    /// 初始化
    init(side: ViewSide) {

        super.init(frame: .zero)

        self.side = side
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 重写布局子视图方法
    override func layoutSubviews() {

        addBorderLayer()
    }

    /// 重写用户界面风格变化处理方法
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)

        addBorderLayer()
    }
}

extension BorderedView {

    /// 添加边框图层
    private func addBorderLayer() {

        if borderLayer != nil {
            borderLayer.removeFromSuperlayer()
            borderLayer = nil
        }

        borderLayer = CAShapeLayer()
        borderLayer.backgroundColor = UIColor.separator.cgColor

        switch side {
        case .left:
            borderLayer.frame = CGRect(x: bounds.minX, y: bounds.minY, width: thickness, height: bounds.height)
            break
        case .right:
            borderLayer.frame = CGRect(x: bounds.maxX - thickness, y: bounds.minY, width: thickness, height: bounds.height)
            break
        case .top:
            borderLayer.frame = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: thickness)
            break
        case .bottom:
            borderLayer.frame = CGRect(x: bounds.minX, y: bounds.maxY - thickness, width: bounds.width, height: thickness)
            break
        }

        layer.addSublayer(borderLayer)
    }
}
