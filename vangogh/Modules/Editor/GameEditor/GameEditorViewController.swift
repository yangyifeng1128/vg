///
/// GameEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AwaitToast
import CoreData
import Kingfisher
import SnapKit
import UIKit

class GameEditorViewController: UIViewController {

    // 视图布局常量枚举值

    enum ViewLayoutConstants {
        static let topButtonContainerWidth: CGFloat = 64
        static let topRightButtonContainerWidth: CGFloat = 52
        static let topButtonContainerPadding: CGFloat = 12
        static let gameTitleLabelFontSize: CGFloat = 16
        static let gameboardViewWidth: CGFloat = 1560 /* 960 */
        static let gameboardViewHeight: CGFloat = 2080 /* 1280 */
        static let gameboardViewGridWidth: CGFloat = 8
    }

    // 父视图控制器类型枚举值

    enum GameEditorParentViewControllerType: Int {
        case unspecified = 1
        case new = 2
        case draft = 3
    }

    private var backButton: CircleNavigationBarButton!
    private var publishButtonContainer: UIView!
    private var publishButton: CircleNavigationBarButton!
    private var gameSettingsButtonContainer: UIView!
    private var gameSettingsButton: CircleNavigationBarButton!
    private var gameTitleLabel: UILabel!

    private var gameboardViewContainer: UIScrollView!
    private var gameboardView: GameEditorGameboardView!
    private var sceneViewList: [GameEditorSceneView]!
    private var transitionViewList: [GameEditorTransitionView]!

    private var addSceneIndicatorView: AddSceneIndicatorView!
    private var addTransitionDiagramView: AddTransitionDiagramView!

    private var bottomViewContainer: UIView!
    private var defaultBottomView: GameEditorDefaultBottomView!
    private var willAddSceneBottomView: GameEditorWillAddSceneBottomView!
    private var sceneBottomView: GameEditorSceneBottomView!
    private var willAddScene: Bool = false

    private var game: MetaGame! // 作品
    private var gameBundle: MetaGameBundle! // 作品资源包

    private var parentType: GameEditorParentViewControllerType! // 父视图控制器类型
    var sceneSavedMessage: String? // 「场景已保存」消息
    var needsContentOffsetUpdate: Bool = false // 是否需要重新计算内容偏移量

    init(game: MetaGame, gameBundle: MetaGameBundle, parentType: GameEditorParentViewControllerType = .unspecified) {

        super.init(nibName: nil, bundle: nil)

        self.game = game
        self.gameBundle = gameBundle

        self.parentType = parentType
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    //
    //
    // MARK: - 视图生命周期
    //
    //

    override func viewDidLoad() {

        super.viewDidLoad()

        // 重置父视图控制器

        resetParentViewControllers()

        // 初始化子视图

        initSubviews()

        // 初始化全部场景和穿梭器视图

        initAllSceneAndTransitionViews()

        // 加载场景缩略图

        loadSceneThumbImages()
    }

    private func resetParentViewControllers() {

        if parentType == .new { // 如果刚刚从 NewGameViewController 跳转过来，则在返回上级时直接跳过 NewGameViewController
            guard var viewControllers = navigationController?.viewControllers else { return }
            viewControllers.remove(at: viewControllers.count - 2)
            navigationController?.setViewControllers(viewControllers, animated: false)
            parentType = .draft
        }
    }

    private func loadSceneThumbImages() {

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            for sceneView in strongSelf.sceneViewList {
                let url = MetaThumbManager.shared.getThumbImageFileURL(uuid: sceneView.scene.uuid, gameUUID: strongSelf.gameBundle.uuid)
                if FileManager.default.fileExists(atPath: url.path) {
                    DispatchQueue.main.async {
                        sceneView.thumbImageView.kf.setImage(with: url)
                    }
                }
            }
        }
    }

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

    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        // 显示消息

