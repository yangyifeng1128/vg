///
/// RoundedImageView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class RoundedImageView: UIImageView {

    private lazy var maskLayer: CAShapeLayer = {
        self.layer.mask = $0
        return $0
    }(CAShapeLayer())

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

    var cornerRadius: CGFloat!

    init(cornerRadius: CGFloat = GlobalViewLayoutConstants.defaultViewCornerRadius) {

        super.init(frame: .zero)

        self.cornerRadius = cornerRadius
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }
}
