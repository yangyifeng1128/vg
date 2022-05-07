///
/// SceneEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVFoundation
import FittedSheets
import Photos
import SnapKit
import UIKit

class SceneEditorViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let topButtonContainerWidth: CGFloat = 64
        static let topRightButtonContainerWidth: CGFloat = 52
        static let topButtonContainerPadding: CGFloat = 12
        static let sceneTitleLabelWidth: CGFloat = 160
        static let sceneTitleLabelFontSize: CGFloat = 14
        static let workspaceViewHeight: CGFloat = 286
        static let actionBarViewHeight: CGFloat = 44
        static let playButtonHeight: CGFloat = 44
        static let playButtonImageEdgeInset: CGFloat = 10
        static let currentTimeLabelWidth: CGFloat = 44
        static let actionBarViewLabelFontSize: CGFloat = 14
        static let timeSeparatorLabelFontSize: CGFloat = 10
        static let previewButtonWidth: CGFloat = 72
        static let previewButtonTitleLabelFontSize: CGFloat = 13
    }

    /// 用户界面风格偏好设置
    static let preferredUserInterfaceStyle: UIUserInterfaceStyle = .dark

    /// 关闭按钮容器
    var closeButtonContainer: UIView!
    /// 关闭按钮
    var closeButton: CircleNavigationBarButton!
    /// 场景设置按钮容器
    var sceneSettingsButtonContainer: UIView!
    /// 场景设置按钮
    var sceneSettingsButton: CircleNavigationBarButton!

    /// 播放器视图容器
    var playerViewContainer: UIView!
    /// 播放器视图
    var playerView: ScenePlayerView!
    /// 加载视图
    var loadingView: LoadingView!

    /// 操作栏视图
    var actionBarView: BorderedView!
    /// 播放按钮
    var playButton: SceneEditorPlayButton!
    /// 当前时刻标签
    var currentTimeLabel: UILabel!
    /// 场景时长标签
    var sceneDurationLabel: UILabel!
    /// 运行按钮
    var previewButton: RoundedButton!

    /// 工作区视图
    var workspaceView: UIView!
    /// 工作区无数据视图
    var workspaceNoDataView: WorkspaceNoDataView!
    /// 时间线视图
    var timelineView: TimelineView!
    /// 底部 Sheet 视图控制器
    var bottomSheetViewController: SheetViewController?

    /// 渲染尺寸
    var renderSize: CGSize!

    /// 场景资源包
    var sceneBundle: MetaSceneBundle!
    /// 作品资源包
    var gameBundle: MetaGameBundle!

    /// 播放器
    var player: AVPlayer!
    /// 播放器项
    var playerItem: AVPlayerItem!
    /// 时间线
    var timeline: Timeline = Timeline()
    /// 当前时刻
    var currentTime: CMTime = .zero {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let s = self else { return }
                s.updateViewsWhenTimeElapsed(to: s.currentTime)
            }
        }
    }
    /// 周期时刻观察器
    var periodicTimeObserver: Any?

    var needsReloadPlayer: Bool = true

    /// 初始化
    init(sceneBundle: MetaSceneBundle, gameBundle: MetaGameBundle) {

        super.init(nibName: nil, bundle: nil)

        self.sceneBundle = sceneBundle
        self.gameBundle = gameBundle
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 反初始化
    deinit {

        removePeriodicTimeObserver()
        NotificationCenter.default.removeObserver(self)
    }

    /// 视图加载完成
    override func viewDidLoad() {

        super.viewDidLoad()

        // 单独强制设置用户界面风格

        overrideUserInterfaceStyle = SceneEditorViewController.preferredUserInterfaceStyle

        // 初始化视图

        initViews()
    }

    /// 视图即将显示
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // 隐藏导航栏

        navigationController?.navigationBar.isHidden = true

        // 单独强制设置状态栏风格

        navigationController?.navigationBar.barStyle = (overrideUserInterfaceStyle == .dark) ? .black : .default
    }

    /// 视图显示完成
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        if needsReloadPlayer && !isSceneBundleEmpty() { // （重新）加载播放器

            loadingView.startAnimating()
            reloadPlayer()

        } else { // 不重新加载播放器

            if let player = player {
                player.seek(to: CMTimeMake(value: sceneBundle.currentTimeMilliseconds, timescale: GVC.preferredTimescale), toleranceBefore: .zero, toleranceAfter: .zero) // 但是需要重新定位播放时刻
            }
        }
    }

    /// 视图即将消失
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        // 关闭先前展示的「Sheet 视图控制器」（如果有的话）

        dismissPreviousBottomSheetViewController()

        // 暂停并保存资源包

        if !timeline.videoChannel.isEmpty {
            pause()
        }
        saveSceneBundle()

        // 提示场景已保存

        sendSceneSavedMessage()
    }

    /// 保存场景资源包
    func saveSceneBundle() {

        sceneBundle.currentTimeMilliseconds = currentTime.milliseconds()
        MetaSceneBundleManager.shared.save(sceneBundle)

        MetaGameBundleManager.shared.save(gameBundle)
    }

    /// 提示场景已保存
    func sendSceneSavedMessage() {

        var message: String
        guard let scene = gameBundle.selectedScene() else { return }
        if let title = scene.title, !title.isEmpty {
            message = (title.count > 8) ? title.prefix(8) + "..." : title
        } else {
            message = NSLocalizedString("Scene", comment: "") + " " + scene.index.description
        }
        if let parent = presentingViewController?.children.last as? GameEditorViewController {
            parent.sceneSavedMessage = message + " " + NSLocalizedString("Saved", comment: "")
        }
    }

    /// 初始化视图
    private func initViews() {

        view.backgroundColor = .systemGroupedBackground

        // 初始化「导航栏」

        initNavigationBar()

        // 初始化「工作区视图」

        initWorkspaceView()

        // 初始化「播放器视图」

        initPlayerView()

        // 初始化「操作栏视图」

        initActionBarView()
    }

    private func initNavigationBar() {

        // 初始化「关闭按钮容器」

        closeButtonContainer = UIView()
        closeButtonContainer.backgroundColor = .clear
        closeButtonContainer.isUserInteractionEnabled = true
        closeButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeButtonDidTap)))
        view.addSubview(closeButtonContainer)
        closeButtonContainer.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.topButtonContainerWidth)
            make.left.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        // 初始化「关闭按钮」

        closeButton = CircleNavigationBarButton(icon: .close)
        closeButton.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
        closeButtonContainer.addSubview(closeButton)
        closeButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.VC.width)
            make.right.bottom.equalToSuperview().offset(-VC.topButtonContainerPadding)
        }

        // 初始化「场景设置按钮容器」

        sceneSettingsButtonContainer = UIView()
        sceneSettingsButtonContainer.backgroundColor = .clear
        sceneSettingsButtonContainer.isUserInteractionEnabled = true
        sceneSettingsButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sceneSettingsButtonDidTap)))
        view.addSubview(sceneSettingsButtonContainer)
        let sceneSettingsButtonContainerLeft: CGFloat = view.bounds.width - VC.topRightButtonContainerWidth
        sceneSettingsButtonContainer.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.topRightButtonContainerWidth)
            make.height.equalTo(VC.topButtonContainerWidth)
            make.left.equalToSuperview().offset(sceneSettingsButtonContainerLeft)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        // 初始化「场景设置按钮」

        sceneSettingsButton = CircleNavigationBarButton(icon: .sceneSettings)
        sceneSettingsButton.addTarget(self, action: #selector(sceneSettingsButtonDidTap), for: .touchUpInside)
        sceneSettingsButtonContainer.addSubview(sceneSettingsButton)
        sceneSettingsButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.VC.width)
            make.right.equalToSuperview().offset(-VC.topButtonContainerPadding)
            make.bottom.equalToSuperview().offset(-VC.topButtonContainerPadding)
        }

        // 初始化「场景标题标签」

        let sceneTitleLabel: UILabel = UILabel()
        sceneTitleLabel.attributedText = prepareSceneTitleLabelAttributedText()
        sceneTitleLabel.numberOfLines = 2
        sceneTitleLabel.lineBreakMode = .byTruncatingTail
        sceneTitleLabel.isUserInteractionEnabled = true
        sceneTitleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sceneTitleLabelDidTap)))
        view.addSubview(sceneTitleLabel)
        sceneTitleLabel.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.sceneTitleLabelWidth)
            make.centerY.equalTo(closeButton)
            make.left.equalTo(closeButtonContainer.snp.right).offset(8)
        }
    }

    /// 初始化「工作区视图」
    private func initWorkspaceView() {

        workspaceView = UIView()
        view.addSubview(workspaceView)
        workspaceView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(VC.workspaceViewHeight)
            make.left.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        // 初始化「时间线视图」

        initTimelineView()

        // 初始化「工作区无数据视图」

        initWorkspaceNoDataView()

        // 初始化「工作区视图」内容显示状态

        if isSceneBundleEmpty() {

            workspaceNoDataView.isHidden = false
            workspaceView.bringSubviewToFront(workspaceNoDataView)

        } else {

            workspaceNoDataView.isHidden = true
            workspaceView.sendSubviewToBack(workspaceNoDataView)
        }
    }

    /// 初始化「工作区无数据视图」
    private func initWorkspaceNoDataView() {

        workspaceNoDataView = WorkspaceNoDataView()
        workspaceNoDataView.delegate = self
        workspaceView.addSubview(workspaceNoDataView)
        workspaceNoDataView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }
    }

    /// 初始化「时间线视图」
    private func initTimelineView() {

        let trackItemThumbImageWidth: CGFloat = MetaSceneAspectRatioTypeManager.shared.calculateWidth(height: TrackItemContentView.VC.height, aspectRatioType: sceneBundle.aspectRatioType)
        let trackItemThumbImageSize: CGSize = CGSize(width: trackItemThumbImageWidth, height: TrackItemContentView.VC.height)

        timelineView = TimelineView(trackItemThumbImageSize: trackItemThumbImageSize)
        timelineView.isHidden = true
        timelineView.delegate = self
        timelineView.timelineToolBarView.delegate = self
        timelineView.trackItemBottomBarView.delegate = self
        timelineView.nodeItemBottomBarView.delegate = self
        workspaceView.addSubview(timelineView)
        timelineView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }
    }

    /// 初始化「播放器视图」
    private func initPlayerView() {

        // 初始化「播放器视图」尺寸

        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        let renderHeight: CGFloat = UIScreen.main.bounds.height - VC.topButtonContainerWidth - window.safeAreaInsets.top - VC.workspaceViewHeight - VC.actionBarViewHeight - window.safeAreaInsets.bottom
        let renderWidth: CGFloat = MetaSceneAspectRatioTypeManager.shared.calculateWidth(height: renderHeight, aspectRatioType: sceneBundle.aspectRatioType)
        renderSize = CGSize(width: renderWidth, height: renderHeight)

        // 初始化「播放器视图容器」

        playerViewContainer = UIView()
        playerViewContainer.backgroundColor = .systemFill
        playerViewContainer.isUserInteractionEnabled = true
        playerViewContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playerViewContainerDidTap)))
        view.addSubview(playerViewContainer)
        playerViewContainer.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(renderSize.height)
            make.left.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(VC.topButtonContainerWidth)
        }

        // 初始化「播放器视图」

        playerView = ScenePlayerView(renderSize: renderSize, isEditable: true)
        playerView.delegate = self
        playerViewContainer.addSubview(playerView)
        playerView.snp.makeConstraints { make -> Void in
            make.width.equalTo(renderSize.width)
            make.height.equalTo(renderSize.height)
            make.center.equalToSuperview()
        }

        // 初始化「加载视图」

        loadingView = LoadingView()
        playerView.addSubview(loadingView)
        loadingView.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(LoadingView.VC.width)
            make.center.equalToSuperview()
        }

        // 初始化「播放器视图」内容显示状态

        if isSceneBundleEmpty() {

            playerView.rendererView.image = .sceneBackground
            playerView.rendererView.contentMode = .scaleAspectFill
        }
    }

    /// 初始化「操作栏视图」
    private func initActionBarView() {

        // 初始化「操作栏视图」

        actionBarView = BorderedView(side: .bottom)
        actionBarView.isHidden = true
        view.addSubview(actionBarView)
        actionBarView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(VC.actionBarViewHeight)
            make.left.equalToSuperview()
            make.bottom.equalTo(workspaceView.snp.top)
        }

        // 初始化「播放按钮」

        playButton = SceneEditorPlayButton(imageEdgeInset: VC.playButtonImageEdgeInset)
        playButton.addTarget(self, action: #selector(playButtonDidTap), for: .touchUpInside)
        actionBarView.addSubview(playButton)
        playButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.playButtonHeight)
            make.center.equalToSuperview()
        }

        // 初始化「场景时长标签」

        currentTimeLabel = UILabel()
        currentTimeLabel.text = "00:00"
        currentTimeLabel.font = .systemFont(ofSize: VC.actionBarViewLabelFontSize, weight: .regular)
        currentTimeLabel.textColor = .mgLabel
        actionBarView.addSubview(currentTimeLabel)
        currentTimeLabel.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.currentTimeLabelWidth)
            make.height.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview()
        }

        let timeSeparatorLabel: UILabel = UILabel()
        timeSeparatorLabel.text = "/"
        timeSeparatorLabel.font = .systemFont(ofSize: VC.timeSeparatorLabelFontSize, weight: .regular)
        timeSeparatorLabel.textColor = .secondaryLabel
        actionBarView.addSubview(timeSeparatorLabel)
        timeSeparatorLabel.snp.makeConstraints { make -> Void in
            make.width.equalTo(8)
            make.centerY.equalTo(currentTimeLabel)
            make.left.equalTo(currentTimeLabel.snp.right)
        }

        sceneDurationLabel = UILabel()
        sceneDurationLabel.text = "00:00"
        sceneDurationLabel.font = .systemFont(ofSize: VC.actionBarViewLabelFontSize, weight: .regular)
        sceneDurationLabel.textColor = .secondaryLabel
        actionBarView.addSubview(sceneDurationLabel)
        sceneDurationLabel.snp.makeConstraints { make -> Void in
            make.centerY.equalTo(currentTimeLabel)
            make.left.equalTo(timeSeparatorLabel.snp.right)
            make.right.equalTo(playButton.snp.left).offset(-12)
        }

        // 初始化「运行按钮」

        previewButton = RoundedButton(cornerRadius: 4.8)
        previewButton.backgroundColor = .accent
        previewButton.tintColor = .mgLabel
        previewButton.setTitle(NSLocalizedString("Preview", comment: ""), for: .normal)
        previewButton.setTitleColor(.mgLabel, for: .normal)
        previewButton.setTitleColor(UIColor.mgLabel?.withAlphaComponent(0.5), for: .disabled)
        previewButton.titleLabel?.font = .systemFont(ofSize: VC.previewButtonTitleLabelFontSize, weight: .regular)
        previewButton.setImage(.emulate, for: .normal)
        previewButton.adjustsImageWhenHighlighted = false
        previewButton.imageView?.tintColor = .mgLabel
        previewButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        previewButton.addTarget(self, action: #selector(previewButtonDidTap), for: .touchUpInside)
        actionBarView.addSubview(previewButton)
        previewButton.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.previewButtonWidth)
            make.height.equalToSuperview().inset(8)
            make.centerY.equalTo(playButton)
            make.right.equalToSuperview().offset(-12)
        }
    }

    /// 准备「场景标题标签」文本
    private func prepareSceneTitleLabelAttributedText() -> NSMutableAttributedString {

        let completeSceneTitleString: NSMutableAttributedString = NSMutableAttributedString(string: "")

        guard let scene = gameBundle.selectedScene() else {
            return completeSceneTitleString
        }

        // 准备场景索引

        let sceneIndexStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.secondaryLabel, .font: UIFont.systemFont(ofSize: VC.sceneTitleLabelFontSize, weight: .regular)]
        // let trimmedGameTitleString: String = (gameTitle.count > 8) ? gameTitle.prefix(8) + "..." : gameTitle
        let sceneIndexString: NSAttributedString = NSAttributedString(string: /* trimmedGameTitleString + " -  " + */ NSLocalizedString("Scene", comment: "") + " " + scene.index.description, attributes: sceneIndexStringAttributes)
        completeSceneTitleString.append(sceneIndexString)

        // 准备场景标题

        if let title = scene.title, !title.isEmpty {
            let sceneTitleStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.mgLabel!, .font: UIFont.systemFont(ofSize: VC.sceneTitleLabelFontSize, weight: .regular)]
            let sceneTitleString: NSAttributedString = NSAttributedString(string: "\n" + title, attributes: sceneTitleStringAttributes)
            completeSceneTitleString.append(sceneTitleString)
        }

        // 准备段落样式

        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        completeSceneTitleString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, completeSceneTitleString.length))

        return completeSceneTitleString
    }
}

