///
/// SceneEmulatorPlayButton
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class SceneEmulatorPlayButton: UIButton {

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

    /// 重写可用状态
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

    /// 播放状态
    var isPlaying: Bool = false {
        didSet {
            setToggled()
        }
    }

    /// 播放图像
    var playImage: UIImage? = .play
    /// 暂停图像
    var pauseImage: UIImage? = .pause

    /// 图像边缘内边距
    private var imageEdgeInset: CGFloat!

    /// 初始化
    init(imageEdgeInset: CGFloat) {

        super.init(frame: .zero)

        self.imageEdgeInset = imageEdgeInset

        setToggled()

        backgroundColor = GVC.defaultSceneControlBackgroundColor
        tintColor = .white
        adjustsImageWhenHighlighted = false
        imageView?.tintColor = .white
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 重写背景矩形区域
    override func backgroundRect(forBounds bounds: CGRect) -> CGRect {

        return CGRect(x: imageEdgeInset, y: imageEdgeInset, width: bounds.width - imageEdgeInset * 2, height: bounds.height - imageEdgeInset * 2)
    }
}

extension SceneEmulatorPlayButton {

    /// 设置切换状态
    private func setToggled() {

        if isPlaying {
            setBackgroundImage(pauseImage, for: .normal)
        } else {
            setBackgroundImage(playImage, for: .normal)
        }
    }
}
