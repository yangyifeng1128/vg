///
/// UIImage+Circle
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension UIImage {

    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()

        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: rect)

        context.restoreGState()
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }
}
