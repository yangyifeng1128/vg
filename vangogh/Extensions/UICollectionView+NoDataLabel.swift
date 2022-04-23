///
/// UICollectionView+NoDataLabel
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension UICollectionView {

    //// 视图布局常量枚举值    enum ViewLayoutConstants {
        static let oopsStringFontSize: CGFloat = 64
        static let noDataTitleStringFontSize: CGFloat = 16
    }

    /// 显示无数据信息
    func showNoDataInfo(title: String, tintColor: UIColor = .tertiaryLabel) {

        let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))

        let completeNoDataString: NSMutableAttributedString = NSMutableAttributedString(string: "")

        // 准备 oops

        let oopsStringAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.tertiaryLabel,
                .font: UIFont.systemFont(ofSize: ViewLayoutConstants.oopsStringFontSize, weight: .regular)
        ]
        let oopsString: NSAttributedString = NSAttributedString(string: "(·_·)\n", attributes: oopsStringAttributes)
        completeNoDataString.append(oopsString)

        // 准备标题

        let noDataTitleStringAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: tintColor,
                .font: UIFont.systemFont(ofSize: ViewLayoutConstants.noDataTitleStringFontSize, weight: .regular)
        ]
        let noDataTitleString: NSAttributedString = NSAttributedString(string: title, attributes: noDataTitleStringAttributes)
        completeNoDataString.append(noDataTitleString)

        // 准备段落样式

        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 24
        paragraphStyle.alignment = .center
        completeNoDataString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, completeNoDataString.length))

        // 为「无数据标签」设置文本内容

        noDataLabel.attributedText = completeNoDataString
        noDataLabel.numberOfLines = 0
        noDataLabel.lineBreakMode = .byTruncatingTail

        backgroundView = noDataLabel
    }

    /// 隐藏无数据信息
    func hideNoDataInfo() {

        backgroundView = nil
    }
}