        showMessage()
    }

    private func showMessage() {

        if let sceneSavedMessage = sceneSavedMessage {
            let toast = Toast.default(text: sceneSavedMessage)
            toast.show()
            self.sceneSavedMessage = nil
        }
    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        // 保存作品资源包

        saveGameBundle()

        // 提示已保存

        sendSavedMessage()
    }

    private func saveGameBundle() {

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            MetaGameBundleManager.shared.save(strongSelf.gameBundle)
        }
    }

    private func sendSavedMessage() {

        let title: String = (game.title.count > 8) ? game.title.prefix(8) + "..." : game.title
        if let parent = navigationController?.viewControllers[0] as? CompositionViewController {
            parent.gameSavedMessage = title + " " + NSLocalizedString("SavedToDrafts", comment: "")
        }
    }

    override func viewDidDisappear(_ animated: Bool) {

        super.viewDidDisappear(animated)

        // 取消高亮显示「先前选中场景」相关的场景视图

        unhighlightSelectionRelatedViews()
    }

    private func unhighlightSelectionRelatedViews() {

        let previousSelectedSceneIndex = gameBundle.selectedSceneIndex
        let previousSelectedSceneView = sceneViewList.first(where: { $0.scene.index == previousSelectedSceneIndex })
        previousSelectedSceneView?.isActive = false
        unhighlightRelatedSceneViews(sceneView: previousSelectedSceneView)
        unhighlightRelatedTransitionViews(sceneView: previousSelectedSceneView)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)

        // 外观切换后更新视图

        updateViewsWhenTraitCollectionChanged()
    }

    private func updateViewsWhenTraitCollectionChanged() {

        // 更新作品标题标签的图层阴影颜色

        gameTitleLabel.layer.shadowColor = UIColor.secondarySystemBackground.cgColor

        // 重置全部穿梭器视图

        for transitionView in transitionViewList {
            transitionView.unhighlight()
        }

        // 更新「当前选中场景」相关的穿梭器视图、场景视图

        if gameBundle.selectedSceneIndex != 0 {
            let sceneView = sceneViewList.first(where: { $0.scene.index == gameBundle.selectedSceneIndex })
            highlightRelatedTransitionViews(sceneView: sceneView) // 高亮显示「当前选中场景」相关的穿梭器视图
            highlightRelatedSceneViews(sceneView: sceneView) // 高亮显示「当前选中场景」相关的场景视图
        }

        // 隐藏「添加场景提示器」视图

        addSceneIndicatorView.isHidden = true
    }

    private func initSubviews() {

        view.backgroundColor = .systemBackground

        // 初始化作品板视图

        initGameboardView()

        // 初始化导航栏

        initNavigationBar()

        // 初始化操作栏视图

        initActionBarView()

        // 初始化底部视图

        initBottomView()
    }

    private func initGameboardView() {

        // 初始化作品板视图

        gameboardViewContainer = UIScrollView()
        gameboardViewContainer.delegate = self
        gameboardViewContainer.scrollsToTop = false // 禁止点击状态栏滚动至视图顶部
        gameboardViewContainer.backgroundColor = .secondarySystemBackground
        gameboardViewContainer.contentInsetAdjustmentBehavior = .never
        gameboardViewContainer.showsVerticalScrollIndicator = true
        gameboardViewContainer.showsHorizontalScrollIndicator = true
        gameboardViewContainer.contentSize = CGSize(width: ViewLayoutConstants.gameboardViewWidth, height: ViewLayoutConstants.gameboardViewHeight)
        gameboardViewContainer.maximumZoomScale = 1
        gameboardViewContainer.minimumZoomScale = 0.98
        view.addSubview(gameboardViewContainer)
        gameboardViewContainer.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        gameboardView = GameEditorGameboardView()
        gameboardView.isUserInteractionEnabled = true
        gameboardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gameboardViewDidTap)))
        gameboardView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(gameboardViewDidLongPress)))
        gameboardViewContainer.addSubview(gameboardView)
        gameboardView.snp.makeConstraints { make -> Void in
            make.width.equalTo(ViewLayoutConstants.gameboardViewWidth)
            make.height.equalTo(ViewLayoutConstants.gameboardViewHeight)
            make.left.top.equalToSuperview()
        }

        // 初始化「添加场景提示器」视图

        addSceneIndicatorView = AddSceneIndicatorView()
        addSceneIndicatorView.delegate = self
        addSceneIndicatorView.isHidden = true // 隐藏「添加场景提示器」视图
        gameboardView.addSubview(addSceneIndicatorView)
        addSceneIndicatorView.snp.makeConstraints { make -> Void in
            make.width.equalTo(AddSceneIndicatorView.ViewLayoutConstants.width)
            make.height.equalTo(AddSceneIndicatorView.ViewLayoutConstants.height)
            make.center.equalToSuperview()
        }
    }

    private func initNavigationBar() {

        // 初始化返回按钮

        let backButtonContainer: UIView = UIView()
        backButtonContainer.backgroundColor = .clear
        backButtonContainer.isUserInteractionEnabled = true
        backButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backButtonDidTap)))
        view.addSubview(backButtonContainer)
        backButtonContainer.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(ViewLayoutConstants.topButtonContainerWidth)
            make.left.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        backButton = CircleNavigationBarButton(icon: .arrowBack)
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        backButtonContainer.addSubview(backButton)
        backButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.ViewLayoutConstants.width)
            make.right.bottom.equalToSuperview().offset(-ViewLayoutConstants.topButtonContainerPadding)
        }

        // 初始化发布按钮

        publishButtonContainer = UIView()
        publishButtonContainer.backgroundColor = .clear
        publishButtonContainer.isUserInteractionEnabled = true
        publishButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(publishButtonDidTap)))
        view.addSubview(publishButtonContainer)
        let publishButtonContainerLeft: CGFloat = view.bounds.width - ViewLayoutConstants.topRightButtonContainerWidth
        publishButtonContainer.snp.makeConstraints { make -> Void in
            make.width.equalTo(ViewLayoutConstants.topRightButtonContainerWidth)
            make.height.equalTo(ViewLayoutConstants.topButtonContainerWidth)
            make.left.equalToSuperview().offset(publishButtonContainerLeft)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        publishButton = CircleNavigationBarButton(icon: .publish, backgroundColor: .accent, tintColor: .white, imageEdgeInset: 10) // 此处 .publish 图标稍大，所以单独设置了 imageEdgeInset
        publishButton.addTarget(self, action: #selector(publishButtonDidTap), for: .touchUpInside)
        publishButtonContainer.addSubview(publishButton)
        publishButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.ViewLayoutConstants.width)
            make.right.equalToSuperview().offset(-ViewLayoutConstants.topButtonContainerPadding)
            make.bottom.equalToSuperview().offset(-ViewLayoutConstants.topButtonContainerPadding)
        }

        // 初始化作品设置按钮

        gameSettingsButtonContainer = UIView()
        gameSettingsButtonContainer.backgroundColor = .clear
        gameSettingsButtonContainer.isUserInteractionEnabled = true
        gameSettingsButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gameSettingsButtonDidTap)))
        view.addSubview(gameSettingsButtonContainer)
        let gameSettingsButtonContainerLeft: CGFloat = view.bounds.width - ViewLayoutConstants.topRightButtonContainerWidth * 2
        gameSettingsButtonContainer.snp.makeConstraints { make -> Void in
            make.width.equalTo(ViewLayoutConstants.topRightButtonContainerWidth)
            make.height.equalTo(ViewLayoutConstants.topButtonContainerWidth)
            make.left.equalToSuperview().offset(gameSettingsButtonContainerLeft)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        gameSettingsButton = CircleNavigationBarButton(icon: .gameSettings)
        gameSettingsButton.addTarget(self, action: #selector(gameSettingsButtonDidTap), for: .touchUpInside)
        gameSettingsButtonContainer.addSubview(gameSettingsButton)
        gameSettingsButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.ViewLayoutConstants.width)
            make.right.equalToSuperview().offset(-ViewLayoutConstants.topButtonContainerPadding)
            make.bottom.equalToSuperview().offset(-ViewLayoutConstants.topButtonContainerPadding)
        }

        // 初始化标题标签

        gameTitleLabel = UILabel()
        gameTitleLabel.text = game.title
        gameTitleLabel.font = .systemFont(ofSize: ViewLayoutConstants.gameTitleLabelFontSize, weight: .regular)
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
    }

    private func initActionBarView() {

        addTransitionDiagramView = AddTransitionDiagramView()
        addTransitionDiagramView.isHidden = true
        addTransitionDiagramView.isUserInteractionEnabled = true
        addTransitionDiagramView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addTransitionDiagramViewDidTap)))
        view.addSubview(addTransitionDiagramView)

    }

    private func initBottomView() {

        // 初始化底部视图容器

        bottomViewContainer = UIView()
        view.addSubview(bottomViewContainer)
    }
}

