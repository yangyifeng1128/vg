///
/// TermsOfServiceViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit
import WebKit

class TermsOfServiceViewController: UIViewController {

    // 视图布局常量枚举值

    enum ViewLayoutConstants {
        static let topButtonContainerWidth: CGFloat = 64
        static let topButtonContainerPadding: CGFloat = 12
        static let titleLabelFontSize: CGFloat = 16
        static let infoTextViewFontSize: CGFloat = 16
    }

    private var backButtonContainer: UIView!
    private var backButton: CircleNavigationBarButton!
    private var titleLabel: UILabel!

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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)
    }

    private func initSubviews() {

        view.backgroundColor = .systemGroupedBackground

        // 初始化导航栏

        initNavigationBar()

        // 初始化信息文本视图

        initInfoTextView()
    }

    private func initNavigationBar() {

        // 初始化返回按钮

        backButtonContainer = UIView()
        backButtonContainer.backgroundColor = .clear
        backButtonContainer.isUserInteractionEnabled = true
        backButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backButtonDidTap)))
        view.addSubview(backButtonContainer)
        backButtonContainer.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(ViewLayoutConstants.topButtonContainerWidth)
            make.left.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        backButton = CircleNavigationBarButton(icon: .arrowBack)
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        backButtonContainer.addSubview(backButton)
        backButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.ViewLayoutConstants.width)
            make.right.bottom.equalToSuperview().offset(-ViewLayoutConstants.topButtonContainerPadding)
        }

        // 初始化标题标签

        titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("TermsOfService", comment: "")
        titleLabel.font = .systemFont(ofSize: ViewLayoutConstants.titleLabelFontSize, weight: .regular)
        titleLabel.textColor = .mgLabel
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.centerY.equalTo(backButton)
            make.left.equalTo(backButtonContainer.snp.right).offset(8)
        }
    }

    private func initInfoTextView() {

        let infoTextViewContainer = RoundedView()
        infoTextViewContainer.backgroundColor = .secondarySystemGroupedBackground
        view.addSubview(infoTextViewContainer)
        infoTextViewContainer.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(backButtonContainer.snp.bottom).offset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        infoTextView = UITextView()
        infoTextView.attributedText = prepareInfoTextViewAttributedText()
        infoTextView.backgroundColor = .clear
        infoTextView.textContainerInset = UIEdgeInsets(top: 24, left: 8, bottom: 24, right: 8)
        infoTextView.isEditable = false
        infoTextView.isSelectable = false
        infoTextView.isScrollEnabled = true
        infoTextViewContainer.addSubview(infoTextView)
        infoTextView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }
    }

    private func prepareInfoTextViewAttributedText() -> NSMutableAttributedString {

        // 准备文本内容

        let string = LocalDocumentManager.shared.load(type: .termsOfService)
        let stringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.secondaryLabel, .font: UIFont.systemFont(ofSize: ViewLayoutConstants.infoTextViewFontSize, weight: .regular)]
        let completeInfoTextString: NSMutableAttributedString = NSMutableAttributedString(string: string, attributes: stringAttributes)

        // 准备段落样式

        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.paragraphSpacing = 12
        completeInfoTextString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, completeInfoTextString.length))

        return completeInfoTextString
    }
}

extension TermsOfServiceViewController {

    @objc private func backButtonDidTap() {

        print("[TermsOfService] did tap backButton")

        navigationController?.popViewController(animated: true)
    }
}
