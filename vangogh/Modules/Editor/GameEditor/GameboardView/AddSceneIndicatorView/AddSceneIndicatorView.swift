///
/// AddSceneIndicatorView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class AddSceneIndicatorView: UIView {

    /// 视图布局常量枚举值
    enum VC {
        static let width: CGFloat = 160
        static let height: CGFloat = 76
        static let infoLabelFontSize: CGFloat = 14
        static let closeButtonWidth: CGFloat = 24
        static let closeButtonImageEdgeInset: CGFloat = 4.8
    }

    /// 代理
    weak var delegate: AddSceneIndicatorViewDelegate?

    /// 初始化
    init() {

        super.init(frame: .zero)

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = .clear
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan)))

        // 初始化「内容视图」

        let contentView: RoundedView = RoundedView()
        contentView.backgroundColor = GVC.addSceneViewBackgroundColor
        addSubview(contentView)
        contentView.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.width - VC.closeButtonWidth / 2)
            make.height.equalTo(VC.height - VC.closeButtonWidth / 2)
            make.left.bottom.equalToSuperview()
        }

        // 初始化「信息标签」

        let infoLabel: UILabel = UILabel()
        infoLabel.text = NSLocalizedString("AddSceneIndicatorInfo", comment: "")
        infoLabel.font = .systemFont(ofSize: VC.infoLabelFontSize, weight: .regular)
        infoLabel.adjustsFontSizeToFitWidth = true
        infoLabel.textColor = .white
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 2
        infoLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview().inset(8)
        }

        // 初始化「关闭按钮」

        let closeButton: AddSceneIndicatorCloseButton = AddSceneIndicatorCloseButton()
        closeButton.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
        addSubview(closeButton)
        closeButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.closeButtonWidth)
            make.right.top.equalToSuperview()
        }
    }
}

private class AddSceneIndicatorCloseButton: UIButton {

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

    /// 初始化
    init() {

        super.init(frame: .zero)

        backgroundColor = .tertiarySystemBackground
        tintColor = .mgLabel
        setBackgroundImage(.close, for: .normal)
        adjustsImageWhenHighlighted = false
        imageView?.tintColor = tintColor
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 重写背景矩形区域
    override func backgroundRect(forBounds bounds: CGRect) -> CGRect {

        let imageEdgeInset: CGFloat = AddSceneIndicatorView.VC.closeButtonImageEdgeInset
        return CGRect(x: imageEdgeInset, y: imageEdgeInset, width: bounds.width - imageEdgeInset * 2, height: bounds.height - imageEdgeInset * 2)
    }
}
