///
/// GameEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AwaitToast
import CoreData
import Instructions
import Kingfisher
import SnapKit
import UIKit

class GameEditorViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let topButtonContainerWidth: CGFloat = 64
        static let topRightButtonContainerWidth: CGFloat = 52
        static let topButtonContainerPadding: CGFloat = 12
        static let gameTitleLabelFontSize: CGFloat = 16
        static let gameboardViewWidth: CGFloat = 1560 /* 960 */
        static let gameboardViewHeight: CGFloat = 2080 /* 1280 */
        static let gameboardViewGridWidth: CGFloat = 8
    }

    /// 父视图控制器类型枚举值
    enum GameEditorParentViewControllerType: Int {
        case unspecified = 1
        case new = 2
        case draft = 3
    }

    /// 引导标记控制器
    var coachMarksController: CoachMarksController!

    /// 返回按钮
    var backButton: CircleNavigationBarButton!
    /// 发布按钮
    var publishButton: CircleNavigationBarButton!
    /// 作品设置按钮
    var gameSettingsButton: CircleNavigationBarButton!
    /// 作品标题标签
    var gameTitleLabel: UILabel!
    /// 作品板视图容器
    var gameboardViewContainer: UIScrollView!
    /// 作品板视图
    var gameboardView: GameEditorGameboardView!
    /// 场景视图列表
    var sceneViewList: [GameEditorSceneView]!
    /// 穿梭器视图列表
    var transitionViewList: [GameEditorTransitionView]!

    /// 添加场景提示器视图
    var addSceneIndicatorView: AddSceneIndicatorView!
    var addTransitionDiagramView: AddTransitionDiagramView!

    /// 底部视图容器
    var bottomViewContainer: UIView!
    /// 默认底部视图
    var defaultBottomView: GameEditorDefaultBottomView!
    /// 即将添加场景底部视图
    var willAddSceneBottomView: GameEditorWillAddSceneBottomView!
    /// 场景底部视图
    var sceneBottomView: GameEditorSceneBottomView!

    /// 作品
    var game: MetaGame!
    /// 作品资源包
    var gameBundle: MetaGameBundle!

    /// 父视图控制器类型
    var parentType: GameEditorParentViewControllerType!
    /// 场景已保存消息
    var sceneSavedMessage: String?
    /// 是否需要重新计算内容偏移量
    var needsContentOffsetUpdate: Bool = false
    /// 即将添加场景
    var willAddScene: Bool = false

    /// 初始化
    init(game: MetaGame, gameBundle: MetaGameBundle, parentType: GameEditorParentViewControllerType = .unspecified) {

        super.init(nibName: nil, bundle: nil)

        self.game = game
        self.gameBundle = gameBundle

        self.parentType = parentType
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 视图加载完成
    override func viewDidLoad() {

        super.viewDidLoad()

        // 重置父视图控制器

        resetParentViewControllers()

        // 初始化视图

        initViews()

        // 初始化全部场景和穿梭器视图

        initAllSceneAndTransitionViews()

        // 加载场景缩略图

        loadSceneThumbImages()

        // 初始化「引导标记控制器」

        initCoachMarksController()
    }

    /// 重置父视图控制器
    private func resetParentViewControllers() {

        if parentType == .new { // 如果刚刚从 NewGameViewController 跳转过来，则在返回上级时直接跳过 NewGameViewController
            guard var viewControllers = navigationController?.viewControllers else { return }
            viewControllers.remove(at: viewControllers.count - 2)
            navigationController?.setViewControllers(viewControllers, animated: false)
            parentType = .draft
        }
    }

    /// 加载场景缩略图
    private func loadSceneThumbImages() {

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let s = self else { return }
            for sceneView in s.sceneViewList {
                let url = MetaThumbManager.shared.getThumbImageFileURL(uuid: sceneView.scene.uuid, gameUUID: s.gameBundle.uuid)
                if FileManager.default.fileExists(atPath: url.path) {
                    DispatchQueue.main.async {
                        sceneView.thumbImageView.kf.setImage(with: url)
                    }
                }
            }
        }
    }

    /// 视图即将显示
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // 隐藏导航栏

        navigationController?.navigationBar.isHidden = true

        // 本方法一定要在 viewWillAppear 中调用
        // 确保每次显示视图时，都会重新加载「作品板视图外部变更记录」

        performGameboardViewExternalChanges() // 为了提高作品板视图的加载性能，仅更新在外部发生过变化的视图

        // 更新「当前选中场景」相关的视图

        updateSelectionRelatedViews()
    }

    /// 视图显示完成
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        // 显示消息

        showMessage()

        // 显示引导标记

        showCoachMarks()
    }

    /// 显示消息
    private func showMessage() {

        if let sceneSavedMessage = sceneSavedMessage {
            let toast = Toast.default(text: sceneSavedMessage)
            toast.show()
            self.sceneSavedMessage = nil
        }
    }

    /// 视图即将消失
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        // 保存作品资源包

        saveGameBundle()

        // 提示已保存

        sendSavedMessage()

        //隐藏引导标记

        hideCoachMarks()
    }

    /// 保存作品资源包
    private func saveGameBundle() {

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let s = self else { return }
            MetaGameBundleManager.shared.save(s.gameBundle)
        }
    }

    /// 提示已保存
    private func sendSavedMessage() {

        let title: String = (game.title.count > 8) ? game.title.prefix(8) + "..." : game.title
        if let parent = navigationController?.viewControllers[0] as? CompositionViewController {
            parent.draftSavedMessage = title + " " + NSLocalizedString("SavedToDrafts", comment: "")
        }
    }

    /// 视图已经消失
    override func viewDidDisappear(_ animated: Bool) {

        super.viewDidDisappear(animated)

        unhighlightSelectionRelatedViews()
    }

    /// 取消高亮显示「先前选中场景」相关的场景视图
    private func unhighlightSelectionRelatedViews() {

        let previousSelectedSceneIndex = gameBundle.selectedSceneIndex
        let previousSelectedSceneView = sceneViewList.first(where: { $0.scene.index == previousSelectedSceneIndex })
        previousSelectedSceneView?.isActive = false
        unhighlightRelatedSceneViews(sceneView: previousSelectedSceneView)
        unhighlightRelatedTransitionViews(sceneView: previousSelectedSceneView)
    }

    /// 重写用户界面风格变化处理方法
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)

        updateViewsWhenTraitCollectionChanged()
    }

    /// 外观切换后更新视图
    private func updateViewsWhenTraitCollectionChanged() {

        // 更新「作品标题标签」的图层阴影颜色

        gameTitleLabel.layer.shadowColor = UIColor.secondarySystemBackground.cgColor

        // 重置全部「穿梭器视图」

        for transitionView in transitionViewList {
            transitionView.unhighlight()
        }

        // 更新「当前选中场景」相关的穿梭器视图、场景视图

        if gameBundle.selectedSceneIndex != 0 {
            let sceneView = sceneViewList.first(where: { $0.scene.index == gameBundle.selectedSceneIndex })
            highlightRelatedTransitionViews(sceneView: sceneView) // 高亮显示「当前选中场景」相关的穿梭器视图
            highlightRelatedSceneViews(sceneView: sceneView) // 高亮显示「当前选中场景」相关的场景视图
        }

        // 隐藏「添加场景提示器视图」

        addSceneIndicatorView.isHidden = true
    }

    /// 初始化视图
    private func initViews() {

        view.backgroundColor = .systemBackground

        // 初始化「作品板视图容器」

        gameboardViewContainer = UIScrollView()
        gameboardViewContainer.delegate = self
        gameboardViewContainer.scrollsToTop = false // 禁止点击状态栏滚动至视图顶部
        gameboardViewContainer.backgroundColor = .secondarySystemBackground
        gameboardViewContainer.contentInsetAdjustmentBehavior = .never
        gameboardViewContainer.showsVerticalScrollIndicator = true
        gameboardViewContainer.showsHorizontalScrollIndicator = true
        gameboardViewContainer.contentSize = CGSize(width: VC.gameboardViewWidth, height: VC.gameboardViewHeight)
        gameboardViewContainer.maximumZoomScale = 1
        gameboardViewContainer.minimumZoomScale = 0.98
        view.addSubview(gameboardViewContainer)
        gameboardViewContainer.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        // 初始化「作品板视图」

        gameboardView = GameEditorGameboardView()
        gameboardView.isUserInteractionEnabled = true
        gameboardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gameboardViewDidTap)))
        gameboardView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(gameboardViewDidLongPress)))
        gameboardViewContainer.addSubview(gameboardView)
        gameboardView.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.gameboardViewWidth)
            make.height.equalTo(VC.gameboardViewHeight)
            make.left.top.equalToSuperview()
        }

        // 初始化「添加场景提示器视图」

        addSceneIndicatorView = AddSceneIndicatorView()
        addSceneIndicatorView.delegate = self
        addSceneIndicatorView.isHidden = true // 隐藏「添加场景提示器视图」
        gameboardView.addSubview(addSceneIndicatorView)
        addSceneIndicatorView.snp.makeConstraints { make -> Void in
            make.width.equalTo(AddSceneIndicatorView.VC.width)
            make.height.equalTo(AddSceneIndicatorView.VC.height)
            make.center.equalToSuperview()
        }

        // 初始化「返回按钮容器」

        let backButtonContainer: UIView = UIView()
        backButtonContainer.backgroundColor = .clear
        backButtonContainer.isUserInteractionEnabled = true
        backButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backButtonDidTap)))
        view.addSubview(backButtonContainer)
        backButtonContainer.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.topButtonContainerWidth)
            make.left.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        // 初始化「返回按钮」

        backButton = CircleNavigationBarButton(icon: .arrowBack)
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        backButtonContainer.addSubview(backButton)
        backButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.VC.width)
            make.right.bottom.equalToSuperview().offset(-VC.topButtonContainerPadding)
        }

        // 初始化「发布按钮容器」

        let publishButtonContainer: UIView = UIView()
        publishButtonContainer.backgroundColor = .clear
        publishButtonContainer.isUserInteractionEnabled = true
        publishButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(publishButtonDidTap)))
        view.addSubview(publishButtonContainer)
        let publishButtonContainerLeft: CGFloat = view.bounds.width - VC.topRightButtonContainerWidth
        publishButtonContainer.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.topRightButtonContainerWidth)
            make.height.equalTo(VC.topButtonContainerWidth)
            make.left.equalToSuperview().offset(publishButtonContainerLeft)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        // 初始化「发布按钮」

        publishButton = CircleNavigationBarButton(icon: .publish, backgroundColor: .accent, tintColor: .white, imageEdgeInset: 10) // 此处 .publish 图标稍大，所以单独设置了 imageEdgeInset
        publishButton.addTarget(self, action: #selector(publishButtonDidTap), for: .touchUpInside)
        publishButtonContainer.addSubview(publishButton)
        publishButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.VC.width)
            make.right.equalToSuperview().offset(-VC.topButtonContainerPadding)
            make.bottom.equalToSuperview().offset(-VC.topButtonContainerPadding)
        }

        // 初始化「作品设置按钮容器」

        let gameSettingsButtonContainer: UIView = UIView()
        gameSettingsButtonContainer.backgroundColor = .clear
        gameSettingsButtonContainer.isUserInteractionEnabled = true
        gameSettingsButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gameSettingsButtonDidTap)))
        view.addSubview(gameSettingsButtonContainer)
        let gameSettingsButtonContainerLeft: CGFloat = view.bounds.width - VC.topRightButtonContainerWidth * 2
        gameSettingsButtonContainer.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.topRightButtonContainerWidth)
            make.height.equalTo(VC.topButtonContainerWidth)
            make.left.equalToSuperview().offset(gameSettingsButtonContainerLeft)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        // 初始化「作品设置按钮」

        gameSettingsButton = CircleNavigationBarButton(icon: .gameSettings)
        gameSettingsButton.addTarget(self, action: #selector(gameSettingsButtonDidTap), for: .touchUpInside)
        gameSettingsButtonContainer.addSubview(gameSettingsButton)
        gameSettingsButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.VC.width)
            make.right.equalToSuperview().offset(-VC.topButtonContainerPadding)
            make.bottom.equalToSuperview().offset(-VC.topButtonContainerPadding)
        }

        // 初始化「标题标签」

        gameTitleLabel = UILabel()
        gameTitleLabel.text = game.title
        gameTitleLabel.font = .systemFont(ofSize: VC.gameTitleLabelFontSize, weight: .regular)
        gameTitleLabel.textColor = .mgLabel
        gameTitleLabel.numberOfLines = 2
        gameTitleLabel.lineBreakMode = .byTruncatingTail
        gameTitleLabel.layer.shadowOffset = .zero
        gameTitleLabel.layer.shadowOpacity = 1
        gameTitleLabel.layer.shadowRadius = 1
        gameTitleLabel.layer.shadowColor = UIColor.secondarySystemBackground.cgColor
        view.addSubview(gameTitleLabel)
        gameTitleLabel.snp.makeConstraints { make -> Void in
            make.centerY.equalTo(backButton)
            make.left.equalTo(backButtonContainer.snp.right).offset(8)
            make.right.equalTo(gameSettingsButtonContainer.snp.left).offset(-8)
        }

        // 初始化「添加穿梭器示意图视图」

        addTransitionDiagramView = AddTransitionDiagramView()
        addTransitionDiagramView.isHidden = true
        addTransitionDiagramView.isUserInteractionEnabled = true
        addTransitionDiagramView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addTransitionDiagramViewDidTap)))
        view.addSubview(addTransitionDiagramView)

        // 初始化「底部视图」

        bottomViewContainer = UIView()
        view.addSubview(bottomViewContainer)
    }
}

