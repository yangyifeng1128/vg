///
/// GameScannerViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import MercariQRScanner
import SnapKit
import UIKit

class GameScannerViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let topButtonContainerWidth: CGFloat = 64
        static let topButtonContainerPadding: CGFloat = 12
        static let torchButtonWidth: CGFloat = 64
        static let torchButtonImageEdgeInset: CGFloat = 18
    }

    /// 代理
    weak var delegate: GameScannerViewControllerDelegate?

    /// 扫描器视图
    var scannerView: QRScannerView!
    /// 手电筒按钮
    var torchButton: GameScannerTorchButton!

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
    }

    /// 隐藏状态栏
    override var prefersStatusBarHidden: Bool {

        return true
    }

    /// 初始化视图
    private func initViews() {

        view.backgroundColor = .black

        // 初始化「扫描器视图」

        scannerView = QRScannerView(frame: view.bounds)
        view.addSubview(scannerView)
        scannerView.configure(delegate: self, input: .init(isBlurEffectEnabled: true))
        scannerView.startRunning()

        // 初始化「关闭按钮容器」

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

        // 初始化「关闭按钮」

        let backButton: CircleNavigationBarButton = CircleNavigationBarButton(icon: .arrowBack, backgroundColor: GVC.defaultSceneControlBackgroundColor, tintColor: .mgHoneydew)
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        backButtonContainer.addSubview(backButton)
        backButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.VC.width)
            make.right.bottom.equalToSuperview().offset(-VC.topButtonContainerPadding)
        }

        // 初始化「手电筒按钮」

        torchButton = GameScannerTorchButton(imageEdgeInset: VC.torchButtonImageEdgeInset)
        torchButton.addTarget(self, action: #selector(torchButtonDidTap), for: .touchUpInside)
        view.addSubview(torchButton)
        torchButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.torchButtonWidth)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
        }
    }
}
