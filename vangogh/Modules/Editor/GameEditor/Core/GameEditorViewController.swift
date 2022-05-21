///
/// GameEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AwaitToast
import Instructions
import OSLog
import SnapKit
import UIKit

class GameEditorViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let topButtonContainerWidth: CGFloat = 64
        static let topRightButtonContainerWidth: CGFloat = 52
        static let topButtonContainerPadding: CGFloat = 12
        static let gameTitleLabelFontSize: CGFloat = 14
    }

    /// 父视图控制器类型枚举值
    enum ParentViewControllerType: Int {
        case unspecified = 1
        case new = 2
        case draft = 3
    }

    /// 引导标记控制器
    var coachMarksController: CoachMarksController!

    /// 返回按钮
    var backButton: CircleNavigationBarButton!
    /// 发布按钮
    // var publishButton: CircleNavigationBarButton!
    /// 作品设置按钮
    var gameSettingsButton: CircleNavigationBarButton!
    /// 作品标题标签
    var gameTitleLabel: UILabel!

    /// 作品板视图
    var gameboardView: GameEditorGameboardView!

    /// 添加穿梭器示意图视图
    var addTransitionDiagramView: AddTransitionDiagramView!

    /// 底部视图容器
    var bottomViewContainer: UIView!
    /// 工具栏视图
    var toolBarView: GameEditorToolBarView!
    /// 即将添加场景视图
    var willAddSceneView: GameEditorWillAddSceneView!
    /// 场景探索器视图
    var sceneExplorerView: GameEditorSceneExplorerView!

    /// 作品
    var game: MetaGame!
    /// 作品资源包
    var gameBundle: MetaGameBundle!

    /// 父视图控制器类型
    var parentType: ParentViewControllerType!
    /// 场景已保存消息
    var sceneSavedMessage: String?

    /// 是否即将添加场景
    private(set) var willAddScene: Bool = false

    /// 初始化
    init(game: MetaGame, gameBundle: MetaGameBundle, parentType: ParentViewControllerType = .unspecified) {

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

        resetParentViewControllers()

        initViews()

        initCoachMarksController()
    }

    /// 视图即将显示
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        navigationController?.navigationBar.isHidden = true

        reloadExternalChanges()

        reloadGameBundleSession()
    }

    /// 视图显示完成
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        showMessage()

        showCoachMarks()
    }

    /// 视图即将消失
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        hideCoachMarks()

        saveGameBundle() { [weak self] in
            guard let s = self else { return }
            s.sendGameSavedMessage()
        }
    }

    /// 视图已经消失
    override func viewDidDisappear(_ animated: Bool) {

        super.viewDidDisappear(animated)

        gameboardView.unhighlightSelectionRelatedViews()
    }

    /// 重写用户界面风格变化处理方法
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)

        updateViewsWhenTraitCollectionChanged()
    }

    /// 初始化视图
    private func initViews() {

        view.backgroundColor = .systemBackground

        // 初始化「作品板视图」

        gameboardView = GameEditorGameboardView()
        gameboardView.gameDataSource = self
        gameboardView.gameDelegate = self
        view.addSubview(gameboardView)
        gameboardView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
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

        // let publishButtonContainer: UIView = UIView()
        // publishButtonContainer.backgroundColor = .clear
        // publishButtonContainer.isUserInteractionEnabled = true
        // publishButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(publishButtonDidTap)))
        // view.addSubview(publishButtonContainer)
        // let publishButtonContainerLeft: CGFloat = view.bounds.width - VC.topRightButtonContainerWidth
        // publishButtonContainer.snp.makeConstraints { make -> Void in
        //     make.width.equalTo(VC.topRightButtonContainerWidth)
        //     make.height.equalTo(VC.topButtonContainerWidth)
        //     make.left.equalToSuperview().offset(publishButtonContainerLeft)
        //     make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        // }

        // 初始化「发布按钮」

        // publishButton = CircleNavigationBarButton(icon: .publish, backgroundColor: .accent, tintColor: .mgHoneydew, imageEdgeInset: 10) // 此处 .publish 图标稍大，所以单独设置了 imageEdgeInset
        // publishButton.addTarget(self, action: #selector(publishButtonDidTap), for: .touchUpInside)
        // publishButtonContainer.addSubview(publishButton)
        // publishButton.snp.makeConstraints { make -> Void in
        //     make.width.height.equalTo(CircleNavigationBarButton.VC.width)
        //     make.right.equalToSuperview().offset(-VC.topButtonContainerPadding)
        //     make.bottom.equalToSuperview().offset(-VC.topButtonContainerPadding)
        // }

        // 初始化「作品设置按钮容器」

        let gameSettingsButtonContainer: UIView = UIView()
        gameSettingsButtonContainer.backgroundColor = .clear
        gameSettingsButtonContainer.isUserInteractionEnabled = true
        gameSettingsButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gameSettingsButtonDidTap)))
        view.addSubview(gameSettingsButtonContainer)
        // let gameSettingsButtonContainerLeft: CGFloat = view.bounds.width - VC.topRightButtonContainerWidth * 2
        let gameSettingsButtonContainerLeft: CGFloat = view.bounds.width - VC.topRightButtonContainerWidth
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
        gameTitleLabel.textColor = .secondaryLabel
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
        addTransitionDiagramView.isUserInteractionEnabled = true
        addTransitionDiagramView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addTransitionDiagramViewDidTap)))
        view.addSubview(addTransitionDiagramView)

        // 初始化「底部视图容器」

        bottomViewContainer = UIView()
        view.addSubview(bottomViewContainer)
    }
}

