///
/// UIBezierPath+Waterdrop
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension UIBezierPath {

    static func waterdrop(width: CGFloat) -> UIBezierPath {

        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: width / 2, y: width * 3 / 4), radius: width / 2, startAngle: .pi * 7 / 4, endAngle: .pi * 5 / 4, clockwise: false)
        path.addLine(to: CGPoint(x: width / 2, y: 0))
        path.closeSubpath()

        return self.init(cgPath: path)
    }

    static func waterdrop2(width: CGFloat) -> UIBezierPath {

        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: width / 2, y: width * 3 / 4), radius: width / 2, startAngle: .pi * 7 / 4, endAngle: .pi * 5 / 4, clockwise: false)
        path.addLine(to: CGPoint(x: (width - NodeItemCurveView.ViewLayoutConstants.lineWidth) / 2, y: 0))
        path.addLine(to: CGPoint(x: (width + NodeItemCurveView.ViewLayoutConstants.lineWidth) / 2, y: 0))
        path.closeSubpath()

        return self.init(cgPath: path)
    }
}
