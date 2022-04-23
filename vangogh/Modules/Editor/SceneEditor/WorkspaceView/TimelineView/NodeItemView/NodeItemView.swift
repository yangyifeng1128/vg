///
/// NodeItemView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import CoreMedia
import SnapKit
import UIKit

protocol NodeItemViewDelegate: AnyObject {
    func nodeItemViewWillBeginExpanding(node: MetaNode)
    func nodeItemViewDidExpand(node: MetaNode, expandedWidth: CGFloat, edgeX: CGFloat, withLeftEar: Bool)
    func nodeItemViewDidEndExpanding(node: MetaNode)
}

class NodeItemView: UIView {

    weak var delegate: NodeItemViewDelegate?

    var barView: NodeItemBarView!
    private var curveView: NodeItemCurveView!
    private var connectorView: UIView!

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
    private var panGestureAutoScrollScreenEdgeInset: CGFloat = 32
    private var withLeftEar: Bool = false

    private(set) var node: MetaNode!

    init(node: MetaNode) {

        super.init(frame: .zero)

        self.node = node

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {

        isUserInteractionEnabled = true
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(earViewDidPan)))

        // 初始化 curveView

        curveView = NodeItemCurveView(nodeType: node.nodeType)
        addSubview(curveView)
        curveView.snp.makeConstraints { make -> Void in
            make.width.equalTo(0) // 以备后续更新
            make.height.equalTo(NodeItemCurveView.ViewLayoutConstants.height)
            make.left.equalToSuperview().offset(GlobalViewLayoutConstants.timelineItemEarViewWidth)
            make.bottom.equalToSuperview()
        }

        // 初始化 barView

        barView = NodeItemBarView(nodeType: node.nodeType)
        barView.isHidden = true
        addSubview(barView)
        barView.snp.makeConstraints { make -> Void in
            make.width.equalTo(0) // 以备后续更新
            make.height.equalTo(NodeItemBarView.ViewLayoutConstants.height)
            make.left.equalToSuperview()
            make.bottom.equalTo(curveView.snp.top).offset(NodeItemCurveView.ViewLayoutConstants.lineWidth / 2)
        }

        // 初始化 connectorView

        connectorView = UIView()
        connectorView.isHidden = true
        connectorView.backgroundColor = .mgLabel
        addSubview(connectorView)
        connectorView.snp.makeConstraints { make -> Void in
            make.width.equalTo(NodeItemCurveView.ViewLayoutConstants.lineWidth)
            make.height.equalTo(NodeItemCurveView.ViewLayoutConstants.height - 6)
            make.left.equalTo(GlobalViewLayoutConstants.timelineItemEarViewWidth - NodeItemCurveView.ViewLayoutConstants.lineWidth / 2)
            make.bottom.equalToSuperview().offset(-3)
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        // 非激活状态下的组件项视图不响应任何事件，交由其父视图去处理

        let hitView: UIView? = super.hitTest(point, with: event)
        if hitView == self && !isActive {
            return nil
        } else {
            return hitView
        }
    }
}

extension NodeItemView {

    func updateContentView(_ contentView: NodeItemContentView) {

        // 更新 barView

        barView.updateContentView(contentView)

        // 更新 curveView

        curveView.snp.updateConstraints { make -> Void in
            make.width.equalTo(contentView.width)
        }
    }
}

extension NodeItemView {

