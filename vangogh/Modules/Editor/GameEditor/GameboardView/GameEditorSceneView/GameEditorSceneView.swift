///
/// GameEditorSceneView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class GameEditorSceneView: RoundedView {

    /// 视图布局常量枚举值
    enum VC {
        static let width: CGFloat = 48
        static let height: CGFloat = 64
        static let titleLabelSmallFontSize: CGFloat = 12
        static let titleLabelLargeFontSize: CGFloat = 20
        static let maskBackgroundColor: UIColor = UIColor.systemGray3.withAlphaComponent(0.8)
    }

    /// 代理
    weak var delegate: GameEditorSceneViewDelegate?

    /// 缩略图视图
    var thumbImageView: UIImageView!
    /// 标题标签
    var titleLabel: AttributedLabel!
    /// 边框图层
    var borderLayer: CAShapeLayer!

    /// 激活状态
    var isActive: Bool = false {
        willSet {
            if newValue {
                activate()
            } else {
                deactivate()
            }
        }
    }

    /// 场景
    var scene: MetaScene!

    /// 初始化
    init(scene: MetaScene) {

        super.init(cornerRadius: GVC.defaultViewCornerRadius)

        self.scene = scene

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 重写用户界面风格变化处理方法
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)

        // 更新边框颜色

        if borderLayer != nil {
            borderLayer.strokeColor = UIColor.accent?.cgColor
            borderLayer.fillColor = UIColor.clear.cgColor
        }
    }

    /// 初始化视图
    private func initViews() {

        center = scene.center
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap))
        )
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan)))
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPress)))

        // 初始化「缩略图视图」

        thumbImageView = UIImageView()
        thumbImageView.contentMode = .scaleAspectFill
        thumbImageView.image = .sceneBackgroundThumb
        addSubview(thumbImageView)
        thumbImageView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        // 初始化「标题标签」

        titleLabel = AttributedLabel()
        titleLabel.insets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        titleLabel.backgroundColor = VC.maskBackgroundColor
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
}

extension GameEditorSceneView {

    /// 准备「标题标签」文本
    func prepareTitleLabelAttributedText() -> NSMutableAttributedString {

        let completeTitleString: NSMutableAttributedString = NSMutableAttributedString(string: "")

        // 准备场景索引

        let indexStringAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: VC.titleLabelLargeFontSize, weight: .regular)]
        let indexString: NSAttributedString = NSAttributedString(string: scene.index.description, attributes: indexStringAttributes)
        completeTitleString.append(indexString)

        // 准备场景标题

        let titleStringAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: VC.titleLabelSmallFontSize, weight: .regular)]
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
}
