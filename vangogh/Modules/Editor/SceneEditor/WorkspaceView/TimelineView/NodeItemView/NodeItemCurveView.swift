///
/// NodeItemCurveView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class NodeItemCurveView: UIButton {

    // 视图布局常量枚举值

    enum ViewLayoutConstants {
        static let height: CGFloat = 16
        static let lineWidth: CGFloat = TimelineMeasureView.ViewLayoutConstants.markWidth * 2
    }

    private var borderLayer: CAShapeLayer!

    private var nodeType: MetaNodeType!

    init(nodeType: MetaNodeType) {

        super.init(frame: .zero)

        self.nodeType = nodeType
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {

        addBorderLayer()
    }

    private func addBorderLayer() {

        if borderLayer != nil {
            borderLayer.removeFromSuperlayer()
            borderLayer = nil
        }

        borderLayer = CAShapeLayer()
        borderLayer.lineWidth = ViewLayoutConstants.lineWidth
        borderLayer.strokeColor = MetaNodeTypeManager.shared.getNodeTypeBackgroundColor(nodeType: nodeType)?.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.frame = bounds
        borderLayer.path = UIBezierPath.curve(width: bounds.width, height: bounds.height, cornerRadius: GlobalViewLayoutConstants.defaultViewCornerRadius * 0.75).cgPath
        layer.addSublayer(borderLayer)
    }
}