extension SceneEditorViewController: WorkspaceNoDataViewDelegate {

    func initialFootageButtonDidTap() {

        print("[SceneEditor] did tap initialFootageButton")

        addFootage()
    }
}

extension SceneEditorViewController: TimelineViewDelegate {

    func timelineViewDidTap() {

        print("[SceneEditor] timelineView did tap")

        // 关闭先前展示的「Sheet 视图控制器」（如果有的话）

        dismissPreviousBottomSheetViewController()
    }

    func timelineViewWillBeginScrolling() {

        print("[SceneEditor] timelineView will begin scrolling")

        closeButtonContainer.isUserInteractionEnabled = false
        closeButton.isEnabled = false
        sceneSettingsButtonContainer.isUserInteractionEnabled = false
        sceneSettingsButton.isEnabled = false
        playButton.isEnabled = false
        previewButton.isEnabled = false
        timelineView.isEnabled = false
    }

    func timelineViewDidEndScrolling(to time: CMTime, decelerate: Bool) {

        print("[SceneEditor] timelineView did end scrolling to \(time.milliseconds()) ms")

        currentTimeLabel.text = time.toString()
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)

        if !decelerate {
            closeButtonContainer.isUserInteractionEnabled = true
            closeButton.isEnabled = true
            sceneSettingsButtonContainer.isUserInteractionEnabled = true
            sceneSettingsButton.isEnabled = true
            playButton.isEnabled = true
            previewButton.isEnabled = true
            timelineView.isEnabled = true
        }
    }

    func trackItemViewDidBecomeActive(footage: MetaFootage) {

        print("[SceneEditor] trackItemView \(footage.index) did become active")

        // 关闭先前展示的「Sheet 视图控制器」（如果有的话）

        dismissPreviousBottomSheetViewController()
    }

    func trackItemViewWillBeginExpanding(footage: MetaFootage) {

        print("[SceneEditor] trackItemView \(footage.index) will begin expanding")
    }

    func trackItemViewDidEndExpanding(footage: MetaFootage, cursorTimeOffsetMilliseconds: Int64) {

        print("[SceneEditor] trackItemView \(footage.index) did end expanding")

        let cursorTimeMilliseconds: Int64 = max(currentTime.milliseconds() + cursorTimeOffsetMilliseconds, 0)

        for (i, f) in sceneBundle.footages.enumerated() {
            if f.uuid == footage.uuid {
                sceneBundle.footages[i].leftMarkTimeMilliseconds = footage.leftMarkTimeMilliseconds
                sceneBundle.footages[i].durationMilliseconds = footage.durationMilliseconds
                sceneBundle.currentTimeMilliseconds = cursorTimeMilliseconds // 保存当前播放时刻
                MetaSceneBundleManager.shared.save(sceneBundle)
                reloadPlayer()
            }
        }
    }

    func nodeItemViewDidBecomeActive(node: MetaNode) {

        guard let nodeTypeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: node.nodeType) else { return }
        print("[SceneEditor] \"\(nodeTypeTitle) \(node.index)\" did become active")
    }

    func nodeItemViewDidResignActive(node: MetaNode) {

        guard let nodeTypeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: node.nodeType) else { return }
        print("[SceneEditor] \"\(nodeTypeTitle) \(node.index)\" did resign active")
    }

    func nodeItemViewWillBeginExpanding(node: MetaNode) {

        guard let nodeTypeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: node.nodeType) else { return }
        print("[SceneEditor] \"\(nodeTypeTitle) \(node.index)\" will begin expanding")
    }

    func nodeItemViewDidEndExpanding(node: MetaNode) {

        guard let nodeTypeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: node.nodeType) else { return }
        print("[SceneEditor] \"\(nodeTypeTitle) \(node.index)\" did end expanding")

        for (i, n) in sceneBundle.nodes.enumerated() {
            if n.uuid == node.uuid {
                sceneBundle.nodes[i].startTimeMilliseconds = node.startTimeMilliseconds
                sceneBundle.nodes[i].durationMilliseconds = node.durationMilliseconds
                sceneBundle.currentTimeMilliseconds = currentTime.milliseconds()// 保存当前播放时刻
                MetaSceneBundleManager.shared.save(sceneBundle)
            }
        }
    }

    func nodeItemViewWillBeginEditing(node: MetaNode) {

        guard let nodeTypeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: node.nodeType) else { return }
        print("[SceneEditor] \"\(nodeTypeTitle) \(node.index)\" will begin editing")

        // 展示「编辑组件项 Sheet 视图控制器」

        presentEditNodeItemSheetViewController(node: node)
    }

    func newFootageButtonDidTap() {

        print("[SceneEditor] newFootageButton did tap")

        // 添加镜头片段

        addFootage()
    }
}

