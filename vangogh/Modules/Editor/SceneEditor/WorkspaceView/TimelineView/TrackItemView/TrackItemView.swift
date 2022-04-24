///
/// TrackItemView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import CoreMedia
import SnapKit
import UIKit

protocol TrackItemViewDelegate: AnyObject {
    func trackItemViewWillBeginExpanding(footage: MetaFootage)
    func trackItemViewDidExpand(expandedWidth: CGFloat, edgeX: CGFloat, withLeftEar: Bool)
    func trackItemViewDidEndExpanding(footage: MetaFootage, cursorTimeOffsetMilliseconds: Int64)
}

class TrackItemView: UIView {

    /// 视图布局常量枚举值
    enum VC {
        static let height: CGFloat = 64
    }

    weak var delegate: TrackItemViewDelegate?

    private var leftEarView: TrackItemEarView!
    private var rightEarView: TrackItemEarView!
    private var backgroundView: TrackItemBackgroundView!
    var contentView: TrackItemContentView!

    var width: CGFloat {
        return contentView.width + GVC.timelineItemEarViewWidth * 2
    } // 视图宽度
    var isActive: Bool = false { // 激活状态
        willSet {
            if newValue {
                activate() // 激活
            } else {
                deactivate() // 取消激活
            }
        }
    }

    private var panGesturePreviousTranslation: CGPoint = .zero
    private var panGestureAutoScrollScreenEdgeInset: CGFloat = 64
    private var withLeftEar: Bool = false

    var footage: MetaFootage!

    init(footage: MetaFootage) {

        super.init(frame: .zero)

        self.footage = footage

        // 初始化视图

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {

        // 初始化左执耳视图

        leftEarView = TrackItemEarView()
        leftEarView.isHidden = true
        leftEarView.isUserInteractionEnabled = true
        leftEarView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(earViewDidPan)))
        addSubview(leftEarView)
        leftEarView.snp.makeConstraints { make -> Void in
            make.width.equalTo(GVC.timelineItemEarViewWidth)
            make.height.equalToSuperview()
            make.left.top.equalToSuperview()
        }

        // 初始化右执耳视图

        rightEarView = TrackItemEarView(direction: .right)
        rightEarView.isHidden = true
        rightEarView.isUserInteractionEnabled = true
        rightEarView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(earViewDidPan)))
        addSubview(rightEarView)

        // 初始化背景视图

        backgroundView = TrackItemBackgroundView()
        backgroundView.isHidden = true
        addSubview(backgroundView)
    }
}

extension TrackItemView {

    func updateContentView(_ contentView: TrackItemContentView) {

        // 移除先前的内容视图

        if let previousContentView = self.contentView {
            previousContentView.removeFromSuperview()
        }

        // 添加新的内容视图并调整相关视图的布局

        self.contentView = contentView
        addSubview(contentView)
        contentView.snp.makeConstraints { make -> Void in
            make.width.equalTo(contentView.width)
            make.height.equalTo(TrackItemContentView.VC.height)
            make.centerY.equalToSuperview()
            make.left.equalTo(leftEarView.snp.right)
        }

        rightEarView.snp.remakeConstraints { make -> Void in
            make.width.equalTo(GVC.timelineItemEarViewWidth)
            make.height.equalToSuperview()
            make.left.equalTo(contentView.snp.right)
        }

        backgroundView.snp.remakeConstraints { make -> Void in
            make.width.equalTo(contentView.width)
            make.height.equalToSuperview()
            make.left.equalTo(contentView.snp.left)
            make.top.equalToSuperview()
        }
        sendSubviewToBack(backgroundView)
    }
}

extension TrackItemView {