extension GameEditorViewController {

    private func initAllSceneAndTransitionViews() {

        // 初始化场景视图

        sceneViewList = [GameEditorSceneView]()

        for scene in gameBundle.scenes {
            let sceneView: GameEditorSceneView = GameEditorSceneView(scene: scene)
            sceneView.delegate = self
            gameboardView.insertSubview(sceneView, at: 0)
            sceneViewList.append(sceneView)
        }

        // 初始化穿梭器视图

        transitionViewList = [GameEditorTransitionView]()
        for transition in gameBundle.transitions {
            guard let startScene = gameBundle.findScene(index: transition.from), let endScene = gameBundle.findScene(index: transition.to) else { continue }
            let transitionView = GameEditorTransitionView(startScene: startScene, endScene: endScene)
            gameboardView.insertSubview(transitionView, at: 0)
            transitionViewList.append(transitionView)
        }
    }

    private func performGameboardViewExternalChanges() {

        let changes = GameboardViewExternalChangeManager.shared.get()
        for (key, value) in changes {
            switch key {
            case .updateGameTitle:
                gameTitleLabel.text = game.title
                break
            case .updateSceneTitle:
                if let sceneUUID = value as? String {
                    let sceneView = sceneViewList.first(where: { $0.scene.uuid == sceneUUID })
                    DispatchQueue.main.async {
                        sceneView?.updateTitleLabelAttributedText()
                    }
                }
                break
            case .updateSceneThumbImage:
                if let sceneUUID = value as? String {
                    let sceneView = sceneViewList.first(where: { $0.scene.uuid == sceneUUID })
                    if let thumbImage = MetaThumbManager.shared.loadSceneThumbImage(sceneUUID: sceneUUID, gameUUID: gameBundle.uuid) {
                        DispatchQueue.main.async {
                            sceneView?.thumbImageView.image = thumbImage
                        }
                    }
                }
                break
            case .addTransition:
                if let transition = value as? MetaTransition {
                    guard let startScene = gameBundle.findScene(index: transition.from), let endScene = gameBundle.findScene(index: transition.to) else { continue }
                    let transitionView = GameEditorTransitionView(startScene: startScene, endScene: endScene)
                    gameboardView.addSubview(transitionView)
                    transitionViewList.append(transitionView)
                }
                break
            }
        }
        GameboardViewExternalChangeManager.shared.removeAll() // 清空「作品板视图外部变更记录字典」
    }

