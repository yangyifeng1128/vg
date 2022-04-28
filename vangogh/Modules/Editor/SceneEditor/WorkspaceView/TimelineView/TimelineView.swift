///
/// TimelineView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVFoundation
import SnapKit
import UIKit

protocol TimelineViewDelegate: AnyObject {
    func timelineViewDidTap()
    func timelineViewWillBeginScrolling()
    func timelineViewDidEndScrolling(to time: CMTime, decelerate: Bool)
    func trackItemViewDidBecomeActive(footage: MetaFootage)
    func trackItemViewWillBeginExpanding(footage: MetaFootage)
    func trackItemViewDidEndExpanding(footage: MetaFootage, cursorTimeOffsetMilliseconds: Int64)
    func nodeItemViewDidBecomeActive(node: MetaNode)
    func nodeItemViewDidResignActive(node: MetaNode)
    func nodeItemViewWillBeginExpanding(node: MetaNode)
    func nodeItemViewDidEndExpanding(node: MetaNode)
    func nodeItemViewWillBeginEditing(node: MetaNode)
    func newFootageButtonDidTap()
}

class TimelineView: UIView {

    /// 视图布局常量枚举值
    enum VC {
        static let bottomViewContainerHeight: CGFloat = 64
        static let newFootageButtonWidth: CGFloat = 40
        static let newFootageButtonImageEdgeInset: CGFloat = 8
        static let nodeItemTagViewContainerBottomOffset: CGFloat = 16
    }

    /// 时间线底部视图类型枚举值
    enum TimelineBottomViewType {
        case timeline
        case trackItem
        case nodeItem
    }

    /// 代理
    weak var delegate: TimelineViewDelegate?

    private var bottomViewContainer: UIView!
    var timelineToolBarView: TimelineToolBarView!
    var trackItemBottomBarView: TrackItemBottomBarView!
    var nodeItemBottomBarView: NodeItemBottomBarView!

    private var contentViewContainer: UIScrollView!
    private var contentView: UIView!
    private var measureView: TimelineMeasureView!
    private var trackItemViewContainer: UIView!
    private var trackItemViewList: [TrackItemView] = []
    private var nodeItemViewContainer: UIView!
    private var nodeItemViewList: [NodeItemView] = []
    private var nodeItemTagViewContainer: UIView!
    private var nodeItemTagViewList: [NodeItemTagView] = []

    private var cursorView: TimelineCursorView!
    private var newFootageButton: AddFootageButton!

    /// 内容视图宽度
    private var contentViewWidth: CGFloat = 0 {
        didSet {
            contentView.snp.updateConstraints { make -> Void in
                make.width.equalTo(contentViewWidth)
            }
            contentViewContainer.contentSize = CGSize(width: contentViewWidth, height: .zero)
        }
    }
    /// 轨道项视图容器宽度
    private var trackItemViewContainerWidth: CGFloat = 0 {
        didSet {
            trackItemViewContainer.snp.updateConstraints { make -> Void in
                make.width.equalTo(trackItemViewContainerWidth)
            }
        }
    }
    /// 组件项视图容器宽度
    private var nodeItemViewContainerWidth: CGFloat = 0 {
        didSet {
            nodeItemTagViewContainer.snp.updateConstraints { make -> Void in
                make.width.equalTo(nodeItemViewContainerWidth)
            }
            nodeItemViewContainer.snp.updateConstraints { make -> Void in
                make.width.equalTo(nodeItemViewContainerWidth)
            }
        }
    }
    /// 组件项缩略图视图尺寸
    private var trackItemThumbImageSize: CGSize!

    private var timeline: Timeline!
    private let loadTrackItemContentViewThumbImageQueue: DispatchQueue = DispatchQueue(label: GKC.loadTrackItemContentViewThumbImageQueueIdentifier)

    /// 可用状态
    var isEnabled: Bool = true {
        willSet {
            timelineToolBarView.isUserInteractionEnabled = newValue
            newFootageButton.isEnabled = newValue
        }
    }

    private var currentTimeMilliseconds: Int64 = 0