    @objc private func earViewDidPan(_ sender: UIPanGestureRecognizer) {

        // 开始操作

        if sender.state == .began {

            // 判断当前拖拽的是左执耳还是右执耳视图

            if sender.view == leftEarView {
                withLeftEar = true
                highlight(withLeftEar: true)
            } else {
                withLeftEar = false
                highlight(withLeftEar: false)
            }

            delegate?.trackItemViewWillBeginExpanding(footage: footage)
        }

        // 自动扩展

        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        guard let panGestureView = sender.view, let locationInWindow = panGestureView.superview?.convert(panGestureView.center, to: window) else { return }

        if (locationInWindow.x < panGestureAutoScrollScreenEdgeInset && panGesturePreviousTranslation.x < 0) || (locationInWindow.x > window.bounds.width - panGestureAutoScrollScreenEdgeInset && panGesturePreviousTranslation.x > 0) {
            autoExpand()
        }

        // 手动扩展

        let panGestureTranslation: CGPoint = sender.translation(in: sender.view)
        let translationOffsetX: CGFloat = (panGestureTranslation.x - panGesturePreviousTranslation.x).rounded() // 横向变换偏移量
        var expandedWidth: CGFloat = 0 // 扩展宽度
        var edgeX: CGFloat = 0 // 边缘位置

        if withLeftEar {
            (expandedWidth, edgeX) = expand(translationOffsetX: translationOffsetX, withLeftEar: true)
            panGesturePreviousTranslation.x -= expandedWidth
            delegate?.trackItemViewDidExpand(expandedWidth: expandedWidth, edgeX: edgeX, withLeftEar: true)
        } else {
            (expandedWidth, edgeX) = expand(translationOffsetX: translationOffsetX, withLeftEar: false)
            panGesturePreviousTranslation.x += expandedWidth
            delegate?.trackItemViewDidExpand(expandedWidth: expandedWidth, edgeX: edgeX, withLeftEar: false)
        }

        // 结束操作

        if sender.state == .ended || sender.state == .cancelled {

            panGesturePreviousTranslation = .zero

            contentView.relocateTimeRange(withLeftEar: withLeftEar)

            let previousFootageDurationMilliseconds: Int64 = footage.durationMilliseconds
            footage.leftMarkTimeMilliseconds = contentView.leftMarkTime.milliseconds()
            footage.durationMilliseconds = CMTimeSubtract(contentView.rightMarkTime, contentView.leftMarkTime).milliseconds()
            let cursorTimeOffsetMilliseconds: Int64 = withLeftEar ? footage.durationMilliseconds - previousFootageDurationMilliseconds: 0
            delegate?.trackItemViewDidEndExpanding(footage: footage, cursorTimeOffsetMilliseconds: cursorTimeOffsetMilliseconds)

            unhighlight(withLeftEar: withLeftEar)
        }
    }

    private func autoExpand() {

        print("[TrackItem] trackItemView \"\(footage.uuid)\" did expand automatically")
    }

    private func expand(translationOffsetX: CGFloat, withLeftEar: Bool) -> (CGFloat, CGFloat) {

        let previousContentViewWidth: CGFloat = contentView.width
        let previousOriginX: CGFloat = frame.origin.x.rounded()
        contentView.expand(translationOffsetX: translationOffsetX, withLeftEar: withLeftEar)
        let expandedWidth: CGFloat = (contentView.width - previousContentViewWidth).rounded()

        // 更新布局

        contentView.snp.updateConstraints { make -> Void in
            make.width.equalTo(contentView.width)
        }
        backgroundView.snp.updateConstraints { make -> Void in
            make.width.equalTo(contentView.width)
        }
        snp.updateConstraints { make -> Void in
            make.width.equalTo(width)
        }

        // 获取边缘位置

        let edgeX: CGFloat = withLeftEar ? (previousOriginX - expandedWidth).rounded() : (previousOriginX - expandedWidth + width).rounded()

        return (expandedWidth, edgeX)
    }
}

extension TrackItemView {

    private func activate() {

        if let leftEarView = leftEarView {
            leftEarView.isHidden = false
        }
        if let rightEarView = rightEarView {
            rightEarView.isHidden = false
        }
        if let backgroundView = backgroundView {
            backgroundView.isHidden = false
        }
    }

    private func deactivate() {

        if let leftEarView = leftEarView {
            leftEarView.isHidden = true
        }
        if let rightEarView = rightEarView {
            rightEarView.isHidden = true
        }
        if let backgroundView = backgroundView {
            backgroundView.isHidden = true
        }
    }

    private func highlight(withLeftEar: Bool) {

        if withLeftEar {
            leftEarView.highlight()
        } else {
            rightEarView.highlight()
        }
        backgroundView.highlight(withLeftEar: withLeftEar)
    }

    private func unhighlight(withLeftEar: Bool) {

        if withLeftEar {
            leftEarView.unhighlight()
        } else {
            rightEarView.unhighlight()
        }
        backgroundView.unhighlight()
    }
}
