///
/// AgreementsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class AgreementsViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let contentViewWidth: CGFloat = 280
        static let contentViewHeight: CGFloat = 480
        static let titleLabelFontSize: CGFloat = 16
        static let bottomViewHeight: CGFloat = 168
        static let bottomViewInfoLabelFontSize: CGFloat = 13
        static let agreeButtonHeight: CGFloat = 48
        static let agreeButtonTitleLabelFontSize: CGFloat = 16
        static let disagreeButtonHeight: CGFloat = 40
        static let disagreeButtonTitleLabelFontSize: CGFloat = 13
        static let infoTextViewFontSize: CGFloat = 13
    }

    /// 内部链接枚举值
    enum L {
        static let termsOfServiceLink: String = "\(GUC.metaGameURLScheme)://\(LocalDocumentType.termsOfService.rawValue)"
        static let privacyPolicyLink: String = "\(GUC.metaGameURLScheme)://\(LocalDocumentType.privacyPolicy.rawValue)"
    }

    /// 初始化
    init() {

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 视图加载完成
    override func viewDidLoad() {

        super.viewDidLoad()

        initViews()
    }

    /// 视图即将显示
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // 隐藏导航栏

        navigationController?.navigationBar.isHidden = true
    }

    /// 初始化视图
    private func initViews() {

        // 初始化「模糊视图」

        let blurView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        view.addSubview(blurView)
        blurView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        // 初始化「内容视图」

        let contentView: RoundedView = RoundedView()
        contentView.backgroundColor = .white
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.contentViewWidth)
            make.height.equalTo(VC.contentViewHeight)
            make.center.equalToSuperview()
        }

        // 初始化「标题标签」

        let titleLabel: UILabel = UILabel()
        titleLabel.text = NSLocalizedString("Agreements", comment: "")
        titleLabel.font = .systemFont(ofSize: VC.titleLabelFontSize, weight: .semibold)
        titleLabel.textColor = .mgLabel
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(24)
        }

        // 初始化「底部视图」

        let bottomView: UIView = UIView()
        bottomView.backgroundColor = .tertiarySystemBackground
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(VC.bottomViewHeight)
            make.left.bottom.equalToSuperview()
        }

        // 初始化「不同意按钮」

        let disagreeButton: RoundedButton = RoundedButton(cornerRadius: GVC.defaultViewCornerRadius)
        disagreeButton.tintColor = .secondaryLabel
        disagreeButton.setTitle(NSLocalizedString("Disagree", comment: ""), for: .normal)
        disagreeButton.titleLabel?.font = .systemFont(ofSize: VC.disagreeButtonTitleLabelFontSize, weight: .regular)
        disagreeButton.setTitleColor(.secondaryLabel, for: .normal)
        disagreeButton.addTarget(self, action: #selector(disagreeButtonDidTap), for: .touchUpInside)
        bottomView.addSubview(disagreeButton)
        disagreeButton.snp.makeConstraints { make -> Void in
            make.height.equalTo(VC.disagreeButtonHeight)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-8)
        }

        // 初始化「同意按钮」

        let agreeButton: RoundedButton = RoundedButton(cornerRadius: GVC.defaultViewCornerRadius)
        agreeButton.backgroundColor = .accent
        agreeButton.tintColor = .mgHoneydew
        agreeButton.setTitle(NSLocalizedString("Agree", comment: ""), for: .normal)
        agreeButton.titleLabel?.font = .systemFont(ofSize: VC.agreeButtonTitleLabelFontSize, weight: .regular)
        agreeButton.setTitleColor(.mgHoneydew, for: .normal)
        agreeButton.addTarget(self, action: #selector(agreeButtonDidTap), for: .touchUpInside)
        bottomView.addSubview(agreeButton)
        agreeButton.snp.makeConstraints { make -> Void in
            make.height.equalTo(VC.agreeButtonHeight)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(disagreeButton.snp.top)
        }

        // 初始化「底部视图信息标签」

        let bottomViewInfoLabel: UILabel = UILabel()
        bottomViewInfoLabel.attributedText = prepareBottomViewInfoLabelAttributedText()
        bottomViewInfoLabel.numberOfLines = 2
        bottomViewInfoLabel.lineBreakMode = .byTruncatingTail
        bottomView.addSubview(bottomViewInfoLabel)
        bottomViewInfoLabel.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalTo(agreeButton.snp.top).offset(-8)
        }

        // 初始化「信息文本视图」

        let infoTextView: UITextView = UITextView()
        infoTextView.delegate = self
        infoTextView.attributedText = prepareInfoTextViewAttributedText()
        infoTextView.backgroundColor = .white
        infoTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        infoTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.accent!]
        infoTextView.isEditable = false
        infoTextView.isSelectable = true
        infoTextView.isScrollEnabled = true
        contentView.addSubview(infoTextView)
        infoTextView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.bottom.equalTo(bottomView.snp.top)
        }
    }
}
