///
/// GameEditorSceneView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

protocol GameEditorSceneViewDelegate: AnyObject {
    func sceneViewDidTap(_ sceneView: GameEditorSceneView)
    func sceneViewIsMoving(scene: MetaScene)
    func sceneViewDidPan(scene: MetaScene)
    func sceneViewDidLongPress(_ sceneView: GameEditorSceneView)
}

class GameEditorSceneView: RoundedView {

    // 视图布局常量枚举值

    enum ViewLayoutConstants {
        static let width: CGFloat = 48
        static let height: CGFloat = 64
        static let titleLabelSmallFontSize: CGFloat = 12
        static let titleLabelLargeFontSize: CGFloat = 20
        static let maskBackgroundColor: UIColor = UIColor.systemGray3.withAlphaComponent(0.8)
    }

    weak var delegate: GameEditorSceneViewDelegate?

    var thumbImageView: UIImageView!
    var titleLabel: AttributedLabel!
    private var borderLayer: CAShapeLayer!

    var isActive: Bool = false { // 激活状态
        willSet {
            if newValue {
                activate() // 激活
            } else {
                deactivate() // 取消激活
            }
        }
    }

    var scene: MetaScene!

    init(scene: MetaScene) {

        super.init(cornerRadius: GlobalViewLayoutConstants.defaultViewCornerRadius)

        self.scene = scene

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)

        // 更新边框颜色

        if borderLayer != nil {
            borderLayer.strokeColor = UIColor.accent?.cgColor
            borderLayer.fillColor = UIColor.clear.cgColor
        }
    }

    private func initSubviews() {

        center = scene.center
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap))
        )
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan)))
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPress)))

        thumbImageView = UIImageView()
        thumbImageView.contentMode = .scaleAspectFill
        thumbImageView.image = .sceneBackgroundThumb
        addSubview(thumbImageView)
        thumbImageView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        titleLabel = AttributedLabel()
        titleLabel.insets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        titleLabel.backgroundColor = ViewLayoutConstants.maskBackgroundColor
        titleLabel.attributedText = prepareTitleLabelAttributedText()
        titleLabel.textColor = .lightText
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 3
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        titleLabel.layer.shadowOpacity = 0.4
        titleLabel.layer.shadowRadius = 0
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        isActive = false
    }

    func updateTitleLabelAttributedText() {

        titleLabel.attributedText = prepareTitleLabelAttributedText()
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 3
        titleLabel.lineBreakMode = .byTruncatingTail
    }

    private func prepareTitleLabelAttributedText() -> NSMutableAttributedString {

        let completeTitleString: NSMutableAttributedString = NSMutableAttributedString(string: "")

        // 准备场景索引

        let indexStringAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: ViewLayoutConstants.titleLabelLargeFontSize, weight: .regular)]
        let indexString: NSAttributedString = NSAttributedString(string: scene.index.description, attributes: indexStringAttributes)
        completeTitleString.append(indexString)

        // 准备场景标题

        let titleStringAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: ViewLayoutConstants.titleLabelSmallFontSize, weight: .regular)]
        var titleString: NSAttributedString
        if let title = scene.title, !title.isEmpty {
            titleString = NSAttributedString(string: "\n" + title, attributes: titleStringAttributes)
            completeTitleString.append(titleString)
        }

        // 准备段落样式

        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        completeTitleString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, completeTitleString.length))

        return completeTitleString
    }

    private func activate() {

        cornerRadius = 12
        bounds = CGRect(origin: .zero, size: CGSize(width: ViewLayoutConstants.width * 1.167, height: ViewLayoutConstants.height * 1.125))

        // 添加边框

        if borderLayer != nil {
            borderLayer.removeFromSuperlayer()
            borderLayer = nil
        }

        borderLayer = CAShapeLayer()
        borderLayer.lineWidth = 8
        borderLayer.strokeColor = UIColor.accent?.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.frame = bounds
        borderLayer.path = maskLayer.path

        layer.addSublayer(borderLayer)

        // 高亮

        highlight()
    }

    private func deactivate() {

        cornerRadius = GlobalViewLayoutConstants.defaultViewCornerRadius
        bounds = CGRect(origin: .zero, size: CGSize(width: ViewLayoutConstants.width, height: ViewLayoutConstants.height))

        // 删除边框

        if borderLayer != nil {
            borderLayer.removeFromSuperlayer()
            borderLayer = nil
        }

        // 取消高亮

        unhighlight()
    }

    func highlight() {

        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .white
    }

    func unhighlight() {

        titleLabel.backgroundColor = ViewLayoutConstants.maskBackgroundColor
        titleLabel.textColor = .lightText
    }
}

extension GameEditorSceneView {

    @objc private func tap() {

        UISelectionFeedbackGenerator().selectionChanged() // 震动反馈

        delegate?.sceneViewDidTap(self)
    }

    @objc private func pan(_ sender: UIPanGestureRecognizer) {

        guard let view = sender.view else { return }

        switch sender.state {

        case .began:
            break

        case .changed:

            // 对齐网格

            let location: CGPoint = sender.location(in: superview)
            let gridWidth: CGFloat = GameEditorViewController.ViewLayoutConstants.gameboardViewGridWidth
            let snappedLocation: CGPoint = CGPoint(x: gridWidth * floor(location.x / gridWidth), y: gridWidth * floor(location.y / gridWidth))

            if view.center != snappedLocation {

                UISelectionFeedbackGenerator().selectionChanged() // 震动反馈

                view.center = snappedLocation
                scene.center = view.center
                delegate?.sceneViewIsMoving(scene: scene) // 传递 scene 对象的引用给 delegate，然后在 delegate 中矫正 scene.center
            }
            break

        case .ended:

            view.center = scene.center // 移动结束后，scene.center 已经在 delegate 中完成了矫正，这时候就可以回写给 view.center 了
            delegate?.sceneViewDidPan(scene: scene)
            break

        default:
            break
        }
    }

    @objc private func longPress(_ sender: UILongPressGestureRecognizer) {

        if isActive && sender.state == .began { // 处于激活状态且长按开始时，才会触发操作
            delegate?.sceneViewDidLongPress(self)
        }
    }
}
