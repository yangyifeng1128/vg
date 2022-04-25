///
/// GameEditorTransitionView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class GameEditorTransitionView: UIView {

    /// 视图布局常量枚举值
    enum VC {
        static let tailWidth: CGFloat = 2
        static let headWidth: CGFloat = 10
        static let headLength: CGFloat = 8
        static let pulseWidth: CGFloat = 3
    }

    private var pulseAnimationLayer: CALayer!
    private var pulseAnimationGroup: CAAnimationGroup!
    private var pulseAnimationDuration: TimeInterval = 1.2

    private var arrowLayerColor: CGColor!
    var startScene: MetaScene!
    var endScene: MetaScene!

    init(startScene: MetaScene, endScene: MetaScene) {

        super.init(frame: .zero)

        self.startScene = startScene
        self.endScene = endScene

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {

        backgroundColor = .clear
        arrowLayerColor = UIColor.tertiaryLabel.cgColor

        updateView()
    }

    func highlight(isSent: Bool) {

        arrowLayerColor = isSent ? UIColor.accent?.cgColor : UIColor.fcGreen?.cgColor
        updateView()

        startPulseAnimating(isSent: isSent)
    }

    func unhighlight() {

        arrowLayerColor = UIColor.tertiaryLabel.cgColor
        updateView()

        stopPulseAnimating()
    }

    func updateView() {

        layer.sublayers?.removeAll()

        let arrow = UIBezierPath.arrow2(from: startScene.center, to: endScene.center, tailWidth: VC.tailWidth, headWidth: VC.headWidth, headLength: VC.headLength)

        let arrowLayer = CAShapeLayer()
        arrowLayer.fillColor = arrowLayerColor
        arrowLayer.path = arrow.cgPath

        layer.addSublayer(arrowLayer)
    }
}

extension GameEditorTransitionView {

    private func startPulseAnimating(isSent: Bool) {

        let backgroundColor: CGColor? = isSent ? UIColor.accent?.cgColor : UIColor.fcGreen?.cgColor
        pulseAnimationLayer = CALayer()
        pulseAnimationLayer.position = startScene.center
        pulseAnimationLayer.bounds = CGRect(x: 0, y: 0, width: VC.pulseWidth, height: VC.pulseWidth)
        pulseAnimationLayer.backgroundColor = backgroundColor
        pulseAnimationLayer.cornerRadius = VC.pulseWidth / 2

        pulseAnimationGroup = CAAnimationGroup()
        pulseAnimationGroup.duration = pulseAnimationDuration
        pulseAnimationGroup.repeatCount = 1
        pulseAnimationGroup.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimationGroup.animations = [positionAnimation(), scaleAnimation(), opacityAnimation()]
        pulseAnimationLayer.add(pulseAnimationGroup, forKey: "pulse")

        layer.addSublayer(pulseAnimationLayer)
    }

    private func stopPulseAnimating() {

        if pulseAnimationLayer != nil {
            pulseAnimationLayer.removeFromSuperlayer()
            pulseAnimationLayer = nil
            pulseAnimationGroup = nil
        }
    }

    func positionAnimation() -> CABasicAnimation {

        let positionAnimaton: CABasicAnimation = CABasicAnimation(keyPath: "position")
        positionAnimaton.duration = pulseAnimationDuration
        positionAnimaton.fromValue = [startScene.center.x, startScene.center.y]
        positionAnimaton.toValue = [endScene.center.x, endScene.center.y]

        return positionAnimaton
    }

    func scaleAnimation() -> CABasicAnimation {

        let scaleAnimaton: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimaton.duration = pulseAnimationDuration / 2
        scaleAnimaton.autoreverses = true
        scaleAnimaton.fromValue = NSNumber(value: 1)
        scaleAnimaton.toValue = NSNumber(value: 3)

        return scaleAnimaton
    }

    func opacityAnimation() -> CAKeyframeAnimation {

        let opacityAnimiation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimiation.duration = pulseAnimationDuration
        opacityAnimiation.values = [0.4, 0.8, 0.4]
        opacityAnimiation.keyTimes = [0, NSNumber(value: pulseAnimationDuration / 2), NSNumber(value: pulseAnimationDuration)]

        return opacityAnimiation
    }
}
