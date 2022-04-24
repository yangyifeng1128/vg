///
/// DarkModeViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension AppSettingsViewController {

    @objc func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }
}

extension AppSettingsViewController {

    /// 选择应用程序设置
    func selectAppSetting(_ setting: AppSetting) {

        var vc: UIViewController

        switch setting.type {
        case .generalSettings:
            vc = GeneralSettingsViewController()
            break
        case .feedback:
            vc = FeedbackViewController()
            break
        case .termsOfService:
            vc = TermsOfServiceViewController()
            break
        case .privacyPolicy:
            vc = PrivacyPolicyViewController()
            break
        case .about:
            vc = AboutViewController()
            break
        }

        vc.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(vc, animated: true)
    }
}
