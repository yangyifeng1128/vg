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

    private var closeButtonContainer: UIView!
    private var closeButton: CircleNavigationBarButton!

    private var noDataView: SceneEmulatorNoDataView!

    private var playerView: ScenePlayerView!
    private var loadingView: LoadingView!
    private var progressView: SceneEmulatorProgressView!
    private var playButton: SceneEmulatorPlayButton!
    private var playIndicatorButton: SceneEmulatorPlayButton!

    private var renderSize: CGSize!

    private var gameBundle: MetaGameBundle!
    private var sceneBundle: MetaSceneBundle!

    private var gameEngine: MetaGameEngine!

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

        // 初始化作品引擎

        initMetaGameEngine()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    deinit {

        removePeriodicTimeObserver()
        NotificationCenter.default.removeObserver(self)
    }

    private func initMetaGameEngine() {

        gameEngine = MetaGameEngine(rules: sceneBundle.rules)
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        // 单独强制设置用户界面风格

        overrideUserInterfaceStyle = SceneEmulatorViewController.preferredUserInterfaceStyle

        // 初始化视图

        initViews()
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // 隐藏导航栏

        navigationController?.navigationBar.isHidden = true
    }

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

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        // 暂停播放

        if !timeline.videoChannel.isEmpty {
            pause()
        }

        // 保存资源包

        saveBundle()
    }

    private func saveBundle() {

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sceneBundle.currentTimeMilliseconds = strongSelf.currentTime.milliseconds() // 保存当前播放时刻
            MetaGameBundleManager.shared.save(strongSelf.gameBundle)
            MetaSceneBundleManager.shared.save(strongSelf.sceneBundle)
        }
    }

    override var prefersStatusBarHidden: Bool {

        return true // 隐藏状态栏

        // return false // 显示状态栏
    }

    //
    //
    // MARK: - 初始化子视图
    //
    //

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

        // 初始化关闭按钮

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

        // 关闭「场景模拟器」视图控制器

        presentingViewController?.dismiss(animated: true, completion: nil)

        // 跳转至「场景编辑器」视图控制器

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

extension SceneEmulatorViewController {

    private func reloadPlayer() {

        DispatchQueue.global(qos: .background).async { [weak self] in

            guard let strongSelf = self else { return }

            // （重新）加载时间线

            strongSelf.reloadTimeline()
            DispatchQueue.main.sync {
                strongSelf.loadingView.progress = 0.33
            }

            // （重新）初始化播放器

            let compositionGenerator = CompositionGenerator(timeline: strongSelf.timeline)
            strongSelf.playerItem = compositionGenerator.buildPlayerItem()

            if strongSelf.player == nil {
                strongSelf.player = AVPlayer.init(playerItem: strongSelf.playerItem)
                try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []) // 如果手机处于静音模式，则打开音频播放
            } else {
                strongSelf.removePeriodicTimeObserver() // 移除「周期时间」监听器
                NotificationCenter.default.removeObserver(strongSelf) // 移除其他全部监听器
                strongSelf.player.replaceCurrentItem(with: strongSelf.playerItem)
            }
            strongSelf.player.seek(to: CMTimeMake(value: strongSelf.sceneBundle.currentTimeMilliseconds, timescale: GVC.preferredTimescale), toleranceBefore: .zero, toleranceAfter: .zero)
            strongSelf.addPeriodicTimeObserver() // 添加「周期时间」监听器
            NotificationCenter.default.addObserver(strongSelf, selector: #selector(strongSelf.playerItemDidPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: strongSelf.player.currentItem) // 添加「播放完毕」监听器
            NotificationCenter.default.addObserver(strongSelf, selector: #selector(strongSelf.didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil) // 添加「进入后台」监听器
            NotificationCenter.default.addObserver(strongSelf, selector: #selector(strongSelf.willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil) // 添加「进入前台」监听器
            DispatchQueue.main.sync {
                strongSelf.loadingView.progress = 0.67
            }

            // （重新）初始化界面

            DispatchQueue.main.async {
                strongSelf.updatePlayerRelatedViews() // 更新播放器相关的界面
                strongSelf.loadingView.stopAnimating() // 停止加载视图的加载动画
                if !strongSelf.timeline.videoChannel.isEmpty {
                    strongSelf.playOrPause() // 立即播放
                }
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
                    let resource: ImageResource = ImageResource(image: image, duration: CMTimeMake(value: footage.durationMilliseconds, timescale: GVC.preferredTimescale))
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
            playButton.isHidden = true
            noDataView.isHidden = false
            view.bringSubviewToFront(noDataView)

        } else {

            playerView.rendererView.player = player

            playerView.rendererView.image = nil
            playButton.isHidden = false
            noDataView.isHidden = true
            view.sendSubviewToBack(noDataView)
        }

        playerView.updateNodeViews(nodes: sceneBundle.nodes)
        progressView.updateNodeItemViews(nodes: sceneBundle.nodes, playerItemDurationMilliseconds: playerItem.duration.milliseconds())
    }

    private func addPeriodicTimeObserver() {

        let interval: CMTime = CMTimeMake(value: 1, timescale: 100)
        periodicTimeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] currentTime in
            guard let strongSelf = self else { return }
            strongSelf.currentTime = currentTime
        }
    }

    private func removePeriodicTimeObserver() {

        if let timeObserver = periodicTimeObserver {
            player.removeTimeObserver(timeObserver)
            periodicTimeObserver = nil
        }
    }

    private func updateViewsWhenTimeElapsed(to time: CMTime) {

        if let duration = player.currentItem?.duration {
            progressView.value = SceneEmulatorProgressView.maximumValue * time.seconds / duration.seconds
        }

        playerView.showOrHideNodeViews(at: time)
    }
}

extension SceneEmulatorViewController {

