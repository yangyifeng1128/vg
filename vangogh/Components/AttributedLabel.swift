///
/// AttributedLabel
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class AttributedLabel: UILabel {

    /// 内边距
    var insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

    /// 重写绘制文本方法
    override func drawText(in rect: CGRect) {

        super.drawText(in: rect.inset(by: insets))
    }

    /// 重写固有内容尺寸
    override var intrinsicContentSize: CGSize {

        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom)
    }

    /// 重写边框大小
    override var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = bounds.width - insets.left - insets.right
        }
    }
}
