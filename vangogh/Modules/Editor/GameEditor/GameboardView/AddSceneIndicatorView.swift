///
/// AddSceneIndicatorView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

protocol AddSceneIndicatorViewDelegate: AnyObject {
    func addSceneIndicatorViewDidTap(_ view: AddSceneIndicatorView)
    func addSceneIndicatorViewCloseButtonDidTap()
}

class AddSceneIndicatorView: UIView {

    /// 视图布局常量枚举值
    enum VC {
        static let width: CGFloat = 160
        static let height: CGFloat = 76
        static let infoLabelFontSize: CGFloat = 14
        static let closeButtonWidth: CGFloat = 24
        static let closeButtonImageEdgeInset: CGFloat = 4.8
    }

    weak var delegate: AddSceneIndicatorViewDelegate?

    private var contentView: UIView!
    private var closeButton: CloseButton!
    private var infoLabel: UILabel!

    init() {

        super.init(frame: .zero)

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {

        backgroundColor = .clear
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan)))

        contentView = RoundedView()
        contentView.backgroundColor = GVC.addSceneViewBackgroundColor
        addSubview(contentView)
        contentView.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.width - VC.closeButtonWidth / 2)
            make.height.equalTo(VC.height - VC.closeButtonWidth / 2)
            make.left.bottom.equalToSuperview()
        }

        infoLabel = UILabel()
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

        closeButton = CloseButton()
        closeButton.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
        addSubview(closeButton)
        closeButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.closeButtonWidth)
            make.right.top.equalToSuperview()
        }
    }
}

extension AddSceneIndicatorView {

    @objc private func tap(_ sender: UIPanGestureRecognizer) {

        guard let view = sender.view as? AddSceneIndicatorView else { return }

        delegate?.addSceneIndicatorViewDidTap(view)
    }

    @objc private func pan(_ sender: UIPanGestureRecognizer) {

        guard let view = sender.view else { return }

        switch sender.state {
        case .began:
            break
        case .changed:
            view.center = sender.location(in: superview)
            break
        case .ended:
            break
        default:
            break
        }
    }

    @objc private func closeButtonDidTap() {

        delegate?.addSceneIndicatorViewCloseButtonDidTap()
    }
}

private class CloseButton: UIButton {

    private lazy var maskLayer: CAShapeLayer = {
        self.layer.mask = $0
        return $0
    }(CAShapeLayer())

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

    override func backgroundRect(forBounds bounds: CGRect) -> CGRect {

        let imageEdgeInset: CGFloat = AddSceneIndicatorView.VC.closeButtonImageEdgeInset
        return CGRect(x: imageEdgeInset, y: imageEdgeInset, width: bounds.width - imageEdgeInset * 2, height: bounds.height - imageEdgeInset * 2)
    }
}
