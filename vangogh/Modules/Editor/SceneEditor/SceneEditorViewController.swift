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
        static let sceneTitleLabelSmallFontSize: CGFloat = 14
        static let sceneTitleLabelLargeFontSize: CGFloat = 16
        static let workspaceViewHeight: CGFloat = 286
        static let actionBarViewHeight: CGFloat = 44
        static let playButtonHeight: CGFloat = 44
        static let playButtonImageEdgeInset: CGFloat = 10
        static let currentTimeLabelWidth: CGFloat = 44
        static let actionBarViewLabelFontSize: CGFloat = 14
        static let timeSeparatorLabelFontSize: CGFloat = 10
        static let previewButtonWidth: CGFloat = 88
        static let previewButtonMarginRight: CGFloat = 12
        static let previewButtonTitleLabelFontSize: CGFloat = 14
    }

    static let preferredUserInterfaceStyle: UIUserInterfaceStyle = .dark

    private var closeButtonContainer: UIView!
    private var closeButton: CircleNavigationBarButton!
    private var saveButtonContainer: UIView!
    private var saveButton: CircleNavigationBarButton!
    private var sceneSettingsButtonContainer: UIView!
    private var sceneSettingsButton: CircleNavigationBarButton!

    private var playerViewContainer: UIView!
    private var playerView: ScenePlayerView!
    private var loadingView: LoadingView!

    private var actionBarView: BorderedView!
    private var playButton: SceneEditorPlayButton!
    private var currentTimeLabel: UILabel!
    private var sceneDurationLabel: UILabel!
    private var previewButton: UIButton!

    private var workspaceView: UIView!
    private var workspaceNoDataView: WorkspaceNoDataView!
    private var timelineView: TimelineView!
    private var bottomSheetViewController: SheetViewController?

    private var renderSize: CGSize!

    private var sceneBundle: MetaSceneBundle!
    private var gameBundle: MetaGameBundle!

    private var player: AVPlayer!
    private var playerItem: AVPlayerItem!
    private var timeline: Timeline = Timeline()
    private var currentTime: CMTime = .zero {
        didSet {
            updateViewsWhenTimeElapsed(to: currentTime)
        }
    }
    private var periodicTimeObserver: Any?

    var needsReloadPlayer: Bool = true

    //
    //
    // MARK: - 视图生命周期
    //
    //

    init(sceneBundle: MetaSceneBundle, gameBundle: MetaGameBundle) {

        super.init(nibName: nil, bundle: nil)

        self.sceneBundle = sceneBundle
        self.gameBundle = gameBundle
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    deinit {

        removePeriodicTimeObserver()
        NotificationCenter.default.removeObserver(self)
    }

    /// 视图加载完成
    override func viewDidLoad() {

        super.viewDidLoad()

        // 单独强制设置用户界面风格

        overrideUserInterfaceStyle = SceneEditorViewController.preferredUserInterfaceStyle

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

        // 关闭先前展示的 Sheet 视图控制器（如果有的话）

        dismissPreviousBottomSheetViewController()

        // 暂停并保存资源包

        if !timeline.videoChannel.isEmpty {
            pause()
        }
        saveBundle()

        // 提示已保存

        sendSavedMessage()
    }

    ///
    private func saveBundle() {

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let s = self else { return }
            s.sceneBundle.currentTimeMilliseconds = s.currentTime.milliseconds() // 保存当前播放时刻
            MetaGameBundleManager.shared.save(s.gameBundle)
            MetaSceneBundleManager.shared.save(s.sceneBundle)
        }
    }

    ///
    private func sendSavedMessage() {

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

        // 初始化「保存按钮容器」

        saveButtonContainer = UIView()
        saveButtonContainer.backgroundColor = .clear
        saveButtonContainer.isUserInteractionEnabled = true
        saveButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(saveButtonDidTap)))
        view.addSubview(saveButtonContainer)
        let saveButtonContainerLeft: CGFloat = view.bounds.width - VC.topRightButtonContainerWidth
        saveButtonContainer.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.topRightButtonContainerWidth)
            make.height.equalTo(VC.topButtonContainerWidth)
            make.left.equalToSuperview().offset(saveButtonContainerLeft)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        // 初始化「保存按钮」

        saveButton = CircleNavigationBarButton(icon: .save)
        saveButton.addTarget(self, action: #selector(saveButtonDidTap), for: .touchUpInside)
        saveButtonContainer.addSubview(saveButton)
        saveButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.VC.width)
            make.right.equalToSuperview().offset(-VC.topButtonContainerPadding)
            make.bottom.equalToSuperview().offset(-VC.topButtonContainerPadding)
        }

        // 初始化「场景设置按钮容器」

        sceneSettingsButtonContainer = UIView()
        sceneSettingsButtonContainer.backgroundColor = .clear
        sceneSettingsButtonContainer.isUserInteractionEnabled = true
        sceneSettingsButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sceneSettingsButtonDidTap)))
        view.addSubview(sceneSettingsButtonContainer)
        let sceneSettingsButtonContainerLeft: CGFloat = view.bounds.width - VC.topRightButtonContainerWidth * 2
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

    private func initActionBarView() {

        actionBarView = BorderedView(side: .bottom)
        actionBarView.isHidden = true
        view.addSubview(actionBarView)
        actionBarView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(VC.actionBarViewHeight)
            make.left.equalToSuperview()
            make.bottom.equalTo(workspaceView.snp.top)
        }

        // 初始化播放按钮

        playButton = SceneEditorPlayButton(imageEdgeInset: VC.playButtonImageEdgeInset)
        playButton.addTarget(self, action: #selector(playButtonDidTap), for: .touchUpInside)
        actionBarView.addSubview(playButton)
        playButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.playButtonHeight)
            make.center.equalToSuperview()
        }

        // 初始化场景时长标签

        currentTimeLabel = UILabel()
        currentTimeLabel.text = "00:00"
        currentTimeLabel.font = .systemFont(ofSize: VC.actionBarViewLabelFontSize, weight: .regular)
        currentTimeLabel.textColor = .mgLabel
        actionBarView.addSubview(currentTimeLabel)
        currentTimeLabel.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.currentTimeLabelWidth)
            make.left.equalToSuperview().offset(12)
            make.top.bottom.equalToSuperview()
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

        // 初始化预览按钮

        previewButton = UIButton()
        previewButton.backgroundColor = .clear
        previewButton.tintColor = .mgLabel
        previewButton.contentHorizontalAlignment = .right
        previewButton.contentVerticalAlignment = .center
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
            make.height.equalToSuperview()
            make.centerY.equalTo(playButton)
            make.right.equalToSuperview().offset(-VC.previewButtonMarginRight)
        }
    }

    private func prepareSceneTitleLabelAttributedText() -> NSMutableAttributedString {

        let completeSceneTitleString: NSMutableAttributedString = NSMutableAttributedString(string: "")

        guard let scene = gameBundle.selectedScene() else {
            return completeSceneTitleString
        }

        // 准备场景索引

        var sceneIndexFontSize: CGFloat
        var sceneIndexColor: UIColor
        if let title = scene.title, !title.isEmpty {
            sceneIndexFontSize = VC.sceneTitleLabelSmallFontSize
            sceneIndexColor = .secondaryLabel
        } else {
            sceneIndexFontSize = VC.sceneTitleLabelLargeFontSize
            sceneIndexColor = .mgLabel!
        }
        let sceneIndexStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: sceneIndexColor, .font: UIFont.systemFont(ofSize: sceneIndexFontSize, weight: .regular)]
        // let trimmedGameTitleString: String = (gameTitle.count > 8) ? gameTitle.prefix(8) + "..." : gameTitle
        let sceneIndexString: NSAttributedString = NSAttributedString(string: /* trimmedGameTitleString + " -  " + */ NSLocalizedString("Scene", comment: "") + " " + scene.index.description, attributes: sceneIndexStringAttributes)
        completeSceneTitleString.append(sceneIndexString)

        // 准备场景标题

        if let title = scene.title, !title.isEmpty {
            let sceneTitleStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.mgLabel!, .font: UIFont.systemFont(ofSize: VC.sceneTitleLabelSmallFontSize, weight: .regular)]
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

        // 关闭先前展示的 Sheet 视图控制器（如果有的话）

        dismissPreviousBottomSheetViewController()
    }

    func timelineViewWillBeginScrolling() {

        print("[SceneEditor] timelineView will begin scrolling")

        closeButtonContainer.isUserInteractionEnabled = false
        closeButton.isEnabled = false
        saveButtonContainer.isUserInteractionEnabled = false
        saveButton.isEnabled = false
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
            saveButtonContainer.isUserInteractionEnabled = true
            saveButton.isEnabled = true
            sceneSettingsButtonContainer.isUserInteractionEnabled = true
            sceneSettingsButton.isEnabled = true
            playButton.isEnabled = true
            previewButton.isEnabled = true
            timelineView.isEnabled = true
        }
    }

    func trackItemViewDidBecomeActive(footage: MetaFootage) {

        print("[SceneEditor] trackItemView \(footage.index) did become active")

        // 关闭先前展示的 Sheet 视图控制器（如果有的话）

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

        // 展示「编辑组件项」 Sheet 视图控制器

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
        saveBundle()

        // 展示「添加组件项」 Sheet 视图控制器

        presentAddNodeItemSheetViewController(toolBarItem: toolBarItem)
    }

    func toolBarSubitemDidTap(_ toolBarSubitem: TimelineToolBarSubitem) {

        let nodeType: MetaNodeType = toolBarSubitem.nodeType
        print("[SceneEditor] toolBarSubitem \"\(nodeType)\" did tap")

        // 添加组件项

        addMetaNode(nodeType: nodeType)

        // 关闭先前展示的「添加组件项」 Sheet 视图控制器

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

            // 展示「编辑组件项」 Sheet 视图控制器

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

            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let s = self else { return }
                MetaThumbManager.shared.saveSceneThumbImage(sceneUUID: s.sceneBundle.sceneUUID, gameUUID: s.sceneBundle.gameUUID, image: thumbImage) // 保存缩略图
            }

            GameboardViewExternalChangeManager.shared.set(key: .updateSceneThumbImage, value: sceneBundle.sceneUUID) // 保存「作品板视图外部变更记录字典」
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
        saveBundle()

        // 激活「时间线-组件项」视图

        timelineView.activateNodeItemView(node: nodeView.node)

        // 展示「编辑组件项」 Sheet 视图控制器

        presentEditNodeItemSheetViewController(node: nodeView.node)
    }

    func saveBundleWhenNodeViewChanged(node: MetaNode) {

        guard let nodeTypeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: node.nodeType) else { return }
        print("[SceneEditor] save bundle when \"\(nodeTypeTitle) \(node.index)\" changed")

        // 更新组件数据

        sceneBundle.updateNode(node)

        // 保存资源包

        saveBundle()
    }
}

