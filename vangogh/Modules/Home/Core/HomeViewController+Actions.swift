///
/// HomeViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension HomeViewController {

    /// 签署协议
    func signAgreements() {

        let agreementsSigned: Bool = UserDefaults.standard.bool(forKey: GKC.agreementsSigned)
        if !agreementsSigned {
            DispatchQueue.main.async { [weak self] in
                guard let s = self else { return }
                s.presentAgreementsVC()
            }
        }
    }

    /// 显示协议
    func presentAgreementsVC() {

        let agreementsVC: AgreementsViewController = AgreementsViewController()
        let agreementsNav: UINavigationController = UINavigationController(rootViewController: agreementsVC)
        agreementsNav.modalPresentationStyle = .overFullScreen
        agreementsNav.modalTransitionStyle = .crossDissolve

        present(agreementsNav, animated: true, completion: nil)
    }

    /// 进入「作品扫描器」
    func pushGameScannerVC() {

        let gameScannerVC: GameScannerViewController = GameScannerViewController()
        gameScannerVC.delegate = self
        gameScannerVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(gameScannerVC, animated: true)
    }

    /// 选择记录
    func selectRecord(_ record: MetaRecord) {
    }
}