    @objc private func earViewDidPan(_ sender: UIPanGestureRecognizer) {

        // 仅适用于激活状态下的组件项视图

        guard let nodeItemView = sender.view as? NodeItemView, nodeItemView.isActive else { return }

        // 开始操作

        if sender.state == .began {

            // 判断当前拖拽的是左执耳还是右执耳视图

            let location: CGPoint = sender.location(in: sender.view)
            if location.x <= bounds.width / 2 {
                withLeftEar = true
                highlight(withLeftEar: withLeftEar)
            } else {
                withLeftEar = false
                highlight(withLeftEar: withLeftEar)
            }

            delegate?.nodeItemViewWillBeginExpanding(node: node)
        }

        // 自动扩展

        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        guard let panGestureView = withLeftEar ? barView.leftEarView : barView.rightEarView, let locationInWindow = panGestureView.superview?.convert(panGestureView.center, to: window) else { return }

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
            delegate?.nodeItemViewDidExpand(node: node, expandedWidth: expandedWidth, edgeX: edgeX, withLeftEar: true)
        } else {
            (expandedWidth, edgeX) = expand(translationOffsetX: translationOffsetX, withLeftEar: false)
            panGesturePreviousTranslation.x += expandedWidth
            delegate?.nodeItemViewDidExpand(node: node, expandedWidth: expandedWidth, edgeX: edgeX, withLeftEar: false)
        }

        // 结束操作

        if sender.state == .ended || sender.state == .cancelled {

            panGesturePreviousTranslation = .zero

            node.startTimeMilliseconds = barView.contentView.startTime.milliseconds()
            node.durationMilliseconds = CMTimeSubtract(barView.contentView.endTime, barView.contentView.startTime).milliseconds()
            delegate?.nodeItemViewDidEndExpanding(node: node)

            unhighlight(withLeftEar: withLeftEar)
        }
    }

    private func autoExpand() {

        print("[NodeItem] nodeItemView \"\(node.uuid)\" did expand automatically")
    }

    private func expand(translationOffsetX: CGFloat, withLeftEar: Bool) -> (CGFloat, CGFloat) {

        let previousContentViewWidth: CGFloat = barView.contentView.width
        let previousOriginX: CGFloat = frame.origin.x.rounded()
        barView.contentView.expand(translationOffsetX: translationOffsetX, withLeftEar: withLeftEar)
        let expandedWidth: CGFloat = (barView.contentView.width - previousContentViewWidth).rounded()

        if expandedWidth != 0 { // 重要！保证左标拖拽效果

            // 更新布局

            barView.contentView.snp.updateConstraints { make -> Void in
                make.width.equalTo(barView.contentView.width)
            }
            barView.backgroundView.snp.updateConstraints { make -> Void in
                make.width.equalTo(barView.contentView.width)
            }
            barView.snp.updateConstraints { make -> Void in
                make.width.equalTo(barView.width)
            }
            curveView.snp.updateConstraints { make -> Void in
                make.width.equalTo(barView.contentView.width)
            }

            if withLeftEar {

                // 拖拽左执耳视图并向左滑动时，保证位置不会小于零

                var originX: CGFloat = (previousOriginX - expandedWidth).rounded()
                if barView.contentView.startTime == .zero {
                    originX = 0
                }

                // 更新布局

                snp.updateConstraints { make -> Void in
                    make.left.equalTo(originX)
                    make.width.equalTo(barView.width)
                }

            } else {

                // 更新布局

                snp.updateConstraints { make -> Void in
                    make.width.equalTo(barView.width)
                }
            }
        }

        // 获取边缘位置

        let edgeX: CGFloat = withLeftEar ? (previousOriginX - expandedWidth).rounded() : (previousOriginX - expandedWidth + barView.width).rounded()

        return (expandedWidth, edgeX)
    }
}

extension NodeItemView {

    private func activate() {

        barView.isHidden = false
        curveView.isHidden = true
        connectorView.isHidden = false
    }

    private func deactivate() {

        barView.isHidden = true
        curveView.isHidden = false
        connectorView.isHidden = true
    }

    private func highlight(withLeftEar: Bool) {

        if withLeftEar {
            barView.leftEarView.highlight()
        } else {
            barView.rightEarView.highlight()
        }
        barView.backgroundView.highlight(withLeftEar: withLeftEar)
    }

    private func unhighlight(withLeftEar: Bool) {

        if withLeftEar {
            barView.leftEarView.unhighlight()
        } else {
            barView.rightEarView.unhighlight()
        }
        barView.backgroundView.unhighlight()
    }
}
