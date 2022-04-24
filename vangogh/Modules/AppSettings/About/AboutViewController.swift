///
/// AboutViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import OSLog
import SnapKit
import UIKit

class AboutViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let topButtonContainerWidth: CGFloat = 64
        static let topButtonContainerPadding: CGFloat = 12
        static let titleLabelFontSize: CGFloat = 16
        static let infoTextViewFontSize: CGFloat = 16
    }

    /// 返回按钮容器
    private var backButtonContainer: UIView!
    /// 返回按钮
    private var backButton: CircleNavigationBarButton!

    /// 信息文本视图
    private var infoTextView: UITextView!

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

        // 初始化视图

        initViews()
    }

    /// 初始化视图
    private func initViews() {

        view.backgroundColor = .systemGroupedBackground

        // 初始化「导航栏」

        initNavigationBar()

        // 初始化「信息文本视图」

        initInfoTextView()
    }

    /// 初始化「导航栏」
    private func initNavigationBar() {

        // 初始化「返回按钮容器」

        backButtonContainer = UIView()
        backButtonContainer.backgroundColor = .clear
        backButtonContainer.isUserInteractionEnabled = true
        backButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backButtonDidTap)))
        view.addSubview(backButtonContainer)
        backButtonContainer.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.topButtonContainerWidth)
            make.left.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        // 初始化「返回按钮」

        backButton = CircleNavigationBarButton(icon: .arrowBack)
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        backButtonContainer.addSubview(backButton)
        backButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.VC.width)
            make.right.bottom.equalToSuperview().offset(-VC.topButtonContainerPadding)
        }

        // 初始化「标题标签」

        let titleLabel: UILabel = UILabel()
        titleLabel.text = NSLocalizedString("About", comment: "")
        titleLabel.font = .systemFont(ofSize: VC.titleLabelFontSize, weight: .regular)
        titleLabel.textColor = .mgLabel
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.centerY.equalTo(backButton)
            make.left.equalTo(backButtonContainer.snp.right).offset(8)
        }
    }

    /// 初始化「信息文本视图」
    private func initInfoTextView() {

        // 初始化「信息文本视图容器」

        let infoTextViewContainer = RoundedView()
        infoTextViewContainer.backgroundColor = .secondarySystemGroupedBackground
        view.addSubview(infoTextViewContainer)
        infoTextViewContainer.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(backButtonContainer.snp.bottom).offset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化「信息文本视图」

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

    /// 准备「信息文本视图」文本内容
    private func prepareInfoTextViewAttributedText() -> NSMutableAttributedString {

        // 准备文本内容

        let string = LocalDocumentManager.shared.load(type: .about)
        let stringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.secondaryLabel, .font: UIFont.systemFont(ofSize: VC.infoTextViewFontSize, weight: .regular)]
        let completeInfoTextString: NSMutableAttributedString = NSMutableAttributedString(string: string, attributes: stringAttributes)

        // 准备段落样式

        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.paragraphSpacing = 12
        completeInfoTextString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, completeInfoTextString.length))

        return completeInfoTextString
    }
}

extension AboutViewController {

    /// 点击「返回按钮」
    @objc private func backButtonDidTap() {

        print("[About] did tap backButton")

        navigationController?.popViewController(animated: true)
    }
}
