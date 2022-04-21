///
/// SceneEmulatorProgressTagView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class SceneEmulatorProgressTagView: UIView {

    // 视图布局常量枚举值

    enum ViewLayoutConstants {
        static let width: CGFloat = SceneEmulatorProgressView.ViewLayoutConstants.height / 2
        static let height: CGFloat = width * 5 / 4
        static let iconViewWidth: CGFloat = width / 2
    }

    private lazy var maskLayer: CAShapeLayer = {
        self.layer.mask = $0
        return $0
    }(CAShapeLayer())

    override var bounds: CGRect {
        set {
            super.bounds = newValue
            maskLayer.frame = newValue
            let newPath: CGPath = UIBezierPath.waterdrop(width: bounds.width).cgPath
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

    private var iconView: UIImageView!

    private(set) var node: MetaNode!

    init(node: MetaNode) {

        super.init(frame: .zero)

        self.node = node

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {

        backgroundColor = MetaNodeTypeManager.shared.getNodeTypeBackgroundColor(nodeType: node.nodeType)
        tintColor = .mgLabel

        iconView = UIImageView()
        iconView.image = MetaNodeTypeManager.shared.getNodeTypeIcon(nodeType: node.nodeType)
        addSubview(iconView)
        iconView.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(ViewLayoutConstants.iconViewWidth)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset((ViewLayoutConstants.iconViewWidth - ViewLayoutConstants.width) / 2)
        }
    }
}
