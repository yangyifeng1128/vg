///
/// CircleNavigationBarButton
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class CircleNavigationBarButton: UIButton {

    /// 视图布局常量枚举值
    enum ViewLayoutConstants {
        static let width: CGFloat = 40
    }

    private lazy var maskLayer: CAShapeLayer = {
        self.layer.mask = $0
        return $0
    }(CAShapeLayer())

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

    private var imageEdgeInset: CGFloat!

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

    override func backgroundRect(forBounds bounds: CGRect) -> CGRect {

        return CGRect(x: imageEdgeInset, y: imageEdgeInset, width: bounds.width - imageEdgeInset * 2, height: bounds.height - imageEdgeInset * 2)
    }
}
