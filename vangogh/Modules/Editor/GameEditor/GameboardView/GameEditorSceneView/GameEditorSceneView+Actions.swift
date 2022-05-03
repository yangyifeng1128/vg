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
            let gridWidth: CGFloat = GameEditorGameboardView.VC.gridWidth
            let girdSnappedLocation: CGPoint = CGPoint(x: gridWidth * floor(location.x / gridWidth), y: gridWidth * floor(location.y / gridWidth))

            if view.center != girdSnappedLocation {

                // 震动反馈

                UISelectionFeedbackGenerator().selectionChanged()

//                view.center = girdSnappedLocation
//                scene.center = view.center

//                delegate?.sceneViewIsMoving(scene: scene) // 传递 scene 对象的引用给 delegate，然后在 delegate 中矫正 scene.center

                // 移动「场景视图」到作品板边缘时，停止移动

//                var location: CGPoint = scene.center
                var edgeSnappedLocation: CGPoint = girdSnappedLocation

                let minX: CGFloat = GameEditorSceneView.VC.width
                let maxX: CGFloat = GameEditorGameboardView.VC.contentViewWidth - GameEditorSceneView.VC.width
                if edgeSnappedLocation.x < minX {
                    edgeSnappedLocation.x = minX
                } else if location.x > maxX {
                    edgeSnappedLocation.x = maxX
                }

                let minY: CGFloat = GameEditorSceneView.VC.height
                let maxY: CGFloat = GameEditorGameboardView.VC.contentViewHeight - GameEditorSceneView.VC.height
                if edgeSnappedLocation.y < minY {
                    edgeSnappedLocation.y = minY
                } else if location.y > maxY {
                    edgeSnappedLocation.y = maxY
                }

                // 最终确定「场景视图」中心位置

                if view.center != edgeSnappedLocation {

                    view.center = edgeSnappedLocation
                    scene.center = edgeSnappedLocation
                }
            }
            break

        case .ended:

//            view.center = scene.center // 移动结束后，scene.center 已经在 delegate 中完成了矫正，这时候就可以回写给 view.center 了
            delegate?.sceneViewDidPan(scene: scene)
            break

        default:
            break
        }
    }
}

extension GameEditorSceneView {

    /// 更新「标题标签」文本
    func updateTitleLabelAttributedText() {

        titleLabel.attributedText = prepareTitleLabelAttributedText()
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 3
        titleLabel.lineBreakMode = .byTruncatingTail
    }


    /// 准备「标题标签」文本
    func prepareTitleLabelAttributedText() -> NSMutableAttributedString {

        let completeTitleString: NSMutableAttributedString = NSMutableAttributedString(string: "")

        // 准备场景索引

        let indexStringAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: VC.titleLabelLargeFontSize, weight: .regular)]
        let indexString: NSAttributedString = NSAttributedString(string: scene.index.description, attributes: indexStringAttributes)
        completeTitleString.append(indexString)

        // 准备场景标题

        let titleStringAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: VC.titleLabelSmallFontSize, weight: .regular)]
        var titleString: NSAttributedString
        if let title = scene.title, !title.isEmpty {
            titleString = NSAttributedString(string: "\n" + title, attributes: titleStringAttributes)
            completeTitleString.append(titleString)
        }

        // 准备段落样式

        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        completeTitleString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, completeTitleString.length))

        return completeTitleString
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
