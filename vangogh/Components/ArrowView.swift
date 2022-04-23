///
/// ArrowView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class ArrowView: UIView {

    /// 箭头方向枚举值
    enum HeadDirection {
        case left, right, top, bottom
    }

    /// 箭头方向
    private var direction: HeadDirection = .right
    /// 尾部宽度
    private var tailWidth: CGFloat = 2
    /// 头部宽度
    private var headWidth: CGFloat = 10
    /// 头部长度
    private var headLength: CGFloat = 8
    /// 箭头图层颜色
    var arrowLayerColor: CGColor? = UIColor.secondaryLabel.cgColor

    // 生命周期

    /// 初始化
    init() {

        super.init(frame: .zero)

        // 初始化视图

        initViews()
    }

    /// 初始化
    init(direction: HeadDirection, arrowLayerColor: CGColor?) {

        super.init(frame: .zero)

        self.direction = direction
        self.arrowLayerColor = arrowLayerColor

        // 初始化视图

        initViews()
    }

    /// 初始化
    init(direction: HeadDirection, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) {

        super.init(frame: .zero)

        self.direction = direction
        self.tailWidth = tailWidth
        self.headWidth = headWidth
        self.headLength = headLength

        // 初始化视图

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }
}

extension ArrowView {

    /// 初始化视图
    private func initViews() {

        backgroundColor = .clear
    }

    /// 重写绘制视图方法
    override func draw(_ rect: CGRect) {

        super.draw(rect)

        updateView()
    }

    /// 更新视图
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