    /// 初始化
    init(trackItemThumbImageSize: CGSize) {

        self.trackItemThumbImageSize = trackItemThumbImageSize

        super.init(frame: .zero)

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        // 初始化底部视图

        initBottomView()

        // 初始化内容视图

        initContentView()

        // 初始化其他（游标、添加镜头片段）视图

        initMiscView()
    }

    ///
    private func initBottomView() {

        // 初始化底部视图容器

        bottomViewContainer = UIView()
        addSubview(bottomViewContainer)
        bottomViewContainer.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(VC.bottomViewContainerHeight)
            make.left.bottom.equalToSuperview()
        }

        // 初始化工具栏视图

        timelineToolBarView = TimelineToolBarView()
        timelineToolBarView.isHidden = true
        bottomViewContainer.addSubview(timelineToolBarView)
        timelineToolBarView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        // 初始化轨道项底部视图

        trackItemBottomBarView = TrackItemBottomBarView()
        trackItemBottomBarView.isHidden = true
        bottomViewContainer.addSubview(trackItemBottomBarView)
        trackItemBottomBarView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        // 初始化组件项底部视图

        nodeItemBottomBarView = NodeItemBottomBarView()
        nodeItemBottomBarView.isHidden = true
        bottomViewContainer.addSubview(nodeItemBottomBarView)
        nodeItemBottomBarView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        // 重置底部视图

        resetBottomView(bottomViewType: .timeline)
    }

    func resetBottomView(bottomViewType: TimelineBottomViewType, footage: MetaFootage? = nil, node: MetaNode? = nil) {

        switch bottomViewType {

        case .timeline:

            timelineToolBarView.isHidden = false
            bringSubviewToFront(timelineToolBarView)
            trackItemBottomBarView.isHidden = true
            nodeItemBottomBarView.isHidden = true
            break

        case .trackItem:

            guard let footage = footage else { return }
            trackItemBottomBarView.footage = footage
            trackItemBottomBarView.isHidden = false
            bringSubviewToFront(trackItemBottomBarView)
            timelineToolBarView.isHidden = true
            nodeItemBottomBarView.isHidden = true
            break

        case .nodeItem:

            guard let node = node else { return }
            nodeItemBottomBarView.node = node
            nodeItemBottomBarView.isHidden = false
            bringSubviewToFront(nodeItemBottomBarView)
            timelineToolBarView.isHidden = true
            trackItemBottomBarView.isHidden = true
            break
        }
    }

    //
    //
    // MARK: - 初始化内容视图
    //
    //

    private func initContentView() {

        // 初始化内容视图容器

        contentViewContainer = UIScrollView()
        contentViewContainer.delegate = self
        contentViewContainer.showsVerticalScrollIndicator = false
        contentViewContainer.showsHorizontalScrollIndicator = false
        contentViewContainer.isUserInteractionEnabled = true
        contentViewContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentViewContainerDidTap)))
        addSubview(contentViewContainer)
        contentViewContainer.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(bottomViewContainer.snp.top)
        }

        // 初始化内容视图

        contentView = UIView()
        contentViewContainer.addSubview(contentView)
        let contentViewLeftOffset: CGFloat = UIScreen.main.bounds.width / 2 - GVC.timelineItemEarViewWidth
        contentView.snp.makeConstraints { make -> Void in
            make.width.equalTo(0) // 以备后续更新
            make.height.equalToSuperview()
            make.left.equalToSuperview().offset(contentViewLeftOffset)
            make.top.equalToSuperview()
        }

        // 初始化标尺视图

        initMeasureView()

        // 初始化组件项视图

        initNodeItemViews()

        // 初始化轨道项视图

        initTrackItemViews()
    }

    private func initMeasureView() {

        measureView = TimelineMeasureView()
        contentView.addSubview(measureView)
        measureView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(TimelineMeasureView.VC.height)
            make.left.top.equalToSuperview()
        }
    }

    private func initTrackItemViews() {

        // 初始化轨道项视图容器

        trackItemViewContainer = UIView()
        contentView.addSubview(trackItemViewContainer)
        trackItemViewContainer.snp.makeConstraints { make -> Void in
            make.width.equalTo(0) // 以备后续更新
            make.height.equalTo(TrackItemView.VC.height)
            make.left.equalToSuperview()
            make.bottom.equalTo(nodeItemViewContainer.snp.top).offset(-NodeItemCurveView.VC.lineWidth * 2)
        }
    }

    private func initNodeItemViews() {

        // 初始化内容项标签视图容器

        nodeItemTagViewContainer = UIView()
        contentView.addSubview(nodeItemTagViewContainer)
        nodeItemTagViewContainer.snp.makeConstraints { make -> Void in
            make.width.equalTo(0) // 以备后续更新
            make.height.equalTo(NodeItemTagView.VC.height)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview().offset(-VC.nodeItemTagViewContainerBottomOffset)
        }

        // 初始化内容项视图容器

        nodeItemViewContainer = UIView()
        contentView.addSubview(nodeItemViewContainer)
        nodeItemViewContainer.snp.makeConstraints { make -> Void in
            make.width.equalTo(0) // 以备后续更新
            make.height.equalTo(NodeItemCurveView.VC.height)
            make.left.equalToSuperview()
            make.bottom.equalTo(nodeItemTagViewContainer.snp.top)
        }
    }

    //
    //
    // MARK: - 初始化其他（游标、添加镜头片段）视图
    //
    //

    private func initMiscView() {

        // 初始化游标视图

        cursorView = TimelineCursorView()
        addSubview(cursorView)
        cursorView.snp.makeConstraints { make -> Void in
            make.width.equalTo(TimelineCursorView.VC.width)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-VC.bottomViewContainerHeight)
        }

        // 初始化「添加镜头片段」按钮

        newFootageButton = AddFootageButton(imageEdgeInset: VC.newFootageButtonImageEdgeInset)
        newFootageButton.addTarget(self, action: #selector(newFootageButtonDidTap), for: .touchUpInside)
        addSubview(newFootageButton)
        newFootageButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.newFootageButtonWidth)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalTo(trackItemViewContainer).offset(-12)
        }
    }
}

