///
/// GeneralSettingsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

extension GeneralSettingsViewController {

    @objc func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }
}

extension GeneralSettingsViewController {

    /// 选择通用设置
    func selectGeneralSetting(_ setting: GeneralSetting) {

        var vc: UIViewController

        switch setting.type {
        case .darkMode:
            vc = DarkModeViewController()
            break
        }

        vc.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(vc, animated: true)
    }
}
