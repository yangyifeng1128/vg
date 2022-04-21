///
/// ArrowView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class ArrowView: UIView {

    // 箭头方向枚举值

    enum HeadDirection {
        case left, right, top, bottom
    }

    private var direction: HeadDirection = .right

    private var tailWidth: CGFloat = 2
    private var headWidth: CGFloat = 10
    private var headLength: CGFloat = 8

    var arrowLayerColor: CGColor? = UIColor.secondaryLabel.cgColor

    init() {

        super.init(frame: .zero)

        // 初始化子视图

        initSubviews()
    }

    init(direction: HeadDirection, arrowLayerColor: CGColor?) {

        super.init(frame: .zero)

        self.direction = direction
        self.arrowLayerColor = arrowLayerColor

        // 初始化子视图

        initSubviews()
    }

    init(direction: HeadDirection, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) {

        super.init(frame: .zero)

        self.direction = direction

        self.tailWidth = tailWidth
        self.headWidth = headWidth
        self.headLength = headLength

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {

        backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {

        super.draw(rect)

        updateView()
    }

    func updateView() {

        layer.sublayers?.removeAll()

        var startPoint: CGPoint, endPoint: CGPoint

        switch direction {
        case .left:
            startPoint = CGPoint(x: bounds.width, y: bounds.height / 2)
            endPoint = CGPoint(x: 0, y: bounds.height / 2)
            break
        case .right:
            startPoint = CGPoint(x: 0, y: bounds.height / 2)
            endPoint = CGPoint(x: bounds.width, y: bounds.height / 2)
            break
        case .top:
            startPoint = CGPoint(x: bounds.width / 2, y: bounds.height)
            endPoint = CGPoint(x: bounds.width / 2, y: 0)
            break
        case .bottom:
            startPoint = CGPoint(x: bounds.width / 2, y: 0)
            endPoint = CGPoint(x: bounds.width / 2, y: bounds.height)
            break
        }

        let arrow: UIBezierPath = UIBezierPath.arrow(from: startPoint, to: endPoint, tailWidth: tailWidth, headWidth: headWidth, headLength: headLength)

        let arrowLayer: CAShapeLayer = CAShapeLayer()
        arrowLayer.fillColor = arrowLayerColor
        arrowLayer.path = arrow.cgPath

        layer.addSublayer(arrowLayer)
    }
}