extension SceneEditorViewController {

    private func reloadPlayer() {

        DispatchQueue.global(qos: .background).async { [weak self] in

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
                s.removePeriodicTimeObserver() // 移除「周期时间」监听器
                NotificationCenter.default.removeObserver(s) // 移除其他全部监听器
                s.player.replaceCurrentItem(with: s.playerItem)
            }
            s.player.seek(to: CMTimeMake(value: s.sceneBundle.currentTimeMilliseconds, timescale: GVC.preferredTimescale), toleranceBefore: .zero, toleranceAfter: .zero)
            s.addPeriodicTimeObserver() // 添加「周期时间」监听器
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

extension SceneEditorViewController {

    @objc private func closeButtonDidTap() {

        print("[SceneEditor] did tap closeButton")

        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @objc private func saveButtonDidTap() {

        print("[SceneEditor] did tap saveButton")

        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @objc private func sceneSettingsButtonDidTap() {

        print("[SceneEditor] did tap sceneSettingsButton")

        openSceneSettings()
    }

    @objc private func sceneTitleLabelDidTap() {

        print("[SceneEditor] did tap sceneTitleLabel")
    }

    @objc private func playerViewContainerDidTap() {

        print("[SceneEditor] did tap playerViewContainer")

        // 关闭先前展示的 Sheet 视图控制器（如果有的话）

        dismissPreviousBottomSheetViewController()
    }

    @objc private func previewButtonDidTap() {

        print("[SceneEditor] did tap previewButton")

        previewScene()
    }

    @objc private func playButtonDidTap() {

        print("[SceneEditor] did tap playButton")

        playOrPause()
    }

    @objc private func playerItemDidPlayToEndTime() {

        print("[SceneEditor] player item did play to end time")

        loop()
    }

    @objc private func didEnterBackground() {

        print("[SceneEditor] did enter background")

        // 关闭先前展示的 Sheet 视图控制器（如果有的话）

        dismissPreviousBottomSheetViewController()

        // 暂停并保存资源包

        if !timeline.videoChannel.isEmpty {
            pause()
        }
        saveBundle()
    }

    @objc private func willEnterForeground() {

        print("[SceneEditor] will enter foreground")

        loadingView.startAnimating()
        reloadPlayer()
    }

    private func openSceneSettings() {

        let sceneSettingsVC = SceneSettingsViewController(sceneBundle: sceneBundle, gameBundle: gameBundle)
        sceneSettingsVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(sceneSettingsVC, animated: true)
    }

    private func previewScene() {

        let sceneEmulatorVC = SceneEmulatorViewController(sceneBundle: sceneBundle, gameBundle: gameBundle)
        sceneEmulatorVC.definesPresentationContext = false
        sceneEmulatorVC.modalPresentationStyle = .currentContext

        present(sceneEmulatorVC, animated: true, completion: nil)
    }

    private func playOrPause() {

        if let player = player {

            if player.timeControlStatus == .playing {

                playButton.isPlaying = false
                player.pause()

            } else {

                playButton.isPlaying = true
                player.play()

                timelineView.unselectAllTrackItemViews()
                timelineView.unselectAllNodeItemViews()
                timelineView.resetBottomView(bottomViewType: .timeline)
            }
        }
    }

    private func loop() {

        if let player = player, player.timeControlStatus == .playing {

            playButton.isPlaying = false
            player.pause()

            player.seek(to: .zero)
            player.play()
            playButton.isPlaying = true
        }
    }

    private func pause() {

        if let player = player, player.timeControlStatus == .playing {

            playButton.isPlaying = false
            player.pause()
        }
    }

    private func resume() {

        if let player = player, player.timeControlStatus != .playing {

            playButton.isPlaying = true
            player.play()

            timelineView.unselectAllTrackItemViews()
            timelineView.unselectAllNodeItemViews()
            timelineView.resetBottomView(bottomViewType: .timeline)
        }
    }

    /// 添加镜头片段
    private func addFootage() {

        let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { status in
                DispatchQueue.main.async { [weak self] in
                    guard let s = self else { return }
                    s.pushTargetAssetsVC()
                }
            })
            break
        case .authorized, .limited:
            pushTargetAssetsVC()
            break
        default:
            let alert = UIAlertController(title: NSLocalizedString("PhotoLibraryAuthorizationDenied", comment: ""), message: NSLocalizedString("PhotoLibraryAuthorizationDeniedInfo", comment: ""), preferredStyle: .alert)
            alert.overrideUserInterfaceStyle = SceneEditorViewController.preferredUserInterfaceStyle // 单独强制设置用户界面风格
            let openSettingsAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("OpenSettings", comment: ""), style: .default) { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            alert.addAction(openSettingsAction)
            let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            }
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }

    /// 进入「目标素材」
    private func pushTargetAssetsVC() {

        let targetAssetsVC = TargetAssetsViewController()
        targetAssetsVC.delegate = self
        targetAssetsVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(targetAssetsVC, animated: true)
    }

    private func deleteMetaFootage(_ footage: MetaFootage) {

        // 创建提示框

        let alert = UIAlertController(title: NSLocalizedString("DeleteFootage", comment: ""), message: NSLocalizedString("DeleteFootageInfo", comment: ""), preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = SceneEditorViewController.preferredUserInterfaceStyle // 单独强制设置用户界面风格

        // 「确认」操作

        let confirmAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { [weak self] _ in

            guard let s = self else { return }

            DispatchQueue.global(qos: .background).async {
                MetaSceneBundleManager.shared.deleteMetaFootage(sceneBundle: s.sceneBundle, footage: footage)
                DispatchQueue.main.sync {
                    s.loadingView.startAnimating()
                    s.currentTime = CMTimeMake(value: s.sceneBundle.currentTimeMilliseconds, timescale: GVC.preferredTimescale)
                    s.reloadPlayer()
                }
            }
        }
        alert.addAction(confirmAction)

        // 「取消」操作

        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
        }
        alert.addAction(cancelAction)

        // 展示提示框

        present(alert, animated: true, completion: nil)
    }

    private func addMetaNode(nodeType: MetaNodeType) {

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let s = self else { return }
            let node: MetaNode = MetaSceneBundleManager.shared.addMetaNode(sceneBundle: s.sceneBundle, nodeType: nodeType, startTimeMilliseconds: s.currentTime.milliseconds())
            DispatchQueue.main.async {
                s.playerView.addNodeView(node: node)
                s.playerView.showOrHideNodeViews(at: s.currentTime)
                s.timelineView.addNodeItemView(node: node)
                s.timelineView.updateNodeItemViewContainer()
            }
        }
    }

    private func deleteMetaNode(_ node: MetaNode) {

        // 创建提示框

        let alert = UIAlertController(title: NSLocalizedString("DeleteNode", comment: ""), message: NSLocalizedString("DeleteNodeInfo", comment: ""), preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = SceneEditorViewController.preferredUserInterfaceStyle // 单独强制设置用户界面风格

        // 「确认」操作

        let confirmAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { [weak self] _ in

            guard let s = self else { return }

            DispatchQueue.global(qos: .background).async {
                MetaSceneBundleManager.shared.deleteMetaNode(sceneBundle: s.sceneBundle, node: node)
                DispatchQueue.main.sync {

                    s.dismissPreviousBottomSheetViewController() // 关闭先前展示的 Sheet 视图控制器（如果有的话）

                    s.playerView.removeNodeView(node: node)
                    s.timelineView.removeNodeItemView(node: node)
                    s.timelineView.updateNodeItemViewContainer()
                    s.timelineView.resetBottomView(bottomViewType: .timeline)
                }
            }
        }
        alert.addAction(confirmAction)

        // 「取消」操作

        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
        }
        alert.addAction(cancelAction)

        // 展示提示框

        present(alert, animated: true, completion: nil)
    }

    private func isSceneBundleEmpty() -> Bool {

        return sceneBundle.footages.isEmpty && sceneBundle.nodes.isEmpty
    }

    private func requestPhotoLibraryAuthorization(handler: @escaping (PHAuthorizationStatus) -> Void) {

        let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { status in
                DispatchQueue.main.async {
                    handler(status)
                }
            })
        } else {
            handler(status)
        }
    }
}

