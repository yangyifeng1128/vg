///
/// GameEditorDefaultBottomView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

protocol GameEditorDefaultBottomViewDelegate: AnyObject {
    func addSceneButtonDidTap()
}

class GameEditorDefaultBottomView: BorderedView {

    /// 视图布局常量枚举值
    enum ViewLayoutConstants {
        static let contentViewHeight: CGFloat = 120
        static let addSceneButtonHeight: CGFloat = 56
        static let addSceneButtonTitleLabelFontSize: CGFloat = 18
        static let infoLabelFontSize: CGFloat = 13
        static let infoLabelIconWidth: CGFloat = 16
    }

    weak var delegate: GameEditorDefaultBottomViewDelegate?

    private var contentView: UIView!
    private var addSceneButton: RoundedButton!
    private var infoLabel: UILabel!

    init() {

        super.init(side: .top)

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {

        contentView = UIView()
        contentView.backgroundColor = .systemBackground
        addSubview(contentView)
        contentView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(ViewLayoutConstants.contentViewHeight)
            make.left.top.equalToSuperview()
        }

        addSceneButton = RoundedButton(cornerRadius: GlobalViewLayoutConstants.defaultViewCornerRadius)
        addSceneButton.backgroundColor = .secondarySystemBackground
        addSceneButton.tintColor = .mgLabel
        addSceneButton.setTitle(NSLocalizedString("AddScene", comment: ""), for: .normal)
        addSceneButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        addSceneButton.titleLabel?.font = .systemFont(ofSize: ViewLayoutConstants.addSceneButtonTitleLabelFontSize, weight: .regular)
        addSceneButton.setTitleColor(.mgLabel, for: .normal)
        addSceneButton.setImage(.add, for: .normal)
        addSceneButton.adjustsImageWhenHighlighted = false
        addSceneButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        addSceneButton.imageView?.tintColor = .mgLabel
        addSceneButton.addTarget(self, action: #selector(addSceneButtonDidTap), for: .touchUpInside)
        contentView.addSubview(addSceneButton)
        addSceneButton.snp.makeConstraints { make -> Void in
            make.height.equalTo(ViewLayoutConstants.addSceneButtonHeight)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        infoLabel = UILabel()
        infoLabel.attributedText = prepareInfoLabelAttributedText()
        infoLabel.font = .systemFont(ofSize: ViewLayoutConstants.infoLabelFontSize, weight: .regular)
        infoLabel.textColor = .secondaryLabel
        contentView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(addSceneButton.snp.top).offset(-12)
        }
    }

    private func prepareInfoLabelAttributedText() -> NSMutableAttributedString {

        let completeInfoString: NSMutableAttributedString = NSMutableAttributedString(string: "")

        // 准备信息图标

        let iconAttachment: NSTextAttachment = NSTextAttachment()
        iconAttachment.image = .info
        let infoLabelFont: UIFont = UIFont.systemFont(ofSize: ViewLayoutConstants.infoLabelFontSize, weight: .regular)
        let iconAttachmentY: CGFloat = (infoLabelFont.capHeight - ViewLayoutConstants.infoLabelIconWidth) / 2
        iconAttachment.bounds = CGRect(x: 0, y: iconAttachmentY, width: ViewLayoutConstants.infoLabelIconWidth, height: ViewLayoutConstants.infoLabelIconWidth)
        let iconString: NSAttributedString = NSAttributedString(attachment: iconAttachment)
        completeInfoString.append(iconString)

        // 准备信息标题

        let titleString: NSAttributedString = NSAttributedString(string: " " + NSLocalizedString("AddSceneInfo", comment: ""))
        completeInfoString.append(titleString)

        return completeInfoString
    }
}

extension GameEditorDefaultBottomView {

    @objc private func addSceneButtonDidTap() {

        delegate?.addSceneButtonDidTap()
    }
}
