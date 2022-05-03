///
/// GeneralSettingsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension GeneralSettingsViewController {

    @objc func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }
}

extension GeneralSettingsViewController {

    /// 准备「设置表格视图」单元格
    func prepareSettingTableViewCell(indexPath: IndexPath) -> UITableViewCell {

        let setting: GeneralSetting = settings[indexPath.row]

        guard let cell = settingsTableView.dequeueReusableCell(withIdentifier: GeneralSettingTableViewCell.reuseId) as? GeneralSettingTableViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备「标题标签」

        cell.titleLabel.text = setting.title

        // 准备「信息标签」

        if setting.type == .darkMode {
            if !UserDefaults.standard.bool(forKey: GKC.ignoresSystemUserInterfaceStyle) {
                cell.infoLabel.text = NSLocalizedString("FollowSystem", comment: "")
            } else {
                cell.infoLabel.text = UserDefaults.standard.bool(forKey: GKC.isInLightMode) ? NSLocalizedString("Disabled", comment: "") : NSLocalizedString("Enabled", comment: "")
            }
        }

        return cell
    }

    /// 选择「设置表格视图」单元格
    func selectSettingTableViewCell(indexPath: IndexPath) {

        let setting: GeneralSetting = settings[indexPath.row]

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
