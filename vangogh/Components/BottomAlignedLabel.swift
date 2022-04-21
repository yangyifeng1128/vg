///
/// BottomAlignedLabel
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class BottomAlignedLabel: UILabel {

    override func drawText(in rect: CGRect) {

        let actualRect = textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
        super.drawText(in: actualRect)
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {

        var textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height

        return textRect
    }
}