extension TimelineView {

    func updateTrackItemViews(timeline: Timeline, footages: [MetaFootage]) {

        self.timeline = timeline

        // 移除先前的全部轨道项视图

        for trackItemView in trackItemViewList {
            trackItemView.removeFromSuperview()
        }
        trackItemViewList.removeAll()

        // 添加新的轨道项视图

        var leftOffset: CGFloat = 0

        for (i, trackItem) in timeline.videoChannel.enumerated() {

            guard let trackItem = trackItem as? TrackItem else { return }
            let selectedTimeRange: CMTimeRange = trackItem.resource.selectedTimeRange
            let maxDuration: CMTime = CMTimeMake(value: footages[i].maxDurationMilliseconds, timescale: GVC.preferredTimescale)
            let trackItemContentView: TrackItemContentView = TrackItemContentView(footageType: footages[i].footageType, leftMarkTime: selectedTimeRange.start, rightMarkTime: selectedTimeRange.end, thumbImageSize: trackItemThumbImageSize, maxDuration: maxDuration)
            trackItemContentView.loadThumbImageQueue = loadTrackItemContentViewThumbImageQueue
            if let imageGenerator = trackItem.generateFullRangeImageGenerator(size: trackItemContentView.thumbImageSize) {
                trackItemContentView.imageGenerator = CachedImageGenerator.createFrom(imageGenerator)
            }
            let trackItemView: TrackItemView = TrackItemView(footage: footages[i])
            trackItemView.delegate = self
            trackItemView.updateContentView(trackItemContentView)
            trackItemView.isUserInteractionEnabled = true
            trackItemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trackItemViewDidTap)))
            trackItemViewContainer.addSubview(trackItemView)
            trackItemViewList.append(trackItemView)
            trackItemView.snp.makeConstraints { make -> Void in
                make.width.equalTo(trackItemView.width)
                make.height.equalToSuperview()
                if i > 0 {
                    make.left.equalTo(trackItemViewList[i - 1].snp.right).offset(-GVC.timelineItemEarViewWidth * 2)
                } else {
                    make.left.equalToSuperview()
                }
                make.top.equalToSuperview()
            }

            leftOffset += trackItemView.contentView.width
        }

        // 调整父视图及其他相关视图的布局

        contentViewContainer.layoutIfNeeded()

        // 更新轨道项视图容器的宽度

        trackItemViewContainerWidth = leftOffset + GVC.timelineItemEarViewWidth * 2

        // 更新内容视图容器的宽度
        // FIXME：根据 trackItemViewContainerWidth 和 nodeItemViewContainerWidth 更新 contentViewWidth

        // contentViewWidth = UIScreen.main.bounds.width + max(trackItemViewContainerWidth, nodeItemViewContainerWidth) - GVC.timelineItemEarViewWidth * 2

        contentViewWidth = UIScreen.main.bounds.width + trackItemViewContainerWidth - GVC.timelineItemEarViewWidth * 2

        // 更新「添加镜头片段」按钮的布局

        newFootageButton.snp.updateConstraints { make -> Void in
            make.right.equalToSuperview().offset(-12)
        }

        // 更新当前屏幕可视范围内的轨道项视图的缩略图视图

        visibleTrackItemViewList().forEach { $0.contentView.updateThumbImageViews() }
    }

    private func visibleTrackItemViewList() -> [TrackItemView] {

        // 获取当前屏幕可视范围内的轨道项视图

        var list: [TrackItemView] = [TrackItemView]()

        for trackItemView in trackItemViewList {

            if let parent = trackItemView.superview {
                let rect: CGRect = parent.convert(trackItemView.frame, to: contentViewContainer)
                if contentViewContainer.bounds.intersects(rect) {
                    list.append(trackItemView)
                }
            }
        }

        return list
    }
}