extension SceneEditorViewController: TimelineToolBarViewDelegate, AddNodeItemViewControllerDelegate, EditNodeItemViewControllerDelegate, TrackItemBottomBarViewDelegate, NodeItemBottomBarViewDelegate {

    func toolBarItemDidTap(_ toolBarItem: TimelineToolBarItem) {

        print("[SceneEditor] toolBarItem \"\(toolBarItem.type)\" did tap")

        // 暂停并保存资源包

        if !timeline.videoChannel.isEmpty {
            pause()
        }
        saveSceneBundle()

        // 展示「添加组件项 Sheet 视图控制器」

        presentAddNodeItemSheetViewController(toolBarItem: toolBarItem)
    }

    func toolBarSubitemDidTap(_ toolBarSubitem: TimelineToolBarSubitem) {

        let nodeType: MetaNodeType = toolBarSubitem.nodeType
        print("[SceneEditor] toolBarSubitem \"\(nodeType)\" did tap")

        // 添加组件项

        addMetaNode(nodeType: nodeType)

        // 关闭先前展示的「添加组件项 Sheet 视图控制器」

        dismissPreviousBottomSheetViewController()
    }

    func saveBundleWhenNodeItemViewChanged(node: MetaNode, rules: [MetaRule]) {

        guard let nodeTypeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: node.nodeType) else { return }
        print("[SceneEditor] save bundle when \"\(nodeTypeTitle) \(node.index)\" changed")
    }

    func deleteMetaNodeFromEditNodeItemViewController(node: MetaNode) {

        // 删除组件

        deleteMetaNode(node)
    }

    func trackItemBottomBarItemDidTap(footage: MetaFootage, actionBarItem: TrackItemBottomBarItem) {

        print("[SceneEditor] footage \"\(footage.index)\" did \"\(actionBarItem.type)\"")

        switch actionBarItem.type {

        case .delete:

            // 删除轨道项

            deleteMetaFootage(footage)
            break
        }
    }

    func goBackFromTrackItemBottomBar() {

        print("[SceneEditor] go back from trackItemBottomBar")

        timelineView.unselectAllTimelineItemViews()
    }

    func nodeItemBottomBarItemDidTap(node: MetaNode, actionBarItem: NodeItemBottomBarItem) {

        guard let nodeTypeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: node.nodeType) else { return }
        print("[SceneEditor] \"\(nodeTypeTitle) \(node.index)\" did \"\(actionBarItem.type)\"")

        switch actionBarItem.type {

        case .edit:

            // 重新定位播放时刻

            player.seek(to: CMTimeMake(value: node.startTimeMilliseconds, timescale: GVC.preferredTimescale), toleranceBefore: .zero, toleranceAfter: .zero)

            // 展示「编辑组件项 Sheet 视图控制器」

            presentEditNodeItemSheetViewController(node: node)
            break

        case .delete:

            // 删除组件

            deleteMetaNode(node)
            break
        }
    }

    func goBackFromNodeItemBottomBar() {

        print("[SceneEditor] go back from nodeItemBottomBar")

        timelineView.unselectAllTimelineItemViews()
    }
}

