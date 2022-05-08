///
/// SceneEmulatorCircleProgressView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class SceneEmulatorCircleProgressView: UIView {

    // 视图布局常量枚举值
    enum VC {
        static let trackLayerLineWidth: CGFloat = 2
        static let progressLayerLineWidth: CGFloat = 2
        static let startAngle: CGFloat = -.pi * 0.5
        static let endAngle: CGFloat = .pi * 1.5
    }

    /// 轨道图层
    private var trackLayer: CAShapeLayer!
    /// 进度图层
    private var progressLayer: CAShapeLayer!

    /// 动画状态
    var isAnimating: Bool = false
    /// 进度
    var progress: CGFloat = 0 {
        didSet {
            guard !isAnimating else { return }
            animate(from: progressLayer.strokeEnd, to: min(max(0, progress / GVC.maxProgressValue), 1))
        }
    }

    /// 初始化
    init() {

        super.init(frame: .zero)

        // 初始化「轨道图层」

        trackLayer = CAShapeLayer()
        layer.addSublayer(trackLayer)

        // 初始化「进度图层」

        progressLayer = CAShapeLayer()
        layer.addSublayer(progressLayer)
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 重写绘制视图方法
    override func draw(_ rect: CGRect) {

        super.draw(rect)

        updateView()
    }
}

extension SceneEmulatorCircleProgressView {

    /// 更新视图
    func updateView() {

        let arcCenter = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = (min(bounds.width, bounds.height) - VC.trackLayerLineWidth) / 2
        trackLayer.path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: VC.startAngle, endAngle: VC.endAngle, clockwise: true).cgPath
        trackLayer.fillColor = GVC.defaultSceneControlBackgroundColor.cgColor
        trackLayer.strokeColor = UIColor.secondarySystemGroupedBackground.cgColor
        trackLayer.lineCap = .round
        trackLayer.lineWidth = VC.trackLayerLineWidth

        progressLayer.path = trackLayer.path
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.accent?.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = VC.progressLayerLineWidth
        progressLayer.strokeEnd = 0

        animate(from: progressLayer.strokeEnd, to: min(max(0, progress / GVC.maxProgressValue), 1))
    }

    /// 执行动画
    private func animate(from fromValue: CGFloat, to endValue: CGFloat) {

        isAnimating = true
        progressLayer.strokeEnd = endValue

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = fromValue
        animation.duration = 0.2
        animation.delegate = self
        progressLayer.add(animation, forKey: "strokeEnd")
    }
}

extension SceneEmulatorCircleProgressView: CAAnimationDelegate {

    /// 动画已结束
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {

        isAnimating = !flag
    }
}
