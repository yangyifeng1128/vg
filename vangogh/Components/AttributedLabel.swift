///
/// AttributedLabel
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class AttributedLabel: UILabel {

    var insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

    override func drawText(in rect: CGRect) {

        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {

        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom)
    }

    override var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = bounds.width - insets.left - insets.right
        }
    }
}
