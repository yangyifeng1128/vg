///
/// GameScannerTorchButton
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class GameScannerTorchButton: UIButton {

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

    var isActive: Bool = false { // 激活状态
        didSet {
            setToggled()
        }
    }

    private var torchImage: UIImage? = .torch
    private var torchOffImage: UIImage? = .torchOff

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

        setToggled()

        backgroundColor = GVC.defaultSceneControlBackgroundColor
        adjustsImageWhenHighlighted = false
    }

    override func backgroundRect(forBounds bounds: CGRect) -> CGRect {

        return CGRect(x: imageEdgeInset, y: imageEdgeInset, width: bounds.width - imageEdgeInset * 2, height: bounds.height - imageEdgeInset * 2)
    }

    private func setToggled() {

        UIImpactFeedbackGenerator().impactOccurred()

        if isActive {

            setBackgroundImage(torchImage, for: .normal)
            tintColor = .white
            imageView?.tintColor = .white

        } else {

            setBackgroundImage(torchOffImage, for: .normal)
            tintColor = .gray
            imageView?.tintColor = .gray
        }
    }
}