extension GameEditorViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        // 滚动到边缘时，停止滚动

        var contentOffset = scrollView.contentOffset

        let minX: CGFloat = 0
        let maxX: CGFloat = ViewLayoutConstants.gameboardViewWidth - scrollView.bounds.width
        if contentOffset.x < minX {
            contentOffset.x = minX
        } else if contentOffset.x > maxX {
            contentOffset.x = maxX
        }

        let minY: CGFloat = 0
        let maxY: CGFloat = ViewLayoutConstants.gameboardViewHeight - scrollView.bounds.height
        if contentOffset.y < minY {
            contentOffset.y = minY
        } else if contentOffset.y > maxY {
            contentOffset.y = maxY
        }

        // 滚动视图

        scrollView.contentOffset = contentOffset

        // 异步保存内容偏移量

        gameBundle.contentOffset = contentOffset
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            MetaGameBundleManager.shared.save(strongSelf.gameBundle)
        }
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {

        return gameboardView
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {

        scrollView.setZoomScale(1, animated: true)
    }
}

extension GameEditorViewController: GameEditorDefaultBottomViewDelegate, GameEditorWillAddSceneBottomViewDelegate, GameEditorSceneBottomViewDelegate {

    func addSceneButtonDidTap() {

        print("[GameEditor] did tap addSceneButton")

        willAddScene = true
        resetBottomView(sceneSelected: false, animated: true)
    }

    func cancelAddingSceneButtonDidTap() {

        print("[GameEditor] did tap cancelAddingSceneButton")

        willAddScene = false
        resetBottomView(sceneSelected: false, animated: true)
    }

    func closeSceneButtonDidTap() {

        print("[GameEditor] did tap closeSceneButton")

        closeScene()
    }

    func deleteSceneButtonDidTap() {

        print("[GameEditor] did tap deleteSceneButton")

        deleteScene()
    }

    func editSceneTitleButtonDidTap() {

        print("[GameEditor] did tap editSceneTitleButton")

        editSceneTitle()
    }

    func sceneTitleLabelDidTap() {

        print("[GameEditor] did tap editSceneTitleButton")

        editSceneTitle()
    }

    func manageTransitionsButtonDidTap() {

        print("[GameEditor] did tap manageTransitionsButton")

        manageTransitions()
    }

