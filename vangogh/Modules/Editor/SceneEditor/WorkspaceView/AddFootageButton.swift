///
/// AddFootageButton
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class AddFootageButton: UIButton {

    private lazy var maskLayer: CAShapeLayer = {
        self.layer.mask = $0
        return $0
    }(CAShapeLayer())

    override var bounds: CGRect {
        set {
            super.bounds = newValue
            maskLayer.frame = newValue
            let newPath: CGPath = UIBezierPath(roundedRect: bounds, cornerRadius: min(bounds.width, bounds.height)).cgPath
            if let animation = self.layer.animation(forKey: "bounds.size")?.copy() as? CABasicAnimation {
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

    init(imageEdgeInset: CGFloat) {

        super.init(frame: .zero)

        self.imageEdgeInset = imageEdgeInset

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {

        backgroundColor = .accent
        tintColor = .white
        setBackgroundImage(.add, for: .normal)
        adjustsImageWhenHighlighted = false
        imageView?.tintColor = .white
    }

    override func backgroundRect(forBounds bounds: CGRect) -> CGRect {

        return CGRect(x: imageEdgeInset, y: imageEdgeInset, width: bounds.width - imageEdgeInset * 2, height: bounds.height - imageEdgeInset * 2)
    }
}