    //
    //
    // MARK: - 界面操作
    //
    //

    @objc private func closeButtonDidTap() {

        print("[SceneEmulator] did tap closeButton")

        let parentVC = presentingViewController?.children.last

        if let gameEditorVC = parentVC as? GameEditorViewController {

            gameBundle.selectedSceneIndex = 1 // FIXME：保存当前选中的场景
            gameEditorVC.needsContentOffsetUpdate = true // 将新的选中场景视图置于作品板视图中央

        } else if let sceneEditorVC = parentVC as? SceneEditorViewController {

            sceneEditorVC.needsReloadPlayer = false // 禁止重新加载播放器
        }

        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @objc private func playButtonDidTap() {

        print("[SceneEmulator] did tap playButton")

        playOrPause()
    }

    @objc private func playIndicatorButtonDidTap() {

        print("[SceneEmulator] did tap playIndicatorButton")

        playOrPause()
    }

    @objc private func playerItemDidPlayToEndTime() {

        print("[SceneEmulator] player item did play to end time")

        loop()
    }

    @objc private func didEnterBackground() {

        print("[SceneEmulator] did enter background")

        if !timeline.videoChannel.isEmpty {
            pause()
        }

        saveBundle()
    }

    @objc private func willEnterForeground() {

        print("[SceneEmulator] will enter foreground")

        loadingView.startAnimating()
        reloadPlayer()
    }

    private func playOrPause() {

        if let player = player {

            if player.timeControlStatus == .playing {

                playButton.isPlaying = false
                player.pause()

                view.bringSubviewToFront(playIndicatorButton)
                playIndicatorButton.isHidden = false
                closeButtonContainer.isHidden = false
                progressView.isHidden = false

            } else {

                playButton.isPlaying = true
                player.play()

                view.sendSubviewToBack(playIndicatorButton)
                playIndicatorButton.isHidden = true
                closeButtonContainer.isHidden = true
                progressView.isHidden = true
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
            progressView.value = 0
        }
    }

    private func pause() {

        playButton.isPlaying = false
        if let player = player {
            player.pause()
        }

        view.sendSubviewToBack(playIndicatorButton)
        playIndicatorButton.isHidden = true
        closeButtonContainer.isHidden = true
        progressView.isHidden = true
    }

    //
    //
    // MARK: - 数据操作
    //
    //

    private func isSceneBundleEmpty() -> Bool {

        return sceneBundle.footages.isEmpty && sceneBundle.nodes.isEmpty
    }
}