extension GameEditorViewController {

    /// 重置父视图控制器
    func resetParentViewControllers() {

        // 如果刚刚从 NewGameViewController 跳转过来，则在返回上级时直接跳过 NewGameViewController

        if parentType == .new {
            guard var viewControllers = navigationController?.viewControllers else { return }
            viewControllers.remove(at: viewControllers.count - 2)
            navigationController?.setViewControllers(viewControllers, animated: false)
            parentType = .draft
        }
    }

    /// 重新加载外部变更记录
    func reloadExternalChanges() {

        let changes = GameEditorExternalChangeManager.shared.get()
        for (key, value) in changes {
            switch key {
            case .updateGameTitle:
                DispatchQueue.main.async { [weak self] in
                    guard let s = self else { return }
                    s.gameTitleLabel.text = s.game.title
                }
                break
            case .updateSceneTitle:
                guard let sceneUUID = value as? String else { continue }
                DispatchQueue.main.async { [weak self] in
                    guard let s = self else { return }
                    s.gameboardView.updateSceneViewTitleLabel(sceneUUID: sceneUUID)
                }
                break
            case .updateSceneThumbImage:
                guard let sceneUUID = value as? String else { continue }
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    guard let s = self else { return }
                    if let thumbImage = MetaThumbManager.shared.loadSceneThumbImage(sceneUUID: sceneUUID, gameUUID: s.gameBundle.uuid) {
                        DispatchQueue.main.async {
                            s.gameboardView.updateSceneViewThumbImageView(sceneUUID: sceneUUID, thumbImage: thumbImage)
                        }
                    }
                }
                break
            case .addTransition:
                guard let transition = value as? MetaTransition else { continue }
                DispatchQueue.main.async { [weak self] in
                    guard let s = self else { return }
                    s.addTransitionView(transition: transition)
                }
                break
            }
        }

        GameEditorExternalChangeManager.shared.removeAll()
    }

    /// 重新加载作品资源包会话状态
    func reloadGameBundleSession() {

        if let scene = gameBundle.selectedScene() {

            gameboardView.unhighlightSelectionRelatedViews()
            saveSelectedSceneIndex(scene.index) { [weak self] in
                guard let s = self else { return }
                s.reloadSceneExplorerView(animated: false) {
                    s.gameboardView.highlightSelectionRelatedViews()
                    s.gameboardView.centerSceneView(scene: scene, animated: false) { contentOffset in
                        s.saveContentOffset(contentOffset)
                    }
                }
            }

        } else {

            gameboardView.unhighlightSelectionRelatedViews()
            saveSelectedSceneIndex(0) { [weak self] in
                guard let s = self else { return }
                s.reloadToolBarView(animated: false) {
                    var contentOffset: CGPoint = s.gameBundle.contentOffset
                    if contentOffset == GVC.defaultGameboardViewContentOffset {
                        contentOffset = CGPoint(x: (GameEditorGameboardView.VC.contentViewWidth - s.view.bounds.width) / 2, y: (GameEditorGameboardView.VC.contentViewHeight - s.view.bounds.height) / 2)
                    }
                    s.gameboardView.contentOffset = contentOffset
                }
            }
        }
    }

    /// 显示消息
    func showMessage() {

        if let sceneSavedMessage = sceneSavedMessage {
            let toast = Toast.default(text: sceneSavedMessage)
            toast.show()
            self.sceneSavedMessage = nil
        }
    }

    /// 提示作品已保存
    func sendGameSavedMessage() {

        let title: String = (game.title.count > 8) ? game.title.prefix(8) + "..." : game.title
        if let parent = navigationController?.viewControllers[0] as? CompositionViewController {
            parent.draftSavedMessage = title + " " + NSLocalizedString("Saved", comment: "")
        }
    }

    /// 外观切换后更新视图
    func updateViewsWhenTraitCollectionChanged() {

        gameTitleLabel.layer.shadowColor = UIColor.secondarySystemBackground.cgColor
    }
}

extension GameEditorViewController {

