///
/// AgreementsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension AgreementsViewController {

    @objc func agreeButtonDidTap() {

        UserDefaults.standard.setValue(true, forKey: GKC.agreementsSigned)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @objc func disagreeButtonDidTap() {

        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    }
}

extension AgreementsViewController {

    /// 准备「底部视图信息标签」文本
    func prepareBottomViewInfoLabelAttributedText() -> NSMutableAttributedString {

        // 准备签署信息

        let string: String = NSLocalizedString("AgreementsInfo", comment: "")
        let stringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.secondaryLabel, .font: UIFont.systemFont(ofSize: VC.bottomViewInfoLabelFontSize, weight: .regular)]
        let completeBottomViewInfoString: NSMutableAttributedString = NSMutableAttributedString(string: string, attributes: stringAttributes)

        // 准备段落样式

        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        completeBottomViewInfoString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, completeBottomViewInfoString.length))

        return completeBottomViewInfoString
    }

    /// 准备「信息文本视图」文本
    func prepareInfoTextViewAttributedText() -> NSMutableAttributedString {

        // 准备协议内容

        let appName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
        let string: String = "感谢您信任并使用「" + appName + "」的产品和服务！\n为了给您提供更好的创作与互动体验，在您使用「" + appName + "」具体功能的过程中，我们会向您收集必要的用户信息，或请求必要的设备权限。\n未经您同意，我们不会向任何第三方披露、共享您的个人信息。\n请完整地阅读《服务协议》与《隐私政策》来了解如何保护您的个人信息。\n"
        let stringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.darkText, .font: UIFont.systemFont(ofSize: VC.infoTextViewFontSize, weight: .regular)]
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

    /// 为文本视图添加交互链接
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
