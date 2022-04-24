///
/// SceneEmulatorProgressBarView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class SceneEmulatorProgressBarView: UIView {

    private var maskLayer: CAShapeLayer!

    init() {

        super.init(frame: .zero)

        // 初始化视图

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {

        isUserInteractionEnabled = false
        layer.backgroundColor = GVC.defaultSceneControlBackgroundColor.cgColor

        maskLayer = CAShapeLayer()
        layer.mask = maskLayer
    }

    override func draw(_ rect: CGRect) {

        super.draw(rect)

        let maskRect = CGRect(origin: CGPoint(x: 0, y: (SceneEmulatorProgressView.VC.barHeight - SceneEmulatorProgressView.VC.visibleBarHeight) / 2), size: CGSize(width: rect.width, height: SceneEmulatorProgressView.VC.visibleBarHeight))
        maskLayer.path = UIBezierPath(roundedRect: maskRect, cornerRadius: SceneEmulatorProgressView.VC.visibleBarHeight / 2).cgPath
    }
}
