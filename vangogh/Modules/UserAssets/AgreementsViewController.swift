///
/// AgreementsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class AgreementsViewController: UIViewController {

    /// 视图布局常量枚举值
    enum ViewLayoutConstants {
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

    private var blurView: UIVisualEffectView!
    private var contentView: RoundedView!
    private var titleLabel: UILabel!
    private var bottomView: UIView!
    private var disagreeButton: RoundedButton!
    private var agreeButton: RoundedButton!
    private var bottomViewInfoLabel: UILabel!
    private var infoTextView: UITextView!

    init() {

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    //
    //
    // MARK: - 视图生命周期
    //
    //

    override func viewDidLoad() {

        super.viewDidLoad()

        // 初始化子视图

        initSubviews()
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // 隐藏导航栏

        navigationController?.navigationBar.isHidden = true
    }

    private func initSubviews() {

        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
        view.addSubview(blurView)
        blurView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        contentView = RoundedView()
        contentView.backgroundColor = .white
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make -> Void in
            make.width.equalTo(ViewLayoutConstants.contentViewWidth)
            make.height.equalTo(ViewLayoutConstants.contentViewHeight)
            make.center.equalToSuperview()
        }

        // 初始化标题标签

        titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("Agreements", comment: "")
        titleLabel.font = .systemFont(ofSize: ViewLayoutConstants.titleLabelFontSize, weight: .semibold)
        titleLabel.textColor = .darkText
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(24)
        }

        // 初始化底部视图

        bottomView = UIView()
        bottomView.backgroundColor = .tertiarySystemBackground
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(ViewLayoutConstants.bottomViewHeight)
            make.left.bottom.equalToSuperview()
        }

        disagreeButton = RoundedButton(cornerRadius: GlobalViewLayoutConstants.defaultViewCornerRadius)
        disagreeButton.tintColor = .secondaryLabel
        disagreeButton.setTitle(NSLocalizedString("Disagree", comment: ""), for: .normal)
        disagreeButton.titleLabel?.font = .systemFont(ofSize: ViewLayoutConstants.disagreeButtonTitleLabelFontSize, weight: .regular)
        disagreeButton.setTitleColor(.secondaryLabel, for: .normal)
        disagreeButton.addTarget(self, action: #selector(disagreeButtonDidTap), for: .touchUpInside)
        bottomView.addSubview(disagreeButton)
        disagreeButton.snp.makeConstraints { make -> Void in
            make.height.equalTo(ViewLayoutConstants.disagreeButtonHeight)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-8)
        }

        agreeButton = RoundedButton(cornerRadius: GlobalViewLayoutConstants.defaultViewCornerRadius)
        agreeButton.backgroundColor = .accent
        agreeButton.tintColor = .white
        agreeButton.setTitle(NSLocalizedString("Agree", comment: ""), for: .normal)
        agreeButton.titleLabel?.font = .systemFont(ofSize: ViewLayoutConstants.agreeButtonTitleLabelFontSize, weight: .regular)
        agreeButton.setTitleColor(.white, for: .normal)
        agreeButton.addTarget(self, action: #selector(agreeButtonDidTap), for: .touchUpInside)
        bottomView.addSubview(agreeButton)
        agreeButton.snp.makeConstraints { make -> Void in
            make.height.equalTo(ViewLayoutConstants.agreeButtonHeight)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(disagreeButton.snp.top)
        }

        bottomViewInfoLabel = UILabel()
        bottomViewInfoLabel.attributedText = prepareBottomViewInfoLabelAttributedText()
        bottomViewInfoLabel.numberOfLines = 2
        bottomViewInfoLabel.lineBreakMode = .byTruncatingTail
        bottomView.addSubview(bottomViewInfoLabel)
        bottomViewInfoLabel.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalTo(agreeButton.snp.top).offset(-8)
        }

        // 初始化信息文本视图

        infoTextView = UITextView()
        infoTextView.delegate = self
        infoTextView.attributedText = prepareInfoTextViewAttributedText()
        infoTextView.backgroundColor = .white
        infoTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.accent!]
        infoTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
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

    private func prepareBottomViewInfoLabelAttributedText() -> NSMutableAttributedString {

        // 准备签署信息

        let string: String = NSLocalizedString("AgreementsInfo", comment: "")
        let stringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.secondaryLabel, .font: UIFont.systemFont(ofSize: ViewLayoutConstants.bottomViewInfoLabelFontSize, weight: .regular)]
        let completeBottomViewInfoString: NSMutableAttributedString = NSMutableAttributedString(string: string, attributes: stringAttributes)

        // 准备段落样式

        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        completeBottomViewInfoString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, completeBottomViewInfoString.length))

        return completeBottomViewInfoString
    }

    private func prepareInfoTextViewAttributedText() -> NSMutableAttributedString {

        // 准备协议内容

        let appName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
        let string: String = "感谢您信任并使用「" + appName + "」的产品和服务！\n为了给您提供更好的创作与互动体验，在您使用「" + appName + "」具体功能的过程中，我们会向您收集必要的用户信息，或请求必要的设备权限。\n未经您同意，我们不会向任何第三方披露、共享您的个人信息。\n请完整地阅读《服务协议》与《隐私政策》来了解如何保护您的个人信息。\n"
        let stringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.darkText, .font: UIFont.systemFont(ofSize: ViewLayoutConstants.infoTextViewFontSize, weight: .regular)]
        let completeInfoTextString: NSMutableAttributedString = NSMutableAttributedString(string: string, attributes: stringAttributes)

        // 准备链接内容

        completeInfoTextString.addAttribute(.link, value: LocalDocumentType.termsOfService.rawValue, range: (completeInfoTextString.string as NSString).range(of: "《服务协议》"))
        completeInfoTextString.addAttribute(.link, value: LocalDocumentType.privacyPolicy.rawValue, range: (completeInfoTextString.string as NSString).range(of: "《隐私政策》"))

        // 准备段落样式

        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.paragraphSpacing = 12
        completeInfoTextString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, completeInfoTextString.length))

        return completeInfoTextString
    }
}

extension AgreementsViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {

        var vc: UIViewController?

        if URL.absoluteString == LocalDocumentType.termsOfService.rawValue {
            vc = TermsOfServiceViewController()
        } else if URL.absoluteString == LocalDocumentType.privacyPolicy.rawValue {
            vc = PrivacyPolicyViewController()
        }

        if let vc = vc {
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }

        return true
    }
}

extension AgreementsViewController {

    @objc private func agreeButtonDidTap() {

        print("[Agreements] did tap agreeButton")

        UserDefaults.standard.setValue(true, forKey: "agreementsSigned")
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @objc private func disagreeButtonDidTap() {

        print("[Agreements] did tap disagreeButton")

        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    }
}
