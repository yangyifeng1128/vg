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
    }

    /// 用户界面风格偏好设置
    static let preferredUserInterfaceStyle: UIUserInterfaceStyle = .dark

    /// 关闭按钮容器
    var closeButtonContainer: UIView!
    /// 关闭按钮
    var closeButton: CircleNavigationBarButton!

    /// 加载指示器视图
    var loadingIndicatorView: LoadingIndicatorView!
    /// 播放器视图
    var playerView: SceneEmulatorPlayerView!
    /// 播放控制视图
    var playControlView: SceneEmulatorPlayControlView!

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
            updateViewsWhenTimeElapsed(to: currentTime)
        }
    }
    /// 周期时刻观察器
    var periodicTimeObserver: Any?
    /// 需要重新加载播放器
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

        if needsReloadPlayer { // 重新加载播放器

            reloadPlayer()

        } else { // 不重新加载播放器，只希望重新定位播放时刻

            needsReloadPlayer = true

            if let player = player {

                player.seek(to: CMTimeMake(value: sceneBundle.currentTimeMilliseconds, timescale: GVC.preferredTimescale), toleranceBefore: .zero, toleranceAfter: .zero)
                play()
            }
        }
    }

    /// 视图即将消失
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        // 保存场景资源包

        saveSceneBundle() { [weak self] in

            guard let s = self else { return }

            // 停止播放

            s.stop()
        }
    }

    /// 隐藏状态栏
    override var prefersStatusBarHidden: Bool {

        return true
    }

    /// 初始化视图
    private func initViews() {

        // 初始化「播放器视图」

        playerView = SceneEmulatorPlayerView()
        playerView.dataSource = self
        playerView.delegate = self
        view.addSubview(playerView)
        playerView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        // 初始化「加载指示器视图」

        loadingIndicatorView = LoadingIndicatorView()
        view.addSubview(loadingIndicatorView)
        loadingIndicatorView.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(LoadingIndicatorView.VC.width)
            make.center.equalToSuperview()
        }

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

        // 初始化「播放控制视图」

        playControlView = SceneEmulatorPlayControlView()
        playControlView.dataSource = self
        playControlView.delegate = self
        playControlView.progressView.delegate = self
        view.addSubview(playControlView)
        playControlView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(SceneEmulatorPlayControlView.VC.height)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
