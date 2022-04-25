///
/// NodeItemTagView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class NodeItemTagView: UIView {

    /// 视图布局常量枚举值
    enum VC {
        static let width: CGFloat = 40
        static let height: CGFloat = width * 5 / 4
        static let iconViewWidth: CGFloat = 20
        static let borderLayerWidth: CGFloat = NodeItemCurveView.VC.lineWidth * 2
    }

    private lazy var maskLayer: CAShapeLayer = {
        self.layer.mask = $0
        return $0
    }(CAShapeLayer())

    override var bounds: CGRect {
        set {
            super.bounds = newValue
            maskLayer.frame = newValue
            let newPath: CGPath = UIBezierPath.waterdrop2(width: bounds.width).cgPath
            if let animation = layer.animation(forKey: "bounds.size")?.copy() as? CABasicAnimation {
                animation.keyPath = "path"
                animation.fromValue = maskLayer.path
                animation.toValue = newPath
                maskLayer.path = newPath
                maskLayer.add(animation, forKey: "path")
            } else {
                maskLayer.path = newPath
            }
        }
        get {
            return super.bounds
        }
    }

    private var borderLayer: CAShapeLayer!
    private var iconView: UIImageView!

    var isActive: Bool = false { // 激活状态
        willSet {
            if newValue {
                activate() // 激活
            } else {
                deactivate() // 取消激活
            }
        }
    }

    private(set) var node: MetaNode!

    init(node: MetaNode) {

        super.init(frame: .zero)

        self.node = node

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)

        if isActive {
            addBorderLayer()
        }
    }

    private func initViews() {

        backgroundColor = MetaNodeTypeManager.shared.getNodeTypeBackgroundColor(nodeType: node.nodeType)
        tintColor = .mgLabel

        iconView = UIImageView()
        iconView.image = MetaNodeTypeManager.shared.getNodeTypeIcon(nodeType: node.nodeType)
        addSubview(iconView)
        iconView.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.iconViewWidth)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset((VC.iconViewWidth - VC.width) / 2)
        }
    }
}

extension NodeItemTagView {

    private func activate() {

        addBorderLayer()
    }

    private func deactivate() {

        removeBorderLayer()
    }

    private func addBorderLayer() {

        if borderLayer != nil {
            borderLayer.removeFromSuperlayer()
            borderLayer = nil
        }

        borderLayer = CAShapeLayer()
        borderLayer.lineWidth = VC.borderLayerWidth
        var strokeColor: UIColor? = .mgLabel
        if SceneEditorViewController.preferredUserInterfaceStyle == .dark {
            strokeColor = .white
        }
        borderLayer.strokeColor = strokeColor?.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.frame = bounds
        borderLayer.path = maskLayer.path

        layer.addSublayer(borderLayer)
    }

    private func removeBorderLayer() {

        if borderLayer != nil {
            borderLayer.removeFromSuperlayer()
            borderLayer = nil
        }
    }
}
