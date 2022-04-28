///
/// GameEditorTransitionView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension GameEditorTransitionView {

    /// 更新视图
    func updateView() {

        layer.sublayers?.removeAll()

        let arrow = UIBezierPath.arrow2(from: startScene.center, to: endScene.center, tailWidth: VC.tailWidth, headWidth: VC.headWidth, headLength: VC.headLength)

        let arrowLayer = CAShapeLayer()
        arrowLayer.fillColor = arrowLayerColor
        arrowLayer.path = arrow.cgPath

        layer.addSublayer(arrowLayer)
    }

    /// 高亮
    func highlight(isSent: Bool) {

        arrowLayerColor = isSent ? UIColor.accent?.cgColor : UIColor.fcGreen?.cgColor
        updateView()

        startPulseAnimating(isSent: isSent)
    }

    /// 取消高亮
    func unhighlight() {

        arrowLayerColor = UIColor.tertiaryLabel.cgColor
        updateView()

        stopPulseAnimating()
    }

    /// 开启脉冲动画
    func startPulseAnimating(isSent: Bool) {

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
        pulseAnimationGroup.animations = [initPositionAnimation(), initScaleAnimation(), initOpacityAnimation()]
        pulseAnimationLayer.add(pulseAnimationGroup, forKey: "pulse")

        layer.addSublayer(pulseAnimationLayer)
    }

    /// 关闭脉冲动画
    func stopPulseAnimating() {

        if pulseAnimationLayer != nil {
            pulseAnimationLayer.removeFromSuperlayer()
            pulseAnimationLayer = nil
            pulseAnimationGroup = nil
        }
    }

    /// 初始化位移动画
    private func initPositionAnimation() -> CABasicAnimation {

        let positionAnimaton: CABasicAnimation = CABasicAnimation(keyPath: "position")
        positionAnimaton.duration = pulseAnimationDuration
        positionAnimaton.fromValue = [startScene.center.x, startScene.center.y]
        positionAnimaton.toValue = [endScene.center.x, endScene.center.y]

        return positionAnimaton
    }

    /// 初始化缩放动画
    private func initScaleAnimation() -> CABasicAnimation {

        let scaleAnimaton: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimaton.duration = pulseAnimationDuration / 2
        scaleAnimaton.autoreverses = true
        scaleAnimaton.fromValue = NSNumber(value: 1)
        scaleAnimaton.toValue = NSNumber(value: 3)

        return scaleAnimaton
    }

    /// 初始化透明度动画
    private func initOpacityAnimation() -> CAKeyframeAnimation {

        let opacityAnimiation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimiation.duration = pulseAnimationDuration
        opacityAnimiation.values = [0.4, 0.8, 0.4]
        opacityAnimiation.keyTimes = [0, NSNumber(value: pulseAnimationDuration / 2), NSNumber(value: pulseAnimationDuration)]

        return opacityAnimiation
    }
}