extension SceneEditorViewController: TargetAssetsViewControllerDelegate {

    func assetDidPick(_ phasset: PHAsset, thumbImage: UIImage?) {

        print("[SceneEditor] asset did pick")

        loadingView.startAnimating()
        disablePlayerRelatedViews()

        // 加载刚刚选取的素材

        if phasset.mediaType == .image {

            loadPickedImage(phasset: phasset) { [weak self] in
                guard let s = self else { return }
                s.reloadPlayer()
            }

        } else if phasset.mediaType == .video {

            loadPickedVideo(phasset: phasset) { [weak self] in
                guard let s = self else { return }
                s.reloadPlayer()
            }
        }

        // 保存场景缩略图

        if isSceneBundleEmpty(), let thumbImage = thumbImage {

            MetaThumbManager.shared.saveSceneThumbImage(sceneUUID: sceneBundle.sceneUUID, gameUUID: sceneBundle.gameUUID, image: thumbImage) // 保存缩略图

            GameEditorExternalChangeManager.shared.set(key: .updateSceneThumbImage, value: sceneBundle.sceneUUID) // 保存作品编辑器外部变更记录
        }
    }

    private func disablePlayerRelatedViews() {

        playerView.rendererView.player = nil

        playerView.rendererView.image = nil
        playerView.updateNodeViews(nodes: [])
        actionBarView.isHidden = true
        timelineView.isHidden = true
        workspaceNoDataView.isHidden = true
    }