    func updateSelectionRelatedViews() {

        // 重置底部视图

        let sceneSelected: Bool = gameBundle.selectedSceneIndex == 0 ? false : true
        resetBottomView(sceneSelected: sceneSelected, animated: false)

        // 初始化作品板视图容器的内容偏移量

        if needsContentOffsetUpdate, let scene = gameBundle.selectedScene() { // 计算「当前选中场景」的内容偏移量

            centerScene(scene, animated: false) // 尽量将「当前选中场景」视图置于中央，并保存内容偏移量

        } else { // 直接读取资源包中的内容偏移量

            var contentOffset: CGPoint = gameBundle.contentOffset
            if contentOffset == GVC.defaultGameboardViewContentOffset {
                contentOffset = CGPoint(x: (VC.gameboardViewWidth - view.bounds.width) / 2, y: (VC.gameboardViewHeight - view.bounds.height) / 2) // 当前作品板居中
            }
            gameboardViewContainer.contentOffset = contentOffset
        }
    }

    func highlightRelatedSceneViews(sceneView: GameEditorSceneView?) {

        guard let sceneView = sceneView, let scene = sceneView.scene else { return }

        for transitionView in transitionViewList {

            if transitionView.startScene.index == scene.index {

                let endSceneView = sceneViewList.first(where: { $0.scene.index == transitionView.endScene.index })
                endSceneView?.highlight()

            } else if transitionView.endScene.index == scene.index {

                let startSceneView = sceneViewList.first(where: { $0.scene.index == transitionView.startScene.index })
                startSceneView?.highlight()
            }
        }
    }

