///
/// BorderedView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class BorderedView: UIView {

    // 视图侧边枚举值

    enum ViewSide {
        case left, right, top, bottom
    }

    private var borderLayer: CAShapeLayer!
    private var side: ViewSide = .bottom
    private var thickness: CGFloat = 1.0 / UIScreen.main.scale

    init(side: ViewSide) {

        super.init(frame: .zero)

        self.side = side
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {

        addBorderLayer()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)

        addBorderLayer()
    }

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
