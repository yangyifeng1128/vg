///
/// GameScannerTorchButton
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class GameScannerTorchButton: UIButton {

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

    /// 激活状态
    var isActive: Bool = false {
        willSet {
            setToggled()
        }
    }

    /// 开启手电筒图像
    private var torchImage: UIImage? = .torch
    /// 关闭手电筒图像
    private var torchOffImage: UIImage? = .torchOff

    /// 图像边缘内边距
    private var imageEdgeInset: CGFloat!

    /// 初始化
    init(imageEdgeInset: CGFloat) {

        super.init(frame: .zero)

        self.imageEdgeInset = imageEdgeInset

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        setToggled()

        backgroundColor = GVC.defaultSceneControlBackgroundColor
        adjustsImageWhenHighlighted = false
    }

    /// 重写背景矩形区域
    override func backgroundRect(forBounds bounds: CGRect) -> CGRect {

        return CGRect(x: imageEdgeInset, y: imageEdgeInset, width: bounds.width - imageEdgeInset * 2, height: bounds.height - imageEdgeInset * 2)
    }

    /// 设置切换状态
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
