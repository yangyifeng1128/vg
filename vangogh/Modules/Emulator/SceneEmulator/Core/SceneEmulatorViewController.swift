///
/// SceneEmulatorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVKit
import SnapKit
import UIKit

class SceneEmulatorViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let topButtonContainerWidth: CGFloat = 64
        static let topButtonContainerPadding: CGFloat = 12
        static let playerViewPadding: CGFloat = 12
        static let playButtonWidth: CGFloat = 46
        static let playButtonImageEdgeInset: CGFloat = 9.2
        static let playIndicatorButtonWidth: CGFloat = 80
        static let playIndicatorButtonImageEdgeInset: CGFloat = 16
    }

    static let preferredUserInterfaceStyle: UIUserInterfaceStyle = .dark

    var closeButtonContainer: UIView!
    var closeButton: CircleNavigationBarButton!

    var noDataView: SceneEmulatorNoDataView!

    var playerView: ScenePlayerView!
    var loadingView: LoadingView!
    var progressView: SceneEmulatorProgressView!
    var playButton: SceneEmulatorPlayButton!
    var playIndicatorButton: SceneEmulatorPlayButton!

    var renderSize: CGSize!

    var gameBundle: MetaGameBundle!
    var sceneBundle: MetaSceneBundle!

    var gameEngine: MetaGameEngine!

    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var timeline: Timeline = Timeline()
    var currentTime: CMTime = .zero {
        didSet {
            updateViewsWhenTimeElapsed(to: currentTime)
        }
    }
    var periodicTimeObserver: Any?

    var needsReloadPlayer: Bool = true

    /// 初始化
    init(sceneBundle: MetaSceneBundle, gameBundle: MetaGameBundle) {

        super.init(nibName: nil, bundle: nil)

        self.sceneBundle = sceneBundle
        self.gameBundle = gameBundle

        // 初始化作品引擎

        initMetaGameEngine()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 反初始化
    deinit {

        removePeriodicTimeObserver()
        NotificationCenter.default.removeObserver(self)
    }

    /// 初始化作品引擎
    private func initMetaGameEngine() {

        gameEngine = MetaGameEngine(rules: sceneBundle.rules)
    }

    /// 视图加载完成
    override func viewDidLoad() {

        super.viewDidLoad()

        // 单独强制设置用户界面风格

        overrideUserInterfaceStyle = SceneEmulatorViewController.preferredUserInterfaceStyle

        // 初始化视图

        initViews()
    }

    /// 视图即将显示
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // 隐藏导航栏

        navigationController?.navigationBar.isHidden = true
    }

    /// 视图显示完成
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        if needsReloadPlayer && !isSceneBundleEmpty() { // （重新）加载播放器

            loadingView.startAnimating()
            reloadPlayer()

        } else { // 不重新加载播放器，但是需要重新定位播放时刻

            if let player = player {
                player.seek(to: CMTimeMake(value: sceneBundle.currentTimeMilliseconds, timescale: GVC.preferredTimescale), toleranceBefore: .zero, toleranceAfter: .zero)
            }
        }
    }

    /// 视图即将消失
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        // 暂停播放

        if !timeline.videoChannel.isEmpty {
            pause()
        }

        // 保存资源包

        saveBundle()
    }

    /// 隐藏状态栏
    override var prefersStatusBarHidden: Bool {

        return true
    }

    /// 初始化视图
    private func initViews() {

        // 初始化场景模拟器相关的视图

        initEmulatorRelatedViews()

        // 初始化「无数据」视图

        initNoDataView()

        // 初始化视图内容显示状态

        if isSceneBundleEmpty() {

            playerView.rendererView.image = .sceneBackground
            playerView.rendererView.contentMode = .scaleAspectFill
            noDataView.isHidden = false
            view.bringSubviewToFront(noDataView)

        } else {

            noDataView.isHidden = true
            view.sendSubviewToBack(noDataView)
        }
    }

    private func initNoDataView() {

        noDataView = SceneEmulatorNoDataView()
        noDataView.delegate = self
        view.addSubview(noDataView)
        noDataView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }
    }

    private func initEmulatorRelatedViews() {

        initPlayerView()
        initNavigationBar()
        initControls()
    }

    private func initPlayerView() {

        // 初始化播放器视图

        let renderHeight: CGFloat
        var renderWidth: CGFloat
        var renderAlignment: ScenePlayerView.RenderAlignment
        if isSceneBundleEmpty() {
            renderHeight = UIScreen.main.bounds.height
            renderWidth = renderHeight * GVC.defaultSceneAspectRatio
            renderAlignment = .center
        } else {
            if UIDevice.current.userInterfaceIdiom == .phone { // 如果是手机设备
                renderWidth = UIScreen.main.bounds.width // 宽度适配：视频渲染宽度 = 屏幕宽度
                renderHeight = MetaSceneAspectRatioTypeManager.shared.calculateHeight(width: renderWidth, aspectRatioType: sceneBundle.aspectRatioType) // 按照场景尺寸比例计算视频渲染高度
                if sceneBundle.aspectRatioType == .h16w9 { // 如果场景尺寸比例 = 16:9
                    let deviceAspectRatio: CGFloat = UIScreen.main.bounds.width / UIScreen.main.bounds.height
                    if deviceAspectRatio <= 0.5 {
                        renderAlignment = .topCenter
                    } else {
                        renderAlignment = .center // 兼容 iPhone 8, 8 Plus
                    }
                } else { // 如果场景尺寸比例 = 4:3或其他
                    renderAlignment = .center
                }
            } else { // 如果是平板或其他类型设备
                renderHeight = UIScreen.main.bounds.height // 高度适配：视频渲染高度 = 屏幕高度
                renderWidth = MetaSceneAspectRatioTypeManager.shared.calculateWidth(height: renderHeight, aspectRatioType: sceneBundle.aspectRatioType) // 按照场景尺寸比例计算视频渲染宽度
                renderAlignment = .center // 不管场景尺寸比例是什么，在平板或其他类型设备上都进行居中对齐
            }
        }
        renderSize = CGSize(width: renderWidth, height: renderHeight)
        playerView = ScenePlayerView(renderSize: renderSize, renderAlignment: renderAlignment)
        view.addSubview(playerView)
        playerView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        // 初始化加载视图

        loadingView = LoadingView()
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(LoadingView.VC.width)
            make.center.equalToSuperview()
        }
    }

    private func initNavigationBar() {

        // 初始化「关闭按钮容器」

        closeButtonContainer = UIView()
        closeButtonContainer.isHidden = true
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

        closeButton = CircleNavigationBarButton(icon: .close, backgroundColor: GVC.defaultSceneControlBackgroundColor, tintColor: .white)
        closeButton.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
        closeButtonContainer.addSubview(closeButton)
        closeButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.VC.width)
            make.right.bottom.equalToSuperview().offset(-VC.topButtonContainerPadding)
        }
    }

    //
    //
    // MARK: - 初始化控制器
    //
    //

    private func initControls() {

        initProgressView()
        initPlayButton()
        initPlayIndicatorButton()
    }

    private func initProgressView() {

        // 初始化「进度视图」

        progressView = SceneEmulatorProgressView()
        progressView.delegate = self
        progressView.isHidden = true
        view.addSubview(progressView)
        progressView.snp.makeConstraints { make -> Void in
            make.height.equalTo(SceneEmulatorProgressView.VC.height)
            make.left.equalTo(VC.playButtonWidth + VC.playerViewPadding * 2)
            make.right.equalToSuperview().inset(VC.playerViewPadding)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    private func initPlayButton() {

        // 初始化「播放按钮」

        playButton = SceneEmulatorPlayButton(imageEdgeInset: VC.playButtonImageEdgeInset)
        playButton.isHidden = true
        playButton.addTarget(self, action: #selector(playButtonDidTap), for: .touchUpInside)
        view.addSubview(playButton)
        playButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.playButtonWidth)
            make.left.equalToSuperview().offset(VC.playerViewPadding)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-VC.playerViewPadding)
        }
    }

    private func initPlayIndicatorButton() {

        // 初始化「播放提示器按钮」

        playIndicatorButton = SceneEmulatorPlayButton(imageEdgeInset: VC.playIndicatorButtonImageEdgeInset)
        playIndicatorButton.isHidden = true
        playIndicatorButton.addTarget(self, action: #selector(playIndicatorButtonDidTap), for: .touchUpInside)
        view.addSubview(playIndicatorButton)
        playIndicatorButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.playIndicatorButtonWidth)
            make.center.equalToSuperview()
        }
    }
}