extension SceneEditorViewController {

    private func presentAddNodeItemSheetViewController(toolBarItem: TimelineToolBarItem) {

        // 关闭先前展示的 Sheet 视图控制器（如果有的话）

        dismissPreviousBottomSheetViewController()

        // 展示「添加组件项」 Sheet 视图控制器

        let addNodeItemVC: AddNodeItemViewController = AddNodeItemViewController(toolBarItem: toolBarItem)
        addNodeItemVC.delegate = self

        let sheetHeight: CGFloat = view.safeAreaInsets.bottom + AddNodeItemViewController.VC.height

        presentSheetViewController(controller: addNodeItemVC, sizes: [.fixed(sheetHeight)], cornerRadius: GVC.bottomSheetViewCornerRadius)
    }

    private func presentEditNodeItemSheetViewController(node: MetaNode) {

        // 关闭先前展示的 Sheet 视图控制器（如果有的话）

        dismissPreviousBottomSheetViewController()

        // 激活「播放器-组件」视图

        if let nodeView = playerView.nodeViewList.first(where: { $0.node.uuid == node.uuid }) {
            nodeView.isActive = true
        }

        // 展示「编辑组件项」 Sheet 视图控制器

        let editNodeItemVC = EditNodeItemViewController(node: node, rules: sceneBundle.findNodeRules(index: node.index))
        editNodeItemVC.delegate = self

        let minSheetHeight: CGFloat = view.safeAreaInsets.bottom + SceneEditorViewController.VC.workspaceViewHeight + SceneEditorViewController.VC.actionBarViewHeight
        let maxSheetHeight: CGFloat = view.safeAreaInsets.bottom + SceneEditorViewController.VC.workspaceViewHeight + SceneEditorViewController.VC.actionBarViewHeight + renderSize.height

        presentSheetViewController(controller: editNodeItemVC, sizes: [.fixed(minSheetHeight), .fixed(maxSheetHeight)], cornerRadius: 0)
    }

