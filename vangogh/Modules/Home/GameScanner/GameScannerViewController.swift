///
/// GameViewController
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
    private var scannerView: QRScannerView!
    /// 手电筒按钮
    private var torchButton: GameScannerTorchButton!

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

        let backButton: CircleNavigationBarButton = CircleNavigationBarButton(icon: .arrowBack, backgroundColor: GVC.defaultSceneControlBackgroundColor, tintColor: .white)
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

extension GameScannerViewController: QRScannerViewDelegate {

    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {

        print("[GameScanner] failed to scan QRCode. error: \(error.localizedDescription)")

        showScanFailureInfo()
    }

    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {

        print("[GameScanner] did scan QRCode successfully. code: \(code)")

        if let url = URL(string: code), url.scheme == GUC.metaGameURLScheme, let gameUUID = url.host {

            navigationController?.popViewController(animated: true)
            delegate?.scanDidSucceed(gameUUID: gameUUID)

        } else {

            showScanFailureInfo()
        }
    }

    func qrScannerView(_ qrScannerView: QRScannerView, didChangeTorchActive isOn: Bool) {

        torchButton.isActive = isOn
    }

    private func showScanFailureInfo() {

        // 创建提示框

        let alert = UIAlertController(title: NSLocalizedString("NoGamesFound", comment: ""), message: NSLocalizedString("NoGamesFoundInfo", comment: ""), preferredStyle: .alert)

        // 「重新扫描」操作

        let rescanAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Rescan", comment: ""), style: .default) { [weak self] _ in

            guard let s = self else { return }
            s.scannerView.rescan()
        }
        alert.addAction(rescanAction)

        // 「取消」操作

        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { [weak self] _ in

            guard let s = self else { return }
            s.navigationController?.popViewController(animated: true)
        }
        alert.addAction(cancelAction)

        // 展示提示框

        present(alert, animated: true, completion: nil)
    }
}

extension GameScannerViewController {

    /// 点击「返回按钮」
    @objc private func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }

    @objc private func torchButtonDidTap(_ torchButton: GameScannerTorchButton) {

        scannerView.setTorchActive(isOn: !torchButton.isActive)
    }
}
