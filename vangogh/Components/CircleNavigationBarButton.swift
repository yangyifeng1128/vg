///
/// CircleNavigationBarButton
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class CircleNavigationBarButton: UIButton {

    /// 视图常量枚举值
    enum VC {
        static let width: CGFloat = 40
    }

    // 视图

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
            let newPath: CGPath = UIBezierPath(roundedRect: bounds, cornerRadius: min(bounds.width, bounds.height)).cgPath
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

    /// 图像边缘内边距
    private var imageEdgeInset: CGFloat!

    // 生命周期

    /// 初始化
    init(icon: UIImage?, backgroundColor: UIColor? = /* .tertiarySystemBackground */ .clear, tintColor: UIColor? = .mgLabel, imageEdgeInset: CGFloat = 8) {

        super.init(frame: .zero)

        self.imageEdgeInset = imageEdgeInset

        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        setBackgroundImage(icon, for: .normal)
        adjustsImageWhenHighlighted = false
        imageView?.tintColor = tintColor
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 重写背景矩形区域
    override func backgroundRect(forBounds bounds: CGRect) -> CGRect {

        return CGRect(x: imageEdgeInset, y: imageEdgeInset, width: bounds.width - imageEdgeInset * 2, height: bounds.height - imageEdgeInset * 2)
    }
}
