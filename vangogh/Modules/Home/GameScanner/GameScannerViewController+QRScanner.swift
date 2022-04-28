///
/// GameScannerViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import MercariQRScanner
import OSLog
import UIKit

extension GameScannerViewController {

    @objc func torchButtonDidTap(_ torchButton: GameScannerTorchButton) {

        scannerView.setTorchActive(isOn: !torchButton.isActive)
    }
}

extension GameScannerViewController: QRScannerViewDelegate {

    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {

        Logger.home.error("failed to scan QRCode. error: \(error.localizedDescription)")

        showScanFailureInfo()
    }

    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {

        Logger.home.error("scanned QRCode successfully. code: \(code)")

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

    /// 显示扫描失败信息
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
