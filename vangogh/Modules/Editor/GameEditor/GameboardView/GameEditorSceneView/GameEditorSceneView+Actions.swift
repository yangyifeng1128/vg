///
/// GameEditorSceneView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension GameEditorSceneView {

    @objc func tap() {

        UISelectionFeedbackGenerator().selectionChanged()

        delegate?.sceneViewDidTap(self)
    }

    @objc func pan(_ sender: UIPanGestureRecognizer) {

        guard let view = sender.view else { return }

        switch sender.state {

        case .began:
            break

        case .changed:

            // 对齐网格

            let location: CGPoint = sender.location(in: superview)
            let gridWidth: CGFloat = GameEditorViewController.VC.gameboardViewGridWidth
            let snappedLocation: CGPoint = CGPoint(x: gridWidth * floor(location.x / gridWidth), y: gridWidth * floor(location.y / gridWidth))

            if view.center != snappedLocation {

                UISelectionFeedbackGenerator().selectionChanged() // 震动反馈

                view.center = snappedLocation
                scene.center = view.center
                delegate?.sceneViewIsMoving(scene: scene) // 传递 scene 对象的引用给 delegate，然后在 delegate 中矫正 scene.center
            }
            break

        case .ended:

            view.center = scene.center // 移动结束后，scene.center 已经在 delegate 中完成了矫正，这时候就可以回写给 view.center 了
            delegate?.sceneViewDidPan(scene: scene)
            break

        default:
            break
        }
    }

    @objc func longPress(_ sender: UILongPressGestureRecognizer) {

        if isActive && sender.state == .began { // 处于激活状态且长按开始时，才会触发操作
            delegate?.sceneViewDidLongPress(self)
        }
    }
}

extension GameEditorSceneView {

    /// 激活
    func activate() {

        cornerRadius = 12
        bounds = CGRect(origin: .zero, size: CGSize(width: VC.width * 1.167, height: VC.height * 1.125))

        // 添加边框

        if borderLayer != nil {
            borderLayer.removeFromSuperlayer()
            borderLayer = nil
        }

        borderLayer = CAShapeLayer()
        borderLayer.lineWidth = 8
        borderLayer.strokeColor = UIColor.accent?.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.frame = bounds
        borderLayer.path = maskLayer.path

        layer.addSublayer(borderLayer)

        // 高亮

        highlight()
    }

    /// 取消激活
    func deactivate() {

        cornerRadius = GVC.defaultViewCornerRadius
        bounds = CGRect(origin: .zero, size: CGSize(width: VC.width, height: VC.height))

        // 删除边框

        if borderLayer != nil {
            borderLayer.removeFromSuperlayer()
            borderLayer = nil
        }

        // 取消高亮

        unhighlight()
    }

    /// 高亮
    func highlight() {

        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .white
    }

    /// 取消高亮
    func unhighlight() {

        titleLabel.backgroundColor = VC.maskBackgroundColor
        titleLabel.textColor = .lightText
    }
}
