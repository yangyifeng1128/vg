///
/// DarkModeViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import OSLog
import UIKit

extension DarkModeViewController {

    @objc func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }

    @objc func followSystemSwitchDidChange(_ sender: UISwitch) {

        let followsSystemUserInterfaceStyle: Bool = sender.isOn

        UserDefaults.standard.setValue(!followsSystemUserInterfaceStyle, forKey: GKC.ignoresSystemUserInterfaceStyle)
        stylesView.isHidden = followsSystemUserInterfaceStyle

        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

        if followsSystemUserInterfaceStyle { // 跟随系统
            window.overrideUserInterfaceStyle = .unspecified
        } else { // 不跟随系统
            selectUserInterfaceStyle(type: .darkMode) // 默认选择深色模式
        }

        Logger.appSettings.info("followed system user interface style: \(followsSystemUserInterfaceStyle)")
    }
}

extension DarkModeViewController {

    /// 准备「风格表格视图」单元格
    func prepareStyleTableViewCell(indexPath: IndexPath) -> UITableViewCell {

        let style: UserInterfaceStyle = styles[indexPath.row]

        guard let cell = stylesTableView.dequeueReusableCell(withIdentifier: UserInterfaceStyleTableViewCell.reuseId) as? UserInterfaceStyleTableViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备「标题标签」

        cell.titleLabel.text = NSLocalizedString(style.title, comment: "")

        // 准备「勾选视图」

        let isInLightMode: Bool = UserDefaults.standard.bool(forKey: GKC.isInLightMode)
        if style.type == .darkMode {
            cell.checkmarkView.isHidden = isInLightMode
        } else if style.type == .lightMode {
            cell.checkmarkView.isHidden = !isInLightMode
        }

        return cell
    }

    /// 选择「风格表格视图」单元格
    func selectStyleTableViewCell(indexPath: IndexPath) {

        let type: UserInterfaceStyle.UserInterfaceStyleType = styles[indexPath.row].type
        selectUserInterfaceStyle(type: type)
    }

    /// 选择用户界面风格
    func selectUserInterfaceStyle(type: UserInterfaceStyle.UserInterfaceStyleType) {

        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

        if type == .darkMode {
            UserDefaults.standard.setValue(false, forKey: GKC.isInLightMode)
            window.overrideUserInterfaceStyle = .dark
        } else if type == .lightMode {
            UserDefaults.standard.setValue(true, forKey: GKC.isInLightMode)
            window.overrideUserInterfaceStyle = .light
        }

        stylesTableView.reloadData() // 重新加载表格视图

        Logger.appSettings.info("selected user interface style: \"\(type.rawValue)\"")
    }
}
