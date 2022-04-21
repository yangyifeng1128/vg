///
/// UIBezierPath+Arrow
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension UIBezierPath {

    static func arrow(from start: CGPoint, to end: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) -> UIBezierPath {

        let length = hypot(end.x - start.x, end.y - start.y)
        let tailLength = length - headLength

        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { return CGPoint(x: x, y: y) }

        let wingLength: CGFloat = 2

        let points: [CGPoint] = [
            p(0, tailWidth / 2),
            p(tailLength, tailWidth / 2),
            p(tailLength - wingLength, headWidth / 2),
            p(length, 0),
            p(tailLength - wingLength, -headWidth / 2),
            p(tailLength, -tailWidth / 2),
            p(0, -tailWidth / 2)
        ]

        let cosine = (end.x - start.x) / length
        let sine = (end.y - start.y) / length
        let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: start.y)

        let path = CGMutablePath()
        path.addLines(between: points, transform: transform)
        path.closeSubpath()

        return self.init(cgPath: path)
    }

    static func arrow2(from start: CGPoint, to end: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) -> UIBezierPath {

        let length = hypot(end.x - start.x, end.y - start.y)
        let tailLength = length * 0.6 - headLength
        let wingLength: CGFloat = 2

        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { return CGPoint(x: x, y: y) }

        let points: [CGPoint] = [
            p(0, tailWidth / 2),
            p(tailLength, tailWidth / 2),
            p(tailLength - wingLength, headWidth / 2),
            p(length * 0.6, tailWidth / 2),
            p(length, tailWidth / 2),
            p(length, -tailWidth / 2),
            p(length * 0.6, -tailWidth / 2),
            p(tailLength - wingLength, -headWidth / 2),
            p(tailLength, -tailWidth / 2),
            p(0, -tailWidth / 2)
        ]

        let cosine = (end.x - start.x) / length
        let sine = (end.y - start.y) / length
        let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: start.y)

        let path = CGMutablePath()
        path.addLines(between: points, transform: transform)
        path.closeSubpath()

        return self.init(cgPath: path)
    }
}
