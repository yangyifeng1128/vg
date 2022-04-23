///
/// GameEditorWillAddSceneBottomView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

protocol GameEditorWillAddSceneBottomViewDelegate: AnyObject {
    func cancelAddingSceneButtonDidTap()
}

class GameEditorWillAddSceneBottomView: UIView {

    /// 视图布局常量枚举值
    enum ViewLayoutConstants {
        static let contentViewHeight: CGFloat = 144
        static let cancelAddingSceneButtonHeight: CGFloat = 64
        static let cancelAddingSceneButtonTitleLabelFontSize: CGFloat = 18
        static let infoLabelFontSize: CGFloat = 16
        static let infoLabelIconWidth: CGFloat = 20
    }

    weak var delegate: GameEditorWillAddSceneBottomViewDelegate?

    private var contentView: UIView!
    private var cancelAddingSceneButton: UIButton!
    private var infoLabel: UILabel!

    init() {

        super.init(frame: .zero)

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {

        contentView = UIView()
        contentView.backgroundColor = GVC.addSceneViewBackgroundColor
        addSubview(contentView)
        contentView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(ViewLayoutConstants.contentViewHeight)
            make.left.top.equalToSuperview()
        }

        cancelAddingSceneButton = UIButton()
        cancelAddingSceneButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        cancelAddingSceneButton.titleLabel?.font = .systemFont(ofSize: ViewLayoutConstants.cancelAddingSceneButtonTitleLabelFontSize, weight: .regular)
        cancelAddingSceneButton.setTitleColor(.lightText, for: .normal)
        cancelAddingSceneButton.addTarget(self, action: #selector(cancelAddingSceneButtonDidTap), for: .touchUpInside)
        contentView.addSubview(cancelAddingSceneButton)
        cancelAddingSceneButton.snp.makeConstraints { make -> Void in
            make.height.equalTo(ViewLayoutConstants.cancelAddingSceneButtonHeight)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        infoLabel = UILabel()
        let completeString: NSMutableAttributedString = NSMutableAttributedString(string: "")
        let iconAttachment = NSTextAttachment()
        iconAttachment.image = .handPointUp
        let infoLabelFont = UIFont.systemFont(ofSize: ViewLayoutConstants.infoLabelFontSize, weight: .regular)
        let iconAttachmentY: CGFloat = (infoLabelFont.capHeight - ViewLayoutConstants.infoLabelIconWidth) / 2
        iconAttachment.bounds = CGRect(x: 0, y: iconAttachmentY, width: ViewLayoutConstants.infoLabelIconWidth, height: ViewLayoutConstants.infoLabelIconWidth)
        let iconString = NSAttributedString(attachment: iconAttachment)
        completeString.append(iconString)
        let titleString = NSAttributedString(string: " " + NSLocalizedString("WillAddSceneInfo", comment: ""))
        completeString.append(titleString)
        infoLabel.attributedText = completeString
        infoLabel.font = infoLabelFont
        infoLabel.textColor = .white
        infoLabel.textAlignment = .center
        contentView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(cancelAddingSceneButton.snp.top).offset(-8)
        }
    }
}

extension GameEditorWillAddSceneBottomView {

    @objc private func cancelAddingSceneButtonDidTap() {

        delegate?.cancelAddingSceneButtonDidTap()
    }
}