extension SceneEmulatorViewController: SceneEmulatorNoDataViewDelegate {

    func editSceneImmediatelyButtonDidTap() {

        print("[SceneEmulator] did tap editSceneImmediatelyButton")

        // 关闭「场景模拟器视图控制器」

        presentingViewController?.dismiss(animated: true, completion: nil)

        // 展示「场景编辑器视图控制器」

        guard let selectedScene = gameBundle.selectedScene(), let sceneBundle = MetaSceneBundleManager.shared.load(sceneUUID: selectedScene.uuid, gameUUID: gameBundle.uuid) else { return }
        let sceneEditorVC = SceneEditorViewController(sceneBundle: sceneBundle, gameBundle: gameBundle)
        let sceneEditorNav = UINavigationController(rootViewController: sceneEditorVC)
        sceneEditorNav.definesPresentationContext = false
        sceneEditorNav.modalPresentationStyle = .currentContext

        presentingViewController?.present(sceneEditorNav, animated: true, completion: nil)
    }

    func editSceneLaterButtonDidTap() {

        print("[SceneEmulator] did tap editSceneLaterButton")

        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension SceneEmulatorViewController: SceneEmulatorProgressViewDelegate {

    func progressViewDidBeginSliding() {

        print("[SceneEmulator] did begin sliding progressView")

        if player.timeControlStatus == .playing {

            playButton.isPlaying = false
            player.pause()
        }
    }

    func progressViewDidEndSliding(to value: Double) {

        print("[SceneEmulator] did end sliding progressView to \(value * 100 / SceneEmulatorProgressView.maximumValue)%")

        // 重新定位播放时刻

        if let duration = player.currentItem?.duration {

            let currentTimeMilliseconds: Int64 = Int64((duration.seconds * 1000 * value / SceneEmulatorProgressView.maximumValue).rounded())
            player.seek(to: CMTimeMake(value: currentTimeMilliseconds, timescale: GVC.preferredTimescale), toleranceBefore: .zero, toleranceAfter: .zero)
        }
    }
}