    private func loadPickedImage(phasset: PHAsset, completion: @escaping () -> Void) {

        let options = PHImageRequestOptions()
        options.version = .current
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        options.progressHandler = { [weak self] progress, _, _, _ in
            print("[SceneEditor] load picked image: \(progress)")
            guard let s = self else { return }
            DispatchQueue.main.sync {
                s.loadingView.progress = progress
            }
        }

        PHImageManager.default().requestImage(for: phasset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { [weak self] image, info in
            guard let s = self else { return }
            if let image = image {
                MetaSceneBundleManager.shared.addMetaImageFootage(sceneBundle: s.sceneBundle, image: image)
            }
            completion()
        }
    }

    private func loadPickedVideo(phasset: PHAsset, completion: @escaping () -> Void) {

        let options = PHVideoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = { [weak self] progress, _, _, _ in
            print("[SceneEditor] load picked video: \(progress)")
            guard let s = self else { return }
            DispatchQueue.main.sync {
                s.loadingView.progress = progress
            }
        }

        PHImageManager.default().requestAVAsset(forVideo: phasset, options: options) { [weak self] asset, audioMix, info -> Void in
            guard let s = self else { return }
            if let asset = asset {
                MetaSceneBundleManager.shared.addMetaVideoFootage(sceneBundle: s.sceneBundle, asset: asset)
            }
            completion()
        }
    }
}

extension SceneEditorViewController: ScenePlayerViewDelegate {