    func unhighlightRelatedSceneViews(sceneView: GameEditorSceneView?) {

        guard let sceneView = sceneView, let scene = sceneView.scene else { return }

        for transitionView in transitionViewList {

            if transitionView.startScene.index == scene.index {

                let endSceneView = sceneViewList.first(where: { $0.scene.index == transitionView.endScene.index })
                endSceneView?.unhighlight()

            } else if transitionView.endScene.index == scene.index {

                let startSceneView = sceneViewList.first(where: { $0.scene.index == transitionView.startScene.index })
                startSceneView?.unhighlight()
            }
        }
    }

    func highlightRelatedTransitionViews(sceneView: GameEditorSceneView?) {

        guard let sceneView = sceneView, let scene = sceneView.scene else { return }

        var changed: [GameEditorTransitionView] = []

        for transitionView in transitionViewList {

            if transitionView.startScene.index == scene.index {

                transitionView.highlight(isSent: true)
                changed.append(transitionView) // 以「当前选中场景」视图为起点的穿梭器在顶层

            } else if transitionView.endScene.index == scene.index {

                transitionView.highlight(isSent: false)
                changed.insert(transitionView, at: 0) // 以「当前选中场景」视图为重点的穿梭器在底层
            }
        }

        for transitionView in changed {

            bringRelatedSceneViewsToFront(transitionView: transitionView)
        }

        // 确保「添加场景提示器视图」置于最顶层

        gameboardView.bringSubviewToFront(addSceneIndicatorView)
    }

