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
        static let borderWidth: CGFloat = 3
        static let titleLabelSmallFontSize: CGFloat = 12
        static let titleLabelLargeFontSize: CGFloat = 20
        static let maskBackgroundColor: UIColor = UIColor.systemGray5.withAlphaComponent(0.7)
    }

    /// 代理
    weak var delegate: GameEditorSceneViewDelegate?

    /// 缩略图视图
    var thumbImageView: UIImageView!
    /// 标题标签
    var titleLabel: AttributedLabel!
    /// 边框图层
    var borderLayer: CAShapeLayer!

    /// 选中状态
    var isSelected: Bool! {
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

        super.init()

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
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan)))

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

        // 设置选中状态

        isSelected = false
    }
}
