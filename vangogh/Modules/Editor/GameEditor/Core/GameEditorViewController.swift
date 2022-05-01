///
/// GameEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Instructions
import SnapKit
import UIKit

class GameEditorViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let topButtonContainerWidth: CGFloat = 64
        static let topRightButtonContainerWidth: CGFloat = 52
        static let topButtonContainerPadding: CGFloat = 12
        static let gameTitleLabelFontSize: CGFloat = 16
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
    /// 作品板视图
    var gameboardView: GameEditorGameboardView!

    /// 添加穿梭器示意图视图
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

        // 初始化「引导标记控制器」

        initCoachMarksController()
    }

    /// 视图即将显示
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // 隐藏导航栏

        navigationController?.navigationBar.isHidden = true

        // 检查外部变更记录

        checkExternalChanges()

        // 检查保存的会话状态

        checkSavedSession()
    }

    /// 视图显示完成
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        // 显示消息

        showMessage()

        // 显示引导标记

        showCoachMarks()
    }

    /// 视图即将消失
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        // 隐藏引导标记

        hideCoachMarks()

        // 保存作品资源包

        saveGameBundle() { [weak self] in
            guard let s = self else { return }
            s.sendGameSavedMessage()
        }
    }

    /// 视图已经消失
    override func viewDidDisappear(_ animated: Bool) {

        super.viewDidDisappear(animated)

        // 取消高亮显示当前选中的「场景视图」

        gameboardView.unhighlightSelectedSceneView()
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
        addTransitionDiagramView.isUserInteractionEnabled = true
        addTransitionDiagramView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addTransitionDiagramViewDidTap)))
        view.addSubview(addTransitionDiagramView)

        // 初始化「底部视图」

        bottomViewContainer = UIView()
        view.addSubview(bottomViewContainer)
    }
}