extension TimelineView: TrackItemViewDelegate {

    func trackItemViewWillBeginExpanding(footage: MetaFootage) {

        // 先移除滚动代理

        contentViewContainer.delegate = nil

        // 完成操作

        delegate?.trackItemViewWillBeginExpanding(footage: footage)
    }

    func trackItemViewDidExpand(expandedWidth: CGFloat, edgeX: CGFloat, withLeftEar: Bool) {

        // 更新轨道项视图容器宽度

        trackItemViewContainerWidth += expandedWidth

        // 更新内容视图容器的宽度
        // FIXME：根据 trackItemViewContainerWidth 和 nodeItemViewContainerWidth 更新 contentViewWidth

        // contentViewWidth = UIScreen.main.bounds.width + max(trackItemViewContainerWidth, nodeItemViewContainerWidth) - GVC.timelineItemEarViewWidth * 2

        contentViewWidth = UIScreen.main.bounds.width + trackItemViewContainerWidth - GVC.timelineItemEarViewWidth * 2

        if withLeftEar { // 拖拽左执耳视图

            // 左标位置动、右标位置不动

            var contentOffset: CGPoint = contentViewContainer.contentOffset
            contentOffset.x = max(contentOffset.x + expandedWidth, 0)
            contentViewContainer.setContentOffset(contentOffset, animated: false)
        }
    }

    func trackItemViewDidEndExpanding(footage: MetaFootage, cursorTimeOffsetMilliseconds: Int64) {

        // 恢复滚动代理

        contentViewContainer.delegate = self

        // 完成操作

        delegate?.trackItemViewDidEndExpanding(footage: footage, cursorTimeOffsetMilliseconds: cursorTimeOffsetMilliseconds)
    }
}

extension TimelineView {

    func updateNodeItemViews(nodes: [MetaNode]) {

        // 移除先前的全部组件项视图

        for nodeItemTagView in nodeItemTagViewList {
            nodeItemTagView.removeFromSuperview()
        }
        nodeItemTagViewList.removeAll()

        for nodeItemView in nodeItemViewList {
            nodeItemView.removeFromSuperview()
        }
        nodeItemViewList.removeAll()

        // 添加新的组件项视图

        nodes.forEach { addNodeItemView(node: $0) }

        // 调整父视图及其他相关视图的布局

        updateNodeItemViewContainer()
    }

