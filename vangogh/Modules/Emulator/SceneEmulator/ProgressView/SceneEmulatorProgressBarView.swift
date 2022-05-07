///
/// SceneEmulatorProgressBarView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class SceneEmulatorProgressBarView: UIView {

    private var maskLayer: CAShapeLayer!

    /// 初始化
    init() {

        super.init(frame: .zero)

        isUserInteractionEnabled = false
        layer.backgroundColor = GVC.defaultSceneControlBackgroundColor.cgColor

        maskLayer = CAShapeLayer()
        layer.mask = maskLayer
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 重写绘制视图方法
    override func draw(_ rect: CGRect) {

        super.draw(rect)

        let maskRect = CGRect(origin: CGPoint(x: 0, y: (SceneEmulatorProgressView.VC.barHeight - SceneEmulatorProgressView.VC.visibleBarHeight) / 2), size: CGSize(width: rect.width, height: SceneEmulatorProgressView.VC.visibleBarHeight))
        maskLayer.path = UIBezierPath(roundedRect: maskRect, cornerRadius: SceneEmulatorProgressView.VC.visibleBarHeight / 2).cgPath
    }
}
