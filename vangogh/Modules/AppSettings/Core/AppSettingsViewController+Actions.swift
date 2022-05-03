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

    /// 准备「设置表格视图」单元格
    func prepareSettingTableViewCell(indexPath: IndexPath) -> UITableViewCell {

        let setting: AppSetting = settings[indexPath.row]

        guard let cell = settingsTableView.dequeueReusableCell(withIdentifier: AppSettingTableViewCell.reuseId) as? AppSettingTableViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备「标题标签」

        cell.titleLabel.text = setting.title

        return cell
    }

    /// 选择「设置表格视图」单元格
    func selectSettingTableViewCell(indexPath: IndexPath) {

        let setting: AppSetting = settings[indexPath.row]

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