    func addNodeItemView(node: MetaNode) {

        let startTime: CMTime = CMTimeMake(value: node.startTimeMilliseconds, timescale: GVC.preferredTimescale)
        let endTime: CMTime = CMTimeAdd(startTime, CMTimeMake(value: node.durationMilliseconds, timescale: GVC.preferredTimescale))
        let contentOffsetX: CGFloat = calculateContentOffsetX(at: startTime).0

        // 添加新的组件项标签视图

        let nodeItemTagView = NodeItemTagView(node: node)
        nodeItemTagView.isUserInteractionEnabled = true
        nodeItemTagView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nodeItemTagViewDidTap)))
        nodeItemTagViewContainer.addSubview(nodeItemTagView)
        nodeItemTagViewList.append(nodeItemTagView)
        nodeItemTagView.snp.makeConstraints { make -> Void in
            make.width.equalTo(NodeItemTagView.VC.width)
            make.height.equalTo(NodeItemTagView.VC.height)
            make.left.equalToSuperview().offset(contentOffsetX - NodeItemTagView.VC.width / 2 + GVC.timelineItemEarViewWidth)
            make.top.equalToSuperview()
        }

        // 添加新的组件项视图

        let nodeItemContentView: NodeItemContentView = NodeItemContentView(nodeType: node.nodeType, startTime: startTime, endTime: endTime)
        let nodeItemView: NodeItemView = NodeItemView(node: node)
        nodeItemView.delegate = self
        nodeItemView.updateContentView(nodeItemContentView)
        nodeItemView.isUserInteractionEnabled = true
        nodeItemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nodeItemViewDidTap)))
        nodeItemViewContainer.addSubview(nodeItemView)
        nodeItemViewList.append(nodeItemView)
        nodeItemView.snp.makeConstraints { make -> Void in
            make.width.equalTo(nodeItemView.barView.width)
            make.height.equalToSuperview()
            make.left.equalToSuperview().offset(contentOffsetX)
            make.bottom.equalTo(nodeItemTagView.snp.top)
        }
    }

    func removeNodeItemView(node: MetaNode) {

        for (i, nodeItemTagView) in nodeItemTagViewList.enumerated().reversed() {
            if nodeItemTagView.node.uuid == node.uuid {
                nodeItemTagView.removeFromSuperview()
                nodeItemTagViewList.remove(at: i)
            }
        }

        for (i, nodeItemView) in nodeItemViewList.enumerated().reversed() {
            if nodeItemView.node.uuid == node.uuid {
                nodeItemView.removeFromSuperview()
                nodeItemViewList.remove(at: i)
            }
        }
    }

    func updateNodeItemViewContainer() {

        // 调整父视图及其他相关视图的布局

        contentViewContainer.layoutIfNeeded()

        if let lastNodeItemView = nodeItemViewList.max(by: { $0.barView.contentView.endTime < $1.barView.contentView.endTime }) {
            nodeItemViewContainerWidth = lastNodeItemView.frame.origin.x + lastNodeItemView.barView.contentView.width + GVC.timelineItemEarViewWidth * 2
        } else {
            nodeItemViewContainerWidth = 0
        }

        // 更新内容视图容器的宽度
        // FIXME：根据 trackItemViewContainerWidth 和 nodeItemViewContainerWidth 更新 contentViewWidth

        // contentViewWidth = UIScreen.main.bounds.width + max(trackItemViewContainerWidth, nodeItemViewContainerWidth) - GVC.timelineItemEarViewWidth * 2

        contentViewWidth = UIScreen.main.bounds.width + trackItemViewContainerWidth - GVC.timelineItemEarViewWidth * 2

        // 重新加载组件项视图时，还原组件项视图容器在非激活状态下的高度

        nodeItemViewContainer.snp.updateConstraints { make -> Void in
            make.height.equalTo(NodeItemCurveView.VC.height)
        }

        // 添加调整布局动画

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            guard let s = self else { return }
            s.layoutIfNeeded()
        }, completion: nil)
    }
}

extension TimelineView: NodeItemViewDelegate {

    func nodeItemViewWillBeginExpanding(node: MetaNode) {

        // 先移除滚动代理

        contentViewContainer.delegate = nil

        // 保存可以被对齐的边缘时刻

        saveSnappedTimeMillisecondsBeforeExpandingNodeItemView(node: node)

        // 完成操作

        delegate?.nodeItemViewWillBeginExpanding(node: node)
    }

