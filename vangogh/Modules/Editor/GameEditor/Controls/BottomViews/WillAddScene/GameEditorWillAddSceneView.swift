///
/// GameEditorWillAddSceneView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class GameEditorWillAddSceneView: UIView {

    /// 视图布局常量枚举值
    enum VC {
        static let contentViewHeight: CGFloat = 144
        static let cancelAddingSceneButtonHeight: CGFloat = 64
        static let cancelAddingSceneButtonTitleLabelFontSize: CGFloat = 18
        static let infoLabelFontSize: CGFloat = 16
        static let infoLabelIconWidth: CGFloat = 20
    }

    /// 代理
    weak var delegate: GameEditorWillAddSceneViewDelegate?

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

        // 初始化「内容视图」

        let contentView: UIView = UIView()
        contentView.backgroundColor = GVC.addSceneViewBackgroundColor
        addSubview(contentView)
        contentView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(VC.contentViewHeight)
            make.left.top.equalToSuperview()
        }

        // 初始化「取消添加场景按钮」

        let cancelAddingSceneButton: UIButton = UIButton()
        cancelAddingSceneButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        cancelAddingSceneButton.titleLabel?.font = .systemFont(ofSize: VC.cancelAddingSceneButtonTitleLabelFontSize, weight: .regular)
        cancelAddingSceneButton.setTitleColor(.lightText, for: .normal)
        cancelAddingSceneButton.addTarget(self, action: #selector(cancelAddingSceneButtonDidTap), for: .touchUpInside)
        contentView.addSubview(cancelAddingSceneButton)
        cancelAddingSceneButton.snp.makeConstraints { make -> Void in
            make.height.equalTo(VC.cancelAddingSceneButtonHeight)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化「信息标签」

        let infoLabel: UILabel = UILabel()
        let completeString: NSMutableAttributedString = NSMutableAttributedString(string: "")
        let iconAttachment = NSTextAttachment()
        iconAttachment.image = .handPointUp
        let infoLabelFont = UIFont.systemFont(ofSize: VC.infoLabelFontSize, weight: .regular)
        let iconAttachmentY: CGFloat = (infoLabelFont.capHeight - VC.infoLabelIconWidth) / 2
        iconAttachment.bounds = CGRect(x: 0, y: iconAttachmentY, width: VC.infoLabelIconWidth, height: VC.infoLabelIconWidth)
        let iconString = NSAttributedString(attachment: iconAttachment)
        completeString.append(iconString)
        let titleString = NSAttributedString(string: " " + NSLocalizedString("WillAddSceneInfo", comment: ""))
        completeString.append(titleString)
        infoLabel.attributedText = completeString
        infoLabel.font = infoLabelFont
        infoLabel.textColor = .mgHoneydew
        infoLabel.textAlignment = .center
        contentView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(cancelAddingSceneButton.snp.top).offset(-8)
        }
    }
}
