///
/// TimelineMeasureView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit
import CoreMedia

class TimelineMeasureView: UIView {

    /// 视图布局常量枚举值
    enum VC {
        static let height: CGFloat = 24
        static let markWidth: CGFloat = 1
        static let majorMarkHeight: CGFloat = 8
        static let majorMarkTimeStringFontSize: CGFloat = 10
        static let minorMarkHeight: CGFloat = 4
    }

    private var measureLayer: TimelineMeasureLayer!

    init() {

        super.init(frame: .zero)

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 重写布局子视图方法
    override func layoutSubviews() {

        addMeasureLayer()
    }

    /// 重写用户界面风格变化处理方法
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)

        addMeasureLayer()
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = .clear
    }

    private func addMeasureLayer() {

        if measureLayer != nil {
            measureLayer.removeFromSuperlayer()
            measureLayer = nil
        }

        measureLayer = TimelineMeasureLayer()
        measureLayer.frame = bounds
        layer.addSublayer(measureLayer)
    }
}

class TimelineMeasureLayer: CALayer {

    private var minorMark: TimelineMeasureMark = {
        return TimelineMeasureMark(size: CGSize(width: TimelineMeasureView.VC.markWidth, height: TimelineMeasureView.VC.minorMarkHeight), color: .darkGray)
    }()
    private var majorMark: TimelineMeasureMark = {
        return TimelineMeasureMark(size: CGSize(width: TimelineMeasureView.VC.markWidth, height: TimelineMeasureView.VC.majorMarkHeight), color: .gray)
    }()

    override var frame: CGRect {
        didSet { // frame 改变时需要重绘图层
            setNeedsDisplay()
        }
    }

    //
    //
    // MARK: - 重绘图层
    //
    //

    override func display() {

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        drawToImage()
        CATransaction.commit()
    }

    private func drawToImage() {

        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return
        }

        let measureLayerWidth: CGFloat = bounds.width - UIScreen.main.bounds.width
        let totalMarkCount: Int = Int(ceil(measureLayerWidth / GVC.defaultTimelineItemWidthPerSecond))

        for i in 0...totalMarkCount {

            let markOffsetX: CGFloat = GVC.defaultTimelineItemWidthPerSecond * CGFloat(i) + GVC.timelineItemEarViewWidth
            let markOrigin: CGPoint = CGPoint(x: markOffsetX - TimelineMeasureView.VC.markWidth / 2, y: 0)

            let mark: TimelineMeasureMark = (i % 5 == 0) ? majorMark : minorMark

            let rect: CGRect = CGRect(origin: markOrigin, size: mark.size)
            context.setFillColor(mark.color.cgColor)
            context.fill(rect)

            if i % 5 == 0 {
                let timeString: String = CMTimeMakeWithSeconds(Double(i), preferredTimescale: GVC.preferredTimescale).toString()
                let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.gray, .font: UIFont.systemFont(ofSize: TimelineMeasureView.VC.majorMarkTimeStringFontSize, weight: .regular)]
                let attributedString: NSAttributedString = NSAttributedString(string: timeString, attributes: attributes)
                let attributedStringSize: CGSize = attributedString.size()
                let attributedStringOrigin: CGPoint = CGPoint(x: markOffsetX - attributedStringSize.width / 2, y: rect.maxY + 2)
                let attributedStringRect: CGRect = CGRect(origin: attributedStringOrigin, size: attributedStringSize)
                let nsTimeString: NSString = timeString as NSString
                nsTimeString.draw(in: attributedStringRect, withAttributes: attributes)
            }
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        contents = image?.cgImage
    }
}

class TimelineMeasureMark {

    private(set) var size: CGSize
    private(set) var color: UIColor

    init(size: CGSize, color: UIColor) {

        self.size = size
        self.color = color
    }
}
