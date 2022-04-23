///
/// SceneEmulatorPlayButton
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class SceneEmulatorPlayButton: UIButton {

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

    override var isEnabled: Bool {
        willSet {
            if newValue == false {
                tintColor = .gray
                imageView?.tintColor = .gray
            } else {
                tintColor = .white
                imageView?.tintColor = .white
            }
        }
    }

    var isPlaying: Bool = false {
        didSet {
            setToggled()
        }
    }

    var playImage: UIImage? = .play
    var pauseImage: UIImage? = .pause

    private var imageEdgeInset: CGFloat!

    init(imageEdgeInset: CGFloat) {

        super.init(frame: .zero)

        self.imageEdgeInset = imageEdgeInset

        setToggled()

        backgroundColor = GlobalViewLayoutConstants.defaultSceneControlBackgroundColor
        tintColor = .white
        adjustsImageWhenHighlighted = false
        imageView?.tintColor = .white
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    override func backgroundRect(forBounds bounds: CGRect) -> CGRect {

        return CGRect(x: imageEdgeInset, y: imageEdgeInset, width: bounds.width - imageEdgeInset * 2, height: bounds.height - imageEdgeInset * 2)
    }

    private func setToggled() {

        if isPlaying {
            setBackgroundImage(pauseImage, for: .normal)
        } else {
            setBackgroundImage(playImage, for: .normal)
        }
    }
}