    private func presentSheetViewController(controller: UIViewController, sizes: [SheetSize], cornerRadius: CGFloat) {

        // 展示 Sheet 视图控制器

        let options: SheetOptions = SheetOptions(
            pullBarHeight: GVC.bottomSheetViewPullBarHeight,
            shouldExtendBackground: true,
            useInlineMode: true
        )

        bottomSheetViewController = SheetViewController(controller: controller, sizes: sizes, options: options)
        if let vc = bottomSheetViewController {
            vc.gripSize = CGSize(width: GVC.bottomSheetViewGripWidth, height: GVC.bottomSheetViewGripHeight)
            vc.gripColor = .mgLabel
            vc.cornerRadius = cornerRadius
            vc.allowGestureThroughOverlay = true
            vc.didDismiss = { [weak self] vc -> Void in
                guard let s = self else { return }
                s.dismissPreviousBottomSheetViewController()
            }
            vc.animateIn(to: view, in: self)
        }
    }

    private func dismissPreviousBottomSheetViewController() {

        // 取消激活全部已激活的「播放器-组件」视图

        playerView.nodeViewList.filter({ $0.isActive }).forEach {
            $0.isActive = false
        }

        // 关闭先前展示的 Sheet 视图控制器

        if let vc = bottomSheetViewController {
            vc.animateOut()
            bottomSheetViewController = nil
        }
    }
}
