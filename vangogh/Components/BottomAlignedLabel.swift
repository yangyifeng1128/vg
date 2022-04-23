///
/// BottomAlignedLabel
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class BottomAlignedLabel: UILabel {

    /// 重写绘制文本方法
    override func drawText(in rect: CGRect) {

        let actualRect = textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
        super.drawText(in: actualRect)
    }

    /// 重写文本矩形区域
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {

        var textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height

        return textRect
    }
}
