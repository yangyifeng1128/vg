///
/// SceneEmulatorProgressTagView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class SceneEmulatorProgressTagView: UIView {

    /// 视图布局常量枚举值
    enum VC {
        static let width: CGFloat = SceneEmulatorProgressView.VC.height / 2
        static let height: CGFloat = width * 5 / 4
        static let iconViewWidth: CGFloat = width / 2
    }

    /// 遮罩图层
    private lazy var maskLayer: CAShapeLayer = {
        self.layer.mask = $0
        return $0
    }(CAShapeLayer())

    /// 重写边框大小
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

    /// 图标视图
    private var iconView: UIImageView!

    /// 节点
    private(set) var node: MetaNode!

    /// 初始化
    init(node: MetaNode) {

        super.init(frame: .zero)

        self.node = node

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = MetaNodeTypeManager.shared.getNodeTypeBackgroundColor(nodeType: node.nodeType)
        tintColor = .mgLabel

        // 初始化「图标视图」

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
