///
/// NodeItemEarView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class NodeItemEarView: UIButton {

    // 执耳方向枚举值

    enum EarDirection {
        case left, right
    }

    private lazy var maskLayer: CAShapeLayer = {
        self.layer.mask = $0
        return $0
    }(CAShapeLayer())

    override var bounds: CGRect {
        set {
            super.bounds = newValue
            maskLayer.frame = newValue
            let cornerRadii: CGFloat = GVC.defaultViewCornerRadius * 0.75
            var newPath: CGPath?
            if direction == .left {
                newPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: cornerRadii, height: cornerRadii)).cgPath
            } else if direction == .right {
                newPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: cornerRadii, height: cornerRadii)).cgPath
            }
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

    private var direction: EarDirection!
    private var defaultTintColor: UIColor?

    init(direction: EarDirection = .left, tintColor: UIColor?) {

        super.init(frame: .zero)

        self.direction = direction
        backgroundColor = .mgLabel
        defaultTintColor = tintColor
        self.tintColor = defaultTintColor
        var icon: UIImage?
        if direction == .left {
            icon = .triangleLeft
        } else if direction == .right {
            icon = .triangleRight
        }
        setImage(icon, for: .normal)
        adjustsImageWhenHighlighted = false
        imageView?.tintColor = defaultTintColor
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }
}

extension NodeItemEarView {

    func highlight() {

        backgroundColor = .accent
        tintColor = .mgHoneydew
        imageView?.tintColor = .mgHoneydew
    }

    func unhighlight() {

        backgroundColor = .mgLabel
        tintColor = defaultTintColor
        imageView?.tintColor = defaultTintColor
    }
}
