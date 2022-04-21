///
/// UIColor+RGBA
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension UIColor {

    class func colorWithRGBA(rgba: [Decimal]) -> UIColor {

        let doubleValues: [Double] = rgba.map { return $0.doubleValue() }
        return UIColor(red: doubleValues[0] / 255, green: doubleValues[1] / 255, blue: doubleValues[2] / 255, alpha: doubleValues[3])
    }
}