    /// 重新加载「工具栏视图」
    func reloadToolBarView(animated: Bool, completion handler: (() -> Void)? = nil) {

        willAddScene = false
        removePreviousBottomView()

        // 初始化「工具栏视图」

        bottomViewContainer.snp.updateConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(GameEditorToolBarView.VC.contentViewHeight)
            make.left.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                guard let s = self else { return }
                s.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            view.layoutIfNeeded()
        }
        toolBarView = GameEditorToolBarView()
        toolBarView.delegate = self
        bottomViewContainer.addSubview(toolBarView)
        toolBarView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        // 更新「作品板视图」

        gameboardView.snp.remakeConstraints { make -> Void in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(bottomViewContainer.snp.top)
        }

        // 隐藏「添加穿梭器示意图视图」

        addTransitionDiagramView.startSceneIndexLabel.text = ""
        addTransitionDiagramView.isHidden = true

        if let handler = handler {
            handler()
        }
    }

    /// 重新加载「即将添加场景视图」
    func reloadWillAddSceneView(animated: Bool, completion handler: (() -> Void)? = nil) {

        willAddScene = true
        removePreviousBottomView()

        // 初始化「即将添加场景视图」

        bottomViewContainer.snp.updateConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(GameEditorWillAddSceneView.VC.contentViewHeight)
            make.left.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                guard let s = self else { return }
                s.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            view.layoutIfNeeded()
        }
        willAddSceneView = GameEditorWillAddSceneView()
        willAddSceneView.delegate = self
        bottomViewContainer.addSubview(willAddSceneView)
        willAddSceneView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        // 更新「作品板视图」

        gameboardView.snp.remakeConstraints { make -> Void in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(bottomViewContainer.snp.top)
        }

        // 隐藏「添加穿梭器示意图视图」

        addTransitionDiagramView.startSceneIndexLabel.text = ""
        addTransitionDiagramView.isHidden = true

        if let handler = handler {
            handler()
        }
    }

    /// 重新加载「场景探索器视图」
    func reloadSceneExplorerView(animated: Bool, completion handler: (() -> Void)? = nil) {

        willAddScene = false
        removePreviousBottomView()

        // 初始化「场景探索器视图」

        bottomViewContainer.snp.updateConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(GameEditorSceneExplorerView.VC.contentViewHeight)
            make.left.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                guard let s = self else { return }
                s.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            view.layoutIfNeeded()
        }
        sceneExplorerView = GameEditorSceneExplorerView()
        sceneExplorerView.dataSource = self
        sceneExplorerView.delegate = self
        bottomViewContainer.addSubview(sceneExplorerView)
        sceneExplorerView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        // 更新「作品板视图」

        gameboardView.snp.remakeConstraints { make -> Void in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(bottomViewContainer.snp.top)
        }

        // 更新「添加穿梭器示意图视图」

        addTransitionDiagramView.startSceneView.image = .sceneBackgroundThumb
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let s = self else { return }
            if let scene = s.gameBundle.selectedScene(), let thumbImage = MetaThumbManager.shared.loadSceneThumbImage(sceneUUID: scene.uuid, gameUUID: s.gameBundle.uuid) {
                DispatchQueue.main.async {
                    s.addTransitionDiagramView.startSceneView.image = thumbImage
                }
            }
        }
        addTransitionDiagramView.startSceneIndexLabel.text = gameBundle.selectedSceneIndex.description
        addTransitionDiagramView.isHidden = false
        let addTransitionDiagramViewLeftOffset: CGFloat = 12
        let addTransitionDiagramViewBottomOffset: CGFloat = AddTransitionDiagramView.VC.height + 12
        addTransitionDiagramView.snp.updateConstraints { make -> Void in
            make.width.equalTo(AddTransitionDiagramView.VC.width)
            make.height.equalTo(AddTransitionDiagramView.VC.height)
            make.left.equalToSuperview().offset(addTransitionDiagramViewLeftOffset)
            make.top.equalTo(bottomViewContainer.safeAreaLayoutGuide.snp.top).offset(-addTransitionDiagramViewBottomOffset)
        }

        if let handler = handler {
            handler()
        }
    }

    /// 移除先前的「底部视图」
    private func removePreviousBottomView() {

        if toolBarView != nil {
            toolBarView.removeFromSuperview()
            toolBarView = nil
        }

        if willAddSceneView != nil {
            willAddSceneView.removeFromSuperview()
            willAddSceneView = nil
        }

        if sceneExplorerView != nil {
            sceneExplorerView.removeFromSuperview()
            sceneExplorerView = nil
        }
    }
}

extension GameEditorViewController: GameEditorToolBarViewDelegate, GameEditorWillAddSceneViewDelegate {

    func addSceneButtonDidTap() {

        reloadWillAddSceneView(animated: true) {
            Logger.gameEditor.info("will add scene view")
        }
    }

    func cancelAddingSceneButtonDidTap() {

        reloadToolBarView(animated: false) {
            Logger.gameEditor.info("cancelled adding scene view")
        }
    }
}