    func bringRelatedSceneViewsToFront(transitionView: GameEditorTransitionView) {

        // 将穿梭器移动至最上层

        gameboardView.bringSubviewToFront(transitionView)

        // 将穿梭器相关的场景视图移动至最上层

        guard let startSceneView = sceneViewList.first(where: { $0.scene.index == transitionView.startScene.index }) else { return }
        gameboardView.bringSubviewToFront(startSceneView)

        guard let endSceneView = sceneViewList.first(where: { $0.scene.index == transitionView.endScene.index }) else { return }
        gameboardView.bringSubviewToFront(endSceneView)
    }

    func unhighlightRelatedTransitionViews(sceneView: GameEditorSceneView?) {

        guard let sceneView = sceneView, let scene = sceneView.scene else { return }

        for transitionView in transitionViewList {

            if transitionView.startScene.index == scene.index || transitionView.endScene.index == scene.index {

                transitionView.unhighlight()
            }
        }
    }

    func centerScene(_ scene: MetaScene, animated: Bool) {

        var contentOffset = gameboardViewContainer.contentOffset
        let visibleAreaBounds = gameboardViewContainer.bounds
        let visibleAreaCenter = CGPoint(x: contentOffset.x + visibleAreaBounds.width / 2, y: contentOffset.y + visibleAreaBounds.height / 2)
        let xOffset = visibleAreaCenter.x - scene.center.x
        contentOffset.x = contentOffset.x - xOffset
        let yOffset = visibleAreaCenter.y - scene.center.y
        contentOffset.y = contentOffset.y - yOffset

        gameboardViewContainer.setContentOffset(contentOffset, animated: animated)

        // 异步保存内容偏移量

        gameBundle.contentOffset = contentOffset
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let s = self else { return }
            MetaGameBundleManager.shared.save(s.gameBundle)
        }
    }
}
