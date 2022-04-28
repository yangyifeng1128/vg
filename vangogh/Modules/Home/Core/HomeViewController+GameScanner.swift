///
/// HomeViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Photos
import UIKit

extension HomeViewController {

    @objc func scanButtonDidTap() {

        scan()
    }
}

extension HomeViewController: GameScannerViewControllerDelegate {

    /// 扫描成功
    func scanDidSucceed(gameUUID: String) {

        guard let gameBundle = MetaGameBundleManager.shared.load(uuid: gameUUID), let selectedScene = gameBundle.selectedScene(), let selectedSceneBundle = MetaSceneBundleManager.shared.load(sceneUUID: selectedScene.uuid, gameUUID: gameBundle.uuid) else { return }

        let sceneEmulatorVC = SceneEmulatorViewController(sceneBundle: selectedSceneBundle, gameBundle: gameBundle)
        sceneEmulatorVC.definesPresentationContext = false
        sceneEmulatorVC.modalPresentationStyle = .currentContext

        present(sceneEmulatorVC, animated: true, completion: nil)
    }

    /// 扫描
    func scan() {

        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            pushGameScannerVC()
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async { [weak self] in
                        guard let s = self else { return }
                        s.pushGameScannerVC()
                    }
                }
            }
            break
        default:
            let alert = UIAlertController(title: NSLocalizedString("CameraAuthorizationDenied", comment: ""), message: NSLocalizedString("CameraAuthorizationDeniedInfo", comment: ""), preferredStyle: .alert)
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

    /// 进入「作品扫描器」
    func pushGameScannerVC() {

        let gameScannerVC: GameScannerViewController = GameScannerViewController()
        gameScannerVC.delegate = self
        gameScannerVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(gameScannerVC, animated: true)
    }
}
