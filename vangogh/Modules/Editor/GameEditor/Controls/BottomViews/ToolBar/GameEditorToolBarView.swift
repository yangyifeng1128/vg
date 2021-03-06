///
/// GameEditorDefaultBottomView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class GameEditorToolBarView: BorderedView {

    /// 视图布局常量枚举值
    enum VC {
        static let contentViewHeight: CGFloat = 120
        static let addSceneButtonHeight: CGFloat = 56
        static let addSceneButtonTitleLabelFontSize: CGFloat = 18
        static let infoLabelFontSize: CGFloat = 13
        static let infoLabelIconWidth: CGFloat = 16
    }

    /// 代理
    weak var delegate: GameEditorToolBarViewDelegate?

    /// 初始化
    init() {

        super.init(side: .top)

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        // 初始化「内容视图」

        let contentView: UIView = UIView()
        contentView.backgroundColor = .systemBackground
        addSubview(contentView)
        contentView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(VC.contentViewHeight)
            make.left.top.equalToSuperview()
        }

        // 初始化「添加场景按钮」

        let addSceneButton: RoundedButton = RoundedButton()
        addSceneButton.backgroundColor = .secondarySystemBackground
        addSceneButton.tintColor = .mgLabel
        addSceneButton.setTitle(NSLocalizedString("AddScene", comment: ""), for: .normal)
        addSceneButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        addSceneButton.titleLabel?.font = .systemFont(ofSize: VC.addSceneButtonTitleLabelFontSize, weight: .regular)
        addSceneButton.setTitleColor(.mgLabel, for: .normal)
        addSceneButton.setImage(.add, for: .normal)
        addSceneButton.adjustsImageWhenHighlighted = false
        addSceneButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        addSceneButton.imageView?.tintColor = .mgLabel
        addSceneButton.addTarget(self, action: #selector(addSceneButtonDidTap), for: .touchUpInside)
        contentView.addSubview(addSceneButton)
        addSceneButton.snp.makeConstraints { make -> Void in
            make.height.equalTo(VC.addSceneButtonHeight)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化「信息标签」

        let infoLabel: UILabel = UILabel()
        infoLabel.attributedText = prepareInfoLabelAttributedText()
        infoLabel.font = .systemFont(ofSize: VC.infoLabelFontSize, weight: .regular)
        infoLabel.textColor = .secondaryLabel
        contentView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(addSceneButton.snp.top).offset(-12)
        }
    }
}
