///
/// RoundedButton
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class RoundedButton: UIButton {

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
            let newPath: CGPath = UIBezierPath(roundedRect: newValue, cornerRadius: cornerRadius).cgPath
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

    /// 圆角
    var cornerRadius: CGFloat!

    /// 初始化
    init(cornerRadius: CGFloat = GVC.defaultViewCornerRadius) {

        super.init(frame: .zero)

        self.cornerRadius = cornerRadius
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }
}