    func nodeItemViewDidExpand(node: MetaNode, expandedWidth: CGFloat, edgeX: CGFloat, withLeftEar: Bool) {

        if withLeftEar { // 拖拽左执耳视图

            // 更新组件项标签视图的位置

            guard let nodeItemTagView = nodeItemTagViewList.first(where: { $0.node.uuid == node.uuid }) else { return }
            nodeItemTagView.snp.updateConstraints { make -> Void in
                make.left.equalToSuperview().offset(edgeX - NodeItemTagView.VC.width / 2 + GVC.timelineItemEarViewWidth)
            }

        } else { // 拖拽右执耳视图

            // 更新组件项视图容器宽度
            // FIXME：当超过当前组件项视图容器宽度的时候，才需要增加宽度

            nodeItemViewContainerWidth += expandedWidth

        }

        // 更新内容视图容器的宽度
        // FIXME：根据 trackItemViewContainerWidth 和 nodeItemViewContainerWidth 更新 contentViewWidth

        // contentViewWidth = UIScreen.main.bounds.width + max(trackItemViewContainerWidth, nodeItemViewContainerWidth) - GVC.timelineItemEarViewWidth * 2

        contentViewWidth = UIScreen.main.bounds.width + trackItemViewContainerWidth - GVC.timelineItemEarViewWidth * 2
    }

    func nodeItemViewDidEndExpanding(node: MetaNode) {

        // 恢复滚动代理

        contentViewContainer.delegate = self

        // 完成操作

        delegate?.nodeItemViewDidEndExpanding(node: node)
    }

    private func saveSnappedTimeMillisecondsBeforeExpandingNodeItemView(node: MetaNode) {

        var timeMillisecondsPool: [Int64] = []

        // 添加其余组件项视图的边缘时刻

        for nodeItemView in nodeItemViewList.filter({ $0.node.uuid != node.uuid }) {
            let startTimeMilliseconds: Int64 = nodeItemView.node.startTimeMilliseconds
            let endTimeMilliseconds: Int64 = nodeItemView.node.startTimeMilliseconds + nodeItemView.node.durationMilliseconds
            timeMillisecondsPool.append(startTimeMilliseconds)
            timeMillisecondsPool.append(endTimeMilliseconds)
        }

        // 添加所有轨道项视图的结束时刻

        var nextEndTimeMilliseconds: Int64 = 0
        for trackItemView in trackItemViewList {
            nextEndTimeMilliseconds += trackItemView.footage.durationMilliseconds
            timeMillisecondsPool.append(nextEndTimeMilliseconds)
        }

        // 添加起始时刻

        timeMillisecondsPool.append(0)

        // 添加当前时刻

        timeMillisecondsPool.append(currentTimeMilliseconds)

        // 去除重复元素

        let snappedTimeMillisecondsPool: [Int64] = Array(Set(timeMillisecondsPool))

        // 保存

        UserDefaults.standard.set(snappedTimeMillisecondsPool, forKey: GKC.snappedTimeMillisecondsPool)
    }
}

