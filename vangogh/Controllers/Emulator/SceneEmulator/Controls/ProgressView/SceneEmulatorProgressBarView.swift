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

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {

        isUserInteractionEnabled = false
        layer.backgroundColor = GlobalViewLayoutConstants.defaultSceneControlBackgroundColor.cgColor

        maskLayer = CAShapeLayer()
        layer.mask = maskLayer
    }

    override func draw(_ rect: CGRect) {

        super.draw(rect)

        let maskRect = CGRect(origin: CGPoint(x: 0, y: (SceneEmulatorProgressView.ViewLayoutConstants.barHeight - SceneEmulatorProgressView.ViewLayoutConstants.visibleBarHeight) / 2), size: CGSize(width: rect.width, height: SceneEmulatorProgressView.ViewLayoutConstants.visibleBarHeight))
        maskLayer.path = UIBezierPath(roundedRect: maskRect, cornerRadius: SceneEmulatorProgressView.ViewLayoutConstants.visibleBarHeight / 2).cgPath
    }
}
