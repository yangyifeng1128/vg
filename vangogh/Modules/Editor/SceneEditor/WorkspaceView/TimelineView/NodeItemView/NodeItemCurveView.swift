///
/// NodeItemCurveView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class NodeItemCurveView: UIButton {

    /// 视图布局常量枚举值
    enum VC {
        static let height: CGFloat = 16
        static let lineWidth: CGFloat = TimelineMeasureView.VC.markWidth * 2
    }

    /// 边框图层
    private var borderLayer: CAShapeLayer!

    /// 组件类型
    private var nodeType: MetaNodeType!

    /// 初始化
    init(nodeType: MetaNodeType) {

        super.init(frame: .zero)

        self.nodeType = nodeType
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 重写布局子视图方法
    override func layoutSubviews() {

        addBorderLayer()
    }

    /// 添加边框图层
    private func addBorderLayer() {

        if borderLayer != nil {
            borderLayer.removeFromSuperlayer()
            borderLayer = nil
        }

        borderLayer = CAShapeLayer()
        borderLayer.lineWidth = VC.lineWidth
        borderLayer.strokeColor = MetaNodeTypeManager.shared.getNodeTypeBackgroundColor(nodeType: nodeType)?.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.frame = bounds
        borderLayer.path = UIBezierPath.curve(width: bounds.width, height: bounds.height, cornerRadius: GVC.defaultViewCornerRadius * 0.75).cgPath
        layer.addSublayer(borderLayer)
    }
}