    func previewSceneButtonDidTap() {

        print("[GameEditor] did tap previewSceneButton")

        previewScene()
    }

    func editSceneButtonDidTap() {

        print("[GameEditor] did tap editSceneButton")

        editScene()
    }

    func transitionWillDelete(_ transition: MetaTransition, completion: @escaping () -> Void) {

        print("[GameEditor] will delete transition: \(transition)")

        deleteTransition(transition, completion: completion)
    }

    func transitionDidSelect(_ transition: MetaTransition) {

        print("[GameEditor] did select transition: \(transition)")

        let transitionEditorVC = TransitionEditorViewController(gameBundle: gameBundle, transition: transition)
        transitionEditorVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(transitionEditorVC, animated: true)
    }
}

extension GameEditorViewController: GameEditorSceneViewDelegate {

    func sceneViewDidTap(_ sceneView: GameEditorSceneView) {

        print("[GameEditor] did tap gameEditorSceneView")

        selectScene(sceneView, animated: true)
    }

    func sceneViewIsMoving(scene: MetaScene) {

        // 移动场景视图到边缘时，停止移动

        var location: CGPoint = scene.center

        let minX: CGFloat = GameEditorSceneView.ViewLayoutConstants.width
        let maxX: CGFloat = ViewLayoutConstants.gameboardViewWidth - GameEditorSceneView.ViewLayoutConstants.width
        if location.x < minX {
            location.x = minX
        } else if location.x > maxX {
            location.x = maxX
        }

        let minY: CGFloat = GameEditorSceneView.ViewLayoutConstants.height
        let maxY: CGFloat = ViewLayoutConstants.gameboardViewHeight - GameEditorSceneView.ViewLayoutConstants.height
        if location.y < minY {
            location.y = minY
        } else if location.y > maxY {
            location.y = maxY
        }

        scene.center = location

        // 更新「当前被移动场景」相关的穿梭器视图的位置

        for transitionView in transitionViewList {
            if transitionView.startScene.index == scene.index {
                transitionView.startScene = scene
                transitionView.updateView()
            } else if transitionView.endScene.index == scene.index {
                transitionView.endScene = scene
                transitionView.updateView()
            }
        }
    }

    func sceneViewDidPan(scene: MetaScene) {

        print("[GameEditor] did pan gameEditorSceneView")

        // 异步保存「当前被移动场景」的位置

        gameBundle.updateScene(scene)
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            MetaGameBundleManager.shared.save(strongSelf.gameBundle)
        }
    }

    func sceneViewDidLongPress(_ sceneView: GameEditorSceneView) {

        print("[GameEditor] did long press gameEditorSceneView")

        UIImpactFeedbackGenerator().impactOccurred()

        // 弹出提示框

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // 编辑场景标题

        alert.addAction(UIAlertAction(title: NSLocalizedString("EditTitle", comment: ""), style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            // 弹出编辑场景标题提示框
            strongSelf.editSceneTitle()
        })

        // 删除场景

        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            // 弹出删除场景提示框
            strongSelf.deleteScene()
        })

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
        })

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sceneView
            popoverController.sourceRect = sceneView.bounds
        } // 兼容 iPad 应用

        present(alert, animated: true, completion: nil)
    }
}

extension GameEditorViewController: AddSceneIndicatorViewDelegate {

    func addSceneIndicatorViewDidTap(_ view: AddSceneIndicatorView) {

        print("[GameEditor] did tap AddSceneIndicatorView")

        // 添加场景方式二

        let location = CGPoint(x: view.center.x, y: view.center.y + AddSceneIndicatorView.ViewLayoutConstants.closeButtonWidth / 4)
        doAddScene(center: location, forceSelection: true)
    }

