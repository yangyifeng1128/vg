///
/// TrackItemEarView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class TrackItemEarView: UIButton {

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
            let cornerRadii: CGFloat = GVC.defaultViewCornerRadius
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

    init(direction: EarDirection = .left) {

        super.init(frame: .zero)

        self.direction = direction
        backgroundColor = .mgLabel
        tintColor = .systemBackground
        var icon: UIImage?
        if direction == .left {
            icon = .triangleLeft
        } else if direction == .right {
            icon = .triangleRight
        }
        setImage(icon, for: .normal)
        adjustsImageWhenHighlighted = false
        imageView?.tintColor = .systemBackground
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }
}

extension TrackItemEarView {

    func highlight() {

        backgroundColor = .accent
        tintColor = .white
        imageView?.tintColor = .white
    }

    func unhighlight() {

        backgroundColor = .mgLabel
        tintColor = .systemBackground
        imageView?.tintColor = .systemBackground
    }
}