extension TimelineView: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        // 更新当前屏幕可视范围内的轨道项视图的缩略图视图

        visibleTrackItemViewList().forEach { $0.contentView.updateThumbImageViews() }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        delegate?.timelineViewWillBeginScrolling()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

        let time: CMTime = calculateTime(at: scrollView.contentOffset.x).0
        delegate?.timelineViewDidEndScrolling(to: time, decelerate: decelerate)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        let time: CMTime = calculateTime(at: scrollView.contentOffset.x).0
        delegate?.timelineViewDidEndScrolling(to: time, decelerate: false)
    }

    func autoScroll(to time: CMTime) {

        // 更新当前时刻

        currentTimeMilliseconds = time.milliseconds()

        // 移除滚动代理

        contentViewContainer.delegate = nil

        // 设置内容偏移量

        let contentOffsetX: CGFloat = calculateContentOffsetX(at: time).0
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: { [weak self] in
            guard let s = self else { return }
            s.contentViewContainer.contentOffset = CGPoint(x: contentOffsetX, y: 0)
        }, completion: nil)

        // 更新当前屏幕可视范围内的轨道项视图的缩略图视图

        visibleTrackItemViewList().forEach { $0.contentView.updateThumbImageViews() }

        // FIXME：判断是否需要将组件项标签视图固定在屏幕左侧

        print("currentTimeMilliseconds: \(currentTimeMilliseconds), contentOffsetX: \(contentOffsetX)")

        for nodeItemTagView in nodeItemTagViewList {

            let leftMarkTimeMilliseconds: Int64 = Int64(UIScreen.main.bounds.width * 500 / GVC.defaultTimelineItemWidthPerSecond) + nodeItemTagView.node.startTimeMilliseconds
            let rightMarkTimeMilliseconds: Int64 = Int64(UIScreen.main.bounds.width * 500 / GVC.defaultTimelineItemWidthPerSecond) + nodeItemTagView.node.startTimeMilliseconds + nodeItemTagView.node.durationMilliseconds

            print("\(leftMarkTimeMilliseconds), \(rightMarkTimeMilliseconds)")

            if currentTimeMilliseconds >= leftMarkTimeMilliseconds && currentTimeMilliseconds <= rightMarkTimeMilliseconds {

                nodeItemTagView.snp.updateConstraints { make -> Void in
                    make.left.equalToSuperview().offset(contentOffsetX - UIScreen.main.bounds.width / 2 - NodeItemTagView.VC.width / 2 + GVC.timelineItemEarViewWidth)
                }
            }
        }

        // 恢复滚动代理

        contentViewContainer.delegate = self
    }

    private func calculateContentOffsetX(at time: CMTime) -> (CGFloat, Int) {

        var duration: CMTime = time
        var trackItemIndex: Int = 0
        for (i, trackItemView) in trackItemViewList.enumerated() {
            let trackItemDuration: CMTime = trackItemView.contentView.rightMarkTime - trackItemView.contentView.leftMarkTime
            if duration <= trackItemDuration {
                trackItemIndex = i
                break
            } else {
                duration = duration - trackItemDuration
            }
        }

        let contentOffsetX: CGFloat = GVC.defaultTimelineItemWidthPerSecond * time.seconds

        return (contentOffsetX, trackItemIndex)
    }

    private func calculateTime(at contentOffsetX: CGFloat) -> (CMTime, Int) {

        var offsetX: CGFloat = contentOffsetX
        var trackItemIndex = 0
        for (i, trackItemView) in trackItemViewList.enumerated() {
            let width: CGFloat = trackItemView.contentView.width
            if contentOffsetX <= width {
                trackItemIndex = i
                break
            } else {
                offsetX = offsetX - width
            }
        }

        let durationMilliseconds: Int64 = Int64((contentOffsetX * 1000 / GVC.defaultTimelineItemWidthPerSecond).rounded())
        let duration: CMTime = CMTimeMake(value: durationMilliseconds, timescale: GVC.preferredTimescale)

        return (duration, trackItemIndex)
    }
}

extension TimelineView {

    @objc private func contentViewContainerDidTap(_ sender: UITapGestureRecognizer) {

        // 取消选中全部子视图

        unselectAllTimelineItemViews()

        // 完成操作

        delegate?.timelineViewDidTap()
    }

    @objc private func trackItemViewDidTap(_ sender: UITapGestureRecognizer) {

        guard let trackItemView: TrackItemView = sender.view as? TrackItemView else { return }

        // 激活轨道项视图

        activateTrackItemView(footage: trackItemView.footage)
    }

    @objc private func nodeItemTagViewDidTap(_ sender: UITapGestureRecognizer) {

        guard let nodeItemTagView = sender.view as? NodeItemTagView else { return }

        if nodeItemTagView.isActive {

            // 取消激活组件项视图

            deactivateNodeItem(node: nodeItemTagView.node)

        } else {

            // 激活组件项视图

            activateNodeItemView(node: nodeItemTagView.node)
        }
    }

    @objc private func nodeItemViewDidTap(_ sender: UITapGestureRecognizer) {

        guard let nodeItemView: NodeItemView = sender.view as? NodeItemView else { return }

        if nodeItemView.isActive {

            delegate?.nodeItemViewWillBeginEditing(node: nodeItemView.node)
        }
    }

    @objc private func newFootageButtonDidTap() {

        delegate?.newFootageButtonDidTap()
    }