    func addSceneIndicatorViewCloseButtonDidTap() {

        print("[GameEditor] did tap AddSceneIndicatorView's closeButton")

        // 隐藏「添加场景提示器」视图

        addSceneIndicatorView.isHidden = true
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

    private func updateSelectionRelatedViews() {

        // 重置底部视图

        let sceneSelected: Bool = gameBundle.selectedSceneIndex == 0 ? false : true
        resetBottomView(sceneSelected: sceneSelected, animated: false)

        // 初始化作品板视图容器的内容偏移量

        if needsContentOffsetUpdate, let scene = gameBundle.selectedScene() { // 计算「当前选中场景」的内容偏移量

            centerScene(scene, animated: false) // 尽量将「当前选中场景」视图置于中央，并保存内容偏移量

        } else { // 直接读取资源包中的内容偏移量

            var contentOffset: CGPoint = gameBundle.contentOffset
            if contentOffset == GlobalViewLayoutConstants.defaultGameboardViewContentOffset {
                contentOffset = CGPoint(x: (ViewLayoutConstants.gameboardViewWidth - view.bounds.width) / 2, y: (ViewLayoutConstants.gameboardViewHeight - view.bounds.height) / 2) // 当前作品板居中
            }
            gameboardViewContainer.contentOffset = contentOffset
        }
    }

    private func resetBottomView(sceneSelected: Bool, animated: Bool) {

        if defaultBottomView != nil {
            defaultBottomView.removeFromSuperview()
            defaultBottomView = nil
        }
        if willAddSceneBottomView != nil {
            willAddSceneBottomView.removeFromSuperview()
            willAddSceneBottomView = nil
        }
        if sceneBottomView != nil {
            sceneBottomView.removeFromSuperview()
            sceneBottomView = nil
        }

        if sceneSelected {

            // 更新底部视图容器

            bottomViewContainer.snp.updateConstraints { make -> Void in
                make.width.equalToSuperview()
                make.height.equalTo(GameEditorSceneBottomView.ViewLayoutConstants.contentViewHeight)
                make.left.equalToSuperview()
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }
            if animated {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.view.layoutIfNeeded()
                }, completion: nil)
            } else {
                view.layoutIfNeeded()
            }

            sceneBottomView = GameEditorSceneBottomView(gameBundle: gameBundle)
            sceneBottomView.delegate = self
            bottomViewContainer.addSubview(sceneBottomView)
            sceneBottomView.snp.makeConstraints { make -> Void in
                make.edges.equalToSuperview()
            }

            // 更新作品板视图容器

            gameboardViewContainer.snp.remakeConstraints { make -> Void in
                make.left.right.top.equalToSuperview()
                make.bottom.equalTo(bottomViewContainer.snp.top)
            }

            // 更新「当前选中场景」及其相关的穿梭器视图、场景视图

            let sceneView = sceneViewList.first(where: { $0.scene.index == gameBundle.selectedSceneIndex })
            sceneView?.isActive = true
            highlightRelatedTransitionViews(sceneView: sceneView) // 高亮显示「当前选中场景」相关的穿梭器视图
            highlightRelatedSceneViews(sceneView: sceneView) // 高亮显示「当前选中场景」相关的场景视图

            // 隐藏「添加场景提示器」视图

            addSceneIndicatorView.isHidden = true

            // 显示操作栏视图，包括「添加穿梭器示意图」视图

            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let strongSelf = self else { return }
                if let sceneView = sceneView, let thumbImage = MetaThumbManager.shared.loadSceneThumbImage(sceneUUID: sceneView.scene.uuid, gameUUID: strongSelf.gameBundle.uuid) {
                    DispatchQueue.main.async {
                        strongSelf.addTransitionDiagramView.startSceneView.image = thumbImage
                    }
                } else {
                    DispatchQueue.main.async {
                        strongSelf.addTransitionDiagramView.startSceneView.image = .sceneBackgroundThumb
                    }
                }
            }
            addTransitionDiagramView.startSceneIndexLabel.text = gameBundle.selectedSceneIndex.description
            addTransitionDiagramView.isHidden = sceneViewList.count > 1 ? false : true
            let addTransitionDiagramViewLeftOffset: CGFloat = 12
            let addTransitionDiagramViewBottomOffset: CGFloat = AddTransitionDiagramView.ViewLayoutConstants.height + 12
            addTransitionDiagramView.snp.updateConstraints { make -> Void in
                make.width.equalTo(AddTransitionDiagramView.ViewLayoutConstants.width)
                make.height.equalTo(AddTransitionDiagramView.ViewLayoutConstants.height)
                make.left.equalToSuperview().offset(addTransitionDiagramViewLeftOffset)
                make.top.equalTo(bottomViewContainer.safeAreaLayoutGuide.snp.top).offset(-addTransitionDiagramViewBottomOffset)
            }

        } else {

            // 更新底部视图容器

            if !willAddScene {

                bottomViewContainer.snp.updateConstraints { make -> Void in
                    make.width.equalToSuperview()
                    make.height.equalTo(GameEditorDefaultBottomView.ViewLayoutConstants.contentViewHeight)
                    make.left.equalToSuperview()
                    make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                }
                if animated {
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.view.layoutIfNeeded()
                    }, completion: nil)
                } else {
                    view.layoutIfNeeded()
                }

                defaultBottomView = GameEditorDefaultBottomView()
                defaultBottomView.delegate = self
                bottomViewContainer.addSubview(defaultBottomView)
                defaultBottomView.snp.makeConstraints { make -> Void in
                    make.edges.equalToSuperview()
                }

            } else {

                bottomViewContainer.snp.updateConstraints { make -> Void in
                    make.width.equalToSuperview()
                    make.height.equalTo(GameEditorWillAddSceneBottomView.ViewLayoutConstants.contentViewHeight)
                    make.left.equalToSuperview()
                    make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                }
                if animated {
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.view.layoutIfNeeded()
                    }, completion: nil)
                } else {
                    view.layoutIfNeeded()
                }

                willAddSceneBottomView = GameEditorWillAddSceneBottomView()
                willAddSceneBottomView.delegate = self
                bottomViewContainer.addSubview(willAddSceneBottomView)
                willAddSceneBottomView.snp.makeConstraints { make -> Void in
                    make.edges.equalToSuperview()
                }
            }

            // 更新作品板视图容器

            gameboardViewContainer.snp.remakeConstraints { make -> Void in
                make.left.right.top.equalToSuperview()
                make.bottom.equalTo(bottomViewContainer.snp.top)
            }

            // 重置「先前选中场景」及其相关的穿梭器视图

            if let previousSelectedSceneView = sceneViewList.first(where: { $0.scene.index == gameBundle.selectedSceneIndex }) {
                previousSelectedSceneView.isActive = false
                // 取消高亮显示「先前选中场景」相关的穿梭器视图
                unhighlightRelatedTransitionViews(sceneView: previousSelectedSceneView)
                // 取消高亮显示「先前选中场景」相关的场景视图
                unhighlightRelatedSceneViews(sceneView: previousSelectedSceneView)
            }

            // 隐藏「添加场景提示器」视图

            addSceneIndicatorView.isHidden = true

            // 隐藏操作栏视图，包括「添加穿梭器示意图」视图

            addTransitionDiagramView.startSceneIndexLabel.text = ""
            addTransitionDiagramView.isHidden = true

            // 异步保存「当前选中场景」的索引为 0

            gameBundle.selectedSceneIndex = 0
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let strongSelf = self else { return }
                MetaGameBundleManager.shared.save(strongSelf.gameBundle)
            }
        }
    }

    private func highlightRelatedSceneViews(sceneView: GameEditorSceneView?) {

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

    private func unhighlightRelatedSceneViews(sceneView: GameEditorSceneView?) {

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

    private func highlightRelatedTransitionViews(sceneView: GameEditorSceneView?) {

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

        // 确保「添加场景提示器」视图置于最顶层

        gameboardView.bringSubviewToFront(addSceneIndicatorView)
    }

    private func bringRelatedSceneViewsToFront(transitionView: GameEditorTransitionView) {

        // 将穿梭器移动至最上层

        gameboardView.bringSubviewToFront(transitionView)

        // 将穿梭器相关的场景视图移动至最上层

        guard let startSceneView = sceneViewList.first(where: { $0.scene.index == transitionView.startScene.index }) else { return }
        gameboardView.bringSubviewToFront(startSceneView)

        guard let endSceneView = sceneViewList.first(where: { $0.scene.index == transitionView.endScene.index }) else { return }
        gameboardView.bringSubviewToFront(endSceneView)
    }

    private func unhighlightRelatedTransitionViews(sceneView: GameEditorSceneView?) {

        guard let sceneView = sceneView, let scene = sceneView.scene else { return }

        for transitionView in transitionViewList {

            if transitionView.startScene.index == scene.index || transitionView.endScene.index == scene.index {

                transitionView.unhighlight()
            }
        }
    }

    private func centerScene(_ scene: MetaScene, animated: Bool) {

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
            guard let strongSelf = self else { return }
            MetaGameBundleManager.shared.save(strongSelf.gameBundle)
        }
    }
}