    func nodeViewWillBeginEditing(_ nodeView: MetaNodeView) {

        guard let node = nodeView.node, let nodeTypeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: node.nodeType) else { return }
        print("[SceneEditor] \"\(nodeTypeTitle) \(node.index)\" will begin editing")

        // 暂停并保存资源包

        if !timeline.videoChannel.isEmpty {
            pause()
        }
        saveSceneBundle()

        // 激活「时间线-组件项」视图

        timelineView.activateNodeItemView(node: nodeView.node)

        // 展示「编辑组件项 Sheet 视图控制器」

        presentEditNodeItemSheetViewController(node: nodeView.node)
    }

    func saveBundleWhenNodeViewChanged(node: MetaNode) {

        guard let nodeTypeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: node.nodeType) else { return }
        print("[SceneEditor] save bundle when \"\(nodeTypeTitle) \(node.index)\" changed")

        // 更新组件数据

        sceneBundle.updateNode(node)

        // 保存资源包

        saveSceneBundle()
    }
}

extension SceneEditorViewController {

    func reloadPlayer() {

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in

            guard let s = self else { return }

            // （重新）加载时间线

            s.reloadTimeline()

            // （重新）初始化播放器

            let compositionGenerator = CompositionGenerator(timeline: s.timeline)
            s.playerItem = compositionGenerator.buildPlayerItem()

            if s.player == nil {
                s.player = AVPlayer.init(playerItem: s.playerItem)
                try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []) // 如果手机处于静音模式，则打开音频播放
            } else {
                s.removePeriodicTimeObserver() // 移除周期时刻观察器
                NotificationCenter.default.removeObserver(s) // 移除其他全部监听器
                s.player.replaceCurrentItem(with: s.playerItem)
            }
            s.player.seek(to: CMTimeMake(value: s.sceneBundle.currentTimeMilliseconds, timescale: GVC.preferredTimescale), toleranceBefore: .zero, toleranceAfter: .zero)
            s.addPeriodicTimeObserver() // 添加周期时刻观察器
            NotificationCenter.default.addObserver(s, selector: #selector(s.playerItemDidPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: s.player.currentItem) // 添加「播放完毕」监听器
            NotificationCenter.default.addObserver(s, selector: #selector(s.didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil) // 添加「进入后台」监听器
            NotificationCenter.default.addObserver(s, selector: #selector(s.willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil) // 添加「进入前台」监听器

            // （重新）初始化界面

            DispatchQueue.main.async {
                s.updatePlayerRelatedViews() // 更新播放器相关的界面
                s.loadingView.stopAnimating() // 停止加载视图的加载动画
            }
        }
    }

    private func reloadTimeline() {

        var trackItems: [TrackItem] = []

        for footage in sceneBundle.footages {

            var trackItem: TrackItem?

            if footage.footageType == .image {

                let footageURL: URL = MetaSceneBundleManager.shared.getMetaImageFootageFileURL(footageUUID: footage.uuid, sceneUUID: sceneBundle.sceneUUID, gameUUID: sceneBundle.gameUUID)

                if let image = CIImage(contentsOf: footageURL) {
                    let resource: ImageResource = ImageResource(image: image, duration: CMTimeMake(value: footage.durationMilliseconds - footage.leftMarkTimeMilliseconds, timescale: GVC.preferredTimescale))
                    trackItem = TrackItem(resource: resource)
                }

            } else if footage.footageType == .video {

                let footageURL: URL = MetaSceneBundleManager.shared.getMetaVideoFootageFileURL(footageUUID: footage.uuid, sceneUUID: sceneBundle.sceneUUID, gameUUID: sceneBundle.gameUUID)

                let asset: AVAsset = AVAsset(url: footageURL)
                let resource: AVAssetTrackResource = AVAssetTrackResource(asset: asset)
                resource.selectedTimeRange = CMTimeRange(start: CMTimeMake(value: footage.leftMarkTimeMilliseconds, timescale: GVC.preferredTimescale), duration: CMTimeMake(value: footage.durationMilliseconds, timescale: GVC.preferredTimescale))
                trackItem = TrackItem(resource: resource)
            }

            if let trackItem = trackItem {

                let videoTransition: NoneTransition = NoneTransition(duration: .zero)
                trackItem.videoTransition = videoTransition
                trackItem.videoConfiguration.contentMode = .aspectFill // 此处采用 aspectFill（而非 aspectFit）的原因是尽量将视频填满播放器

                trackItems.append(trackItem)
            }
        }

        timeline.videoChannel = trackItems
        timeline.audioChannel = trackItems

        try? Timeline.reloadVideoStartTime(providers: timeline.videoChannel)

        let scale = UIScreen.main.scale
        timeline.renderSize = CGSize(width: renderSize.width * scale, height: renderSize.height * scale)
    }

    private func updatePlayerRelatedViews() {

        if timeline.videoChannel.isEmpty {

            playerView.rendererView.player = nil

            playerView.rendererView.image = .sceneBackground
            playerView.rendererView.contentMode = .scaleAspectFill
            actionBarView.isHidden = true
            workspaceNoDataView.isHidden = false
            workspaceView.bringSubviewToFront(workspaceNoDataView)
            timelineView.isHidden = true

        } else {

            playerView.rendererView.player = player

            playerView.rendererView.image = nil
            actionBarView.isHidden = false
            sceneDurationLabel.text = playerItem.duration.toString()
            workspaceNoDataView.isHidden = true
            workspaceView.sendSubviewToBack(workspaceNoDataView)
            timelineView.isHidden = false
        }

        playerView.updateNodeViews(nodes: sceneBundle.nodes)
        playerView.showOrHideNodeViews(at: CMTimeMake(value: sceneBundle.currentTimeMilliseconds, timescale: GVC.preferredTimescale))
        timelineView.updateTrackItemViews(timeline: timeline, footages: sceneBundle.footages)
        timelineView.updateNodeItemViews(nodes: sceneBundle.nodes)
        timelineView.resetBottomView(bottomViewType: .timeline)
    }

    private func addPeriodicTimeObserver() {

        let interval: CMTime = CMTimeMake(value: 1, timescale: 100)
        periodicTimeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {
            [weak self] currentTime in
            guard let s = self else { return }
            s.currentTime = currentTime
        }
    }

    private func removePeriodicTimeObserver() {

        if let timeObserver = periodicTimeObserver {
            player.removeTimeObserver(timeObserver)
            periodicTimeObserver = nil
        }
    }

    private func updateViewsWhenTimeElapsed(to time: CMTime) {

        currentTimeLabel.text = time.toString()
        timelineView.autoScroll(to: time)
        playerView.showOrHideNodeViews(at: time)
    }
}