    func activateTrackItemView(footage: MetaFootage) {

        guard let trackItemView = trackItemViewList.first(where: { $0.footage.uuid == footage.uuid }) else { return }

        if !trackItemView.isActive {

            // 激活轨道项视图

            trackItemView.isActive = true
            trackItemViewContainer.bringSubviewToFront(trackItemView)
            trackItemViewList.filter({ $0 != trackItemView && $0.isActive }).forEach {
                $0.isActive = false
            }

            // 完成操作

            delegate?.trackItemViewDidBecomeActive(footage: trackItemView.footage)
        }

        // 取消选中全部组件项视图

        unselectAllNodeItemViews()

        // 重置底部视图

        resetBottomView(bottomViewType: .trackItem, footage: trackItemView.footage)
    }

    func activateNodeItemView(node: MetaNode) {

        guard let nodeItemTagView = nodeItemTagViewList.first(where: { $0.node.uuid == node.uuid }), let nodeItemView = nodeItemViewList.first(where: { $0.node.uuid == node.uuid }) else { return }

        if !nodeItemTagView.isActive {

            // 激活组件项视图

            nodeItemTagView.isActive = true
            nodeItemTagViewContainer.bringSubviewToFront(nodeItemTagView)
            nodeItemTagViewList.filter({ $0 != nodeItemTagView && $0.isActive }).forEach {
                $0.isActive = false
            }
            nodeItemView.isActive = true
            nodeItemViewContainer.bringSubviewToFront(nodeItemView)
            nodeItemViewList.filter({ $0 != nodeItemView && $0.isActive }).forEach {
                $0.isActive = false
            }

            // 更新组件项视图容器在激活状态下的高度

            nodeItemViewContainer.snp.updateConstraints { make -> Void in
                make.height.equalTo(NodeItemCurveView.VC.height + NodeItemBarView.VC.height)
            }

            // 取消选中全部轨道项视图

            unselectAllTrackItemViews()

            // 重置底部视图

            resetBottomView(bottomViewType: .nodeItem, node: nodeItemView.node)

            // 完成操作

            delegate?.nodeItemViewDidBecomeActive(node: nodeItemView.node)

            // 添加调整布局动画

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                guard let s = self else { return }
                s.layoutIfNeeded()
            }, completion: nil)
        }
    }

    private func deactivateNodeItem(node: MetaNode) {

        guard let nodeItemTagView = nodeItemTagViewList.first(where: { $0.node.uuid == node.uuid }), let nodeItemView = nodeItemViewList.first(where: { $0.node.uuid == node.uuid }) else { return }

        if nodeItemTagView.isActive {

            // 取消激活组件项视图

            nodeItemTagView.isActive = false
            nodeItemView.isActive = false

            // 更新组件项视图容器在非激活状态下的高度

            nodeItemViewContainer.snp.updateConstraints { make -> Void in
                make.height.equalTo(NodeItemCurveView.VC.height)
            }

            // 重置底部视图

            resetBottomView(bottomViewType: .timeline)

            // 完成操作

            delegate?.nodeItemViewDidResignActive(node: nodeItemView.node)

            // 添加调整布局动画

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                guard let s = self else { return }
                s.layoutIfNeeded()
            }, completion: nil)
        }
    }

    func unselectAllTimelineItemViews() {

        // 取消激活全部轨道项视图

        unselectAllTrackItemViews()

        // 取消激活全部组件项视图

        unselectAllNodeItemViews()

        // 重置底部视图

        resetBottomView(bottomViewType: .timeline)
    }

    func unselectAllTrackItemViews() {

        // 取消激活全部轨道项视图

        trackItemViewList.filter({ $0.isActive }).forEach {
            $0.isActive = false
        }
    }

    func unselectAllNodeItemViews() {

        // 取消激活全部组件项视图

        nodeItemTagViewList.filter({ $0.isActive }).forEach {
            $0.isActive = false
        }
        nodeItemViewList.filter({ $0.isActive }).forEach {
            $0.isActive = false
        }

        // 更新组件项视图容器在非激活状态下的高度

        nodeItemViewContainer.snp.updateConstraints { make -> Void in
            make.height.equalTo(NodeItemCurveView.VC.height)
        }

        // 添加调整布局动画

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            guard let s = self else { return }
            s.layoutIfNeeded()
        }, completion: nil)
    }
}