extension GameEditorViewController {

    @objc private func backButtonDidTap() {

        print("[GameEditor] did tap backButton")

        navigationController?.popViewController(animated: true)
    }

    @objc private func publishButtonDidTap() {

        print("[GameEditor] did tap publishButton")

        publish()
    }

    @objc private func gameSettingsButtonDidTap() {

        print("[GameEditor] did tap gameSettingsButton")

        openGameSettings()
    }

    @objc private func gameboardViewDidTap(_ sender: UITapGestureRecognizer) {

        print("[GameEditor] did tap gameboardView")

        // 添加场景方式一

        if willAddScene {
            let location: CGPoint = sender.location(in: sender.view)
            doAddScene(center: location)
        } else {
            closeScene()
        }
    }

    @objc private func gameboardViewDidLongPress(_ sender: UILongPressGestureRecognizer) {

        if !willAddScene {

            let location: CGPoint = sender.location(in: sender.view)
            addSceneIndicatorView.center = CGPoint(x: location.x, y: location.y - AddSceneIndicatorView.ViewLayoutConstants.height / 2)
            addSceneIndicatorView.isHidden = false // 显示「添加场景提示器」视图
        }
    }

    @objc private func addTransitionDiagramViewDidTap() {

        print("[GameEditor] did tap addTransitionDiagramView")

        addTransition()
    }

    private func publish() {

        let publicationVC = PublicationViewController(game: game)
        publicationVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(publicationVC, animated: true)
    }

    private func openGameSettings() {

        let gameSettingsVC = GameSettingsViewController(game: game)
        gameSettingsVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(gameSettingsVC, animated: true)
    }

    private func addScene(center: CGPoint) -> GameEditorSceneView? {

        let scene = gameBundle.addScene(center: center)
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            MetaGameBundleManager.shared.save(strongSelf.gameBundle)
        }

        let sceneView: GameEditorSceneView = GameEditorSceneView(scene: scene)
        sceneView.delegate = self
        gameboardView.addSubview(sceneView)
        sceneViewList.append(sceneView)

