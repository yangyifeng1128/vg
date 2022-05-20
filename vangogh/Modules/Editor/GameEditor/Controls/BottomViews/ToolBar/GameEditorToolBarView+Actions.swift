///
/// GameEditorToolBarView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension GameEditorToolBarView {

    @objc func addSceneButtonDidTap() {

        delegate?.addSceneButtonDidTap()
    }
}

extension GameEditorToolBarView {

    /// 准备「信息标签」文本
    func prepareInfoLabelAttributedText() -> NSMutableAttributedString {

        let completeInfoTextString: NSMutableAttributedString = NSMutableAttributedString(string: "")

        // 准备信息图标

        let iconAttachment: NSTextAttachment = NSTextAttachment()
        iconAttachment.image = .info
        let infoLabelFont: UIFont = UIFont.systemFont(ofSize: VC.infoLabelFontSize, weight: .regular)
        let iconAttachmentY: CGFloat = (infoLabelFont.capHeight - VC.infoLabelIconWidth) / 2
        iconAttachment.bounds = CGRect(x: 0, y: iconAttachmentY, width: VC.infoLabelIconWidth, height: VC.infoLabelIconWidth)
        let iconString: NSAttributedString = NSAttributedString(attachment: iconAttachment)
        completeInfoTextString.append(iconString)

        // 准备信息标题

        let titleString: NSAttributedString = NSAttributedString(string: " " + NSLocalizedString("AddSceneInfo", comment: ""))
        completeInfoTextString.append(titleString)

        return completeInfoTextString
    }
}
