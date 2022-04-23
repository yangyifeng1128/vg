///
/// NodeItemBackgroundView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class NodeItemBackgroundView: UIView {

    private var highlightLayer: CAGradientLayer!
    private var isExpanding: Bool = false
    private var withLeftEar: Bool = false

    override var bounds: CGRect {
        set {
            super.bounds = newValue
            if isExpanding {
                highlight(withLeftEar: withLeftEar)
            }
        }
        get {
            return super.bounds
        }
    }

    init() {

        super.init(frame: .zero)

        backgroundColor = .mgLabel
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }
}

extension NodeItemBackgroundView {

    func highlight(withLeftEar: Bool) {

        isExpanding = true
        self.withLeftEar = withLeftEar

        if highlightLayer != nil {
            highlightLayer.removeFromSuperlayer()
            highlightLayer = nil
        }

        highlightLayer = CAGradientLayer()
        let startColor: CGColor = UIColor.accent!.cgColor
        let endColor: CGColor = UIColor.white.cgColor
        highlightLayer.colors = withLeftEar ? [startColor, endColor] : [endColor, startColor]
        highlightLayer.startPoint = CGPoint(x: 0, y: 0.5)
        highlightLayer.endPoint = CGPoint(x: 1, y: 0.5)
        highlightLayer.frame = bounds

        layer.addSublayer(highlightLayer)
    }

    func unhighlight() {

        isExpanding = false
        withLeftEar = false

        if highlightLayer != nil {
            highlightLayer.removeFromSuperlayer()
            highlightLayer = nil
        }
    }
}