        return sceneView
    }

    private func selectScene(_ sceneView: GameEditorSceneView?, animated: Bool) {

        guard let sceneView = sceneView else { return }

        gameboardView.bringSubviewToFront(sceneView)

        // 重置「先前选中场景」视图

        let previousSelectedSceneIndex = gameBundle.selectedSceneIndex
        let previousSelectedSceneView = sceneViewList.first(where: { $0.scene.index == previousSelectedSceneIndex })
        previousSelectedSceneView?.isActive = false
        unhighlightRelatedSceneViews(sceneView: previousSelectedSceneView) // 取消高亮显示「先前选中场景」相关的场景视图
        unhighlightRelatedTransitionViews(sceneView: previousSelectedSceneView) // 取消高亮显示「先前选中场景」相关的穿梭器视图

        // 保存「当前选中场景」的索引

        gameBundle.selectedSceneIndex = sceneView.scene.index
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            MetaGameBundleManager.shared.save(strongSelf.gameBundle)
        }

        // 重置底部视图

        willAddScene = false
        resetBottomView(sceneSelected: true, animated: false)

        // 尽量将场景视图置于中央，并保存内容偏移量

        centerScene(sceneView.scene, animated: animated)
    }

    private func doAddScene(center location: CGPoint, forceSelection: Bool = false) {

        // 对齐网格

        let gridWidth: CGFloat = GameEditorViewController.ViewLayoutConstants.gameboardViewGridWidth
        let snappedLocation = CGPoint(x: gridWidth * floor(location.x / gridWidth), y: gridWidth * floor(location.y / gridWidth))

        // 新建场景视图

        guard let sceneView = addScene(center: snappedLocation) else { return }
        print("[GameEditor] do add scene \(sceneView.scene.index)")

        // 重置底部视图

        if forceSelection {

            selectScene(sceneView, animated: true)

        } else {

            willAddScene = false
            if gameBundle.selectedSceneIndex == 0 {
                resetBottomView(sceneSelected: false, animated: false)
            } else {
                resetBottomView(sceneSelected: true, animated: false)
            }
        }

        gameboardView.bringSubviewToFront(addSceneIndicatorView) // 不管采用哪种添加场景方式，都要确保「添加场景提示器」视图置于最顶层
    }

    private func closeScene() {

        let previousSelectedScene = gameBundle.selectedScene() // 暂存「先前选中场景」

        // 重置底部视图

        resetBottomView(sceneSelected: false, animated: true)

        // 尽量将「先前选中场景」视图置于中央，并保存内容偏移量

        if let scene = previousSelectedScene {
            centerScene(scene, animated: true)
        }
    }

    private func deleteScene() {

        // 弹出删除场景提示框

        let alert = UIAlertController(title: NSLocalizedString("DeleteScene", comment: ""), message: NSLocalizedString("DeleteSceneInfo", comment: ""), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { [weak self] _ in

            guard let strongSelf = self else { return }

            // 获取「当前选中场景」的索引和 UUID

            let selectedSceneIndex = strongSelf.gameBundle.selectedSceneIndex
            guard let selectedScene = strongSelf.gameBundle.selectedScene() else { return }
            let selectedSceneUUID = selectedScene.uuid

            // 删除「当前选中场景」相关的全部穿梭器视图

            for (i, transitionView) in strongSelf.transitionViewList.enumerated().reversed() { // 倒序遍历元素可保证安全删除

                if transitionView.startScene.index == selectedSceneIndex {

                    // 取消高亮显示「当前选中穿梭器」相关的「结束场景」视图

                    let endSceneView = strongSelf.sceneViewList.first(where: { $0.scene.index == transitionView.endScene.index })
                    endSceneView?.unhighlight()

                    // 删除「当前选中穿梭器」

                    transitionView.removeFromSuperview()
                    strongSelf.transitionViewList.remove(at: i)

                } else if transitionView.endScene.index == selectedSceneIndex {

                    // 取消高亮显示「当前选中穿梭器」相关的「开始场景」视图

                    let startSceneView = strongSelf.sceneViewList.first(where: { $0.scene.index == transitionView.startScene.index })
                    startSceneView?.unhighlight()

                    // 删除「当前选中穿梭器」

                    transitionView.removeFromSuperview()
                    strongSelf.transitionViewList.remove(at: i)
                }
            }

            // 删除「当前选中场景」视图

            for (i, sceneView) in strongSelf.sceneViewList.enumerated().reversed() { // 倒序遍历元素可保证安全删除
                if sceneView.scene.index == selectedSceneIndex {
                    sceneView.removeFromSuperview()
                    strongSelf.sceneViewList.remove(at: i)
                    break // 找到就退出
                }
            }

            // 保存「删除场景」信息

            strongSelf.gameBundle.deleteSelectedScene()
            DispatchQueue.global(qos: .background).async {
                MetaGameBundleManager.shared.save(strongSelf.gameBundle)
                MetaSceneBundleManager.shared.delete(sceneUUID: selectedSceneUUID, gameUUID: strongSelf.gameBundle.uuid)
            }

            // 重置底部视图

            strongSelf.resetBottomView(sceneSelected: false, animated: true)
        })

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
        })

        present(alert, animated: true, completion: nil)
    }

    private func editSceneTitle() {

        // 弹出编辑场景标题提示框

        let alert = UIAlertController(title: NSLocalizedString("EditSceneTitle", comment: ""), message: nil, preferredStyle: .alert)

        alert.addTextField { [weak self] textField in

            guard let strongSelf = self else { return }

            textField.font = .systemFont(ofSize: GlobalViewLayoutConstants.alertTextFieldFontSize, weight: .regular)
            textField.text = strongSelf.gameBundle.selectedScene()?.title
            textField.returnKeyType = .done
            textField.delegate = self
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { [weak self] _ in

            guard let strongSelf = self else { return }

            guard let title = alert.textFields?.first?.text, !title.isEmpty else {
                let toast = Toast.default(text: NSLocalizedString("EmptyTitleNotAllowed", comment: ""))
                toast.show()
                return
            }

            // 保存「当前选中场景」的标题

            guard let scene = strongSelf.gameBundle.selectedScene() else { return }
            scene.title = title
            strongSelf.gameBundle.updateScene(scene)
            DispatchQueue.global(qos: .background).async {
                MetaGameBundleManager.shared.save(strongSelf.gameBundle)
            }

            // 重置底部视图

            strongSelf.resetBottomView(sceneSelected: true, animated: true)

            // 更新「当前选中场景」视图的标题标签

            let sceneView = strongSelf.sceneViewList.first(where: { $0.scene.index == strongSelf.gameBundle.selectedSceneIndex })
            sceneView?.updateTitleLabelAttributedText()
        })

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
        })

        present(alert, animated: true, completion: nil)
    }

    private func addTransition() {

        let targetScenesVC = TargetScenesViewController(gameBundle: gameBundle)
        targetScenesVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(targetScenesVC, animated: true)
    }

    private func manageTransitions() {

    }

    private func previewScene() {

        guard let selectedScene = gameBundle.selectedScene(), let selectedSceneBundle = MetaSceneBundleManager.shared.load(sceneUUID: selectedScene.uuid, gameUUID: gameBundle.uuid) else { return }
        let sceneEmulatorVC = SceneEmulatorViewController(sceneBundle: selectedSceneBundle, gameBundle: gameBundle)
        sceneEmulatorVC.definesPresentationContext = false
        sceneEmulatorVC.modalPresentationStyle = .currentContext

        present(sceneEmulatorVC, animated: true, completion: nil)
    }

    private func editScene() {

        guard let selectedScene = gameBundle.selectedScene(), let selectedSceneBundle = MetaSceneBundleManager.shared.load(sceneUUID: selectedScene.uuid, gameUUID: gameBundle.uuid) else { return }
        let sceneEditorVC = SceneEditorViewController(sceneBundle: selectedSceneBundle, gameBundle: gameBundle)
        let sceneEditorNav = UINavigationController(rootViewController: sceneEditorVC)
        sceneEditorNav.definesPresentationContext = false
        sceneEditorNav.modalPresentationStyle = .currentContext

        present(sceneEditorNav, animated: true, completion: nil)

    }

    private func deleteTransition(_ transition: MetaTransition, completion: @escaping () -> Void) {

        // 弹出删除穿梭器提示框

        let alert = UIAlertController(title: NSLocalizedString("DeleteTransition", comment: ""), message: NSLocalizedString("DeleteTransitionInfo", comment: ""), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { [weak self] _ in

            guard let strongSelf = self else { return }

            for (i, transitionView) in strongSelf.transitionViewList.enumerated().reversed() { // 倒序遍历元素可保证安全删除

                if transitionView.startScene.index == transition.from &&
                    transitionView.endScene.index == transition.to {

                    // 删除「待删除穿梭器」视图

                    transitionView.removeFromSuperview()
                    strongSelf.transitionViewList.remove(at: i)

                    // 取消高亮显示「待删除穿梭器」相关的「结束场景」视图

                    let oppositeTransitionView = strongSelf.transitionViewList.first(where: {
                        $0.startScene.index == transition.to && $0.endScene.index == transition.from
                    }) // 如果存在反向的穿梭器，就不需要取消高亮显示「结束场景」视图了
                    if oppositeTransitionView == nil {
                        let endSceneView = strongSelf.sceneViewList.first(where: { $0.scene.index == transitionView.endScene.index })
                        endSceneView?.unhighlight()
                    }
                }
            }

            // 保存「删除穿梭器」信息

            strongSelf.gameBundle.deleteTransition(transition)
            DispatchQueue.global(qos: .background).async {
                MetaGameBundleManager.shared.save(strongSelf.gameBundle)
            }

            // 完成之后的回调

            completion()
        })

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
        })

        present(alert, animated: true, completion: nil)
    }
}

extension GameEditorViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard let text = textField.text else { return true }

        if range.length + range.location > text.count { return false }
        let newLength = text.count + string.count - range.length

        return newLength <= 255
    }
}
