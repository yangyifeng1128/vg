///
/// UIBezierPath+Curve
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension UIBezierPath {

    static func curve(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> UIBezierPath {

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0, y: height - cornerRadius))
        path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .pi, endAngle: .pi * 3 / 2, clockwise: false)
        path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
        path.addArc(center: CGPoint(x: width - cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .pi * 3 / 2, endAngle: .pi * 2, clockwise: false)
        path.addLine(to: CGPoint(x: width, y: height))

        return self.init(cgPath: path)
    }
}
