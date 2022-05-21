///
/// AboutViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension AboutViewController {

    @objc func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }
}

extension AboutViewController {

    /// 准备「信息文本视图」文本
    func prepareInfoTextViewAttributedText() -> NSMutableAttributedString {

        // 准备文本内容

        let string = LocalDocumentManager.shared.load(type: .about)
        let stringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.secondaryLabel, .font: UIFont.systemFont(ofSize: VC.infoTextViewFontSize, weight: .regular)]
        let completeInfoString: NSMutableAttributedString = NSMutableAttributedString(string: string, attributes: stringAttributes)

        // 准备段落样式

        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.paragraphSpacing = 12
        completeInfoString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, completeInfoString.length))

        return completeInfoString
    }
}
