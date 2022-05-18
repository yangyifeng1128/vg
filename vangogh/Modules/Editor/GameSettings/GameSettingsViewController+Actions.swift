///
/// GameSettingsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AwaitToast
import OSLog
import UIKit

extension GameSettingsViewController {

    @objc func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }
}

extension GameSettingsViewController {

    /// 准备「设置表格视图」单元格
    func prepareSettingTableViewCell(indexPath: IndexPath) -> UITableViewCell {

        let setting: GameSetting = settings[indexPath.row]

        if setting.type == .gameThumbImage {

            guard let cell = settingsTableView.dequeueReusableCell(withIdentifier: GameSettingTableThumbImageViewCell.reuseId) as? GameSettingTableThumbImageViewCell else {
                fatalError("Unexpected cell type")
            }

            cell.titleLabel.text = setting.title

            cell.thumbImageView.image = .gameBackgroundThumb
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let s = self else { return }
                if let thumbImage = MetaThumbManager.shared.loadGameThumbImage(gameUUID: s.game.uuid) {
                    DispatchQueue.main.async {
                        cell.thumbImageView.image = thumbImage
                    }
                }
            }

            return cell

        } else {

            guard let cell = settingsTableView.dequeueReusableCell(withIdentifier: GameSettingTableViewCell.reuseId) as? GameSettingTableViewCell else {
                fatalError("Unexpected cell type")
            }

            cell.titleLabel.text = setting.title

            switch setting.type {
            case .gameTitle:
                var infoString: String?
                if !game.title.isEmpty {
                    infoString = game.title
                } else {
                    infoString = NSLocalizedString("Untitled", comment: "")
                }
                cell.infoLabel.text = infoString
                break
            default:
                break
            }

            return cell
        }
    }

    /// 选择「设置表格视图」单元格
    func selectSettingTableViewCell(indexPath: IndexPath, cell: GameSettingTableViewCell) {

        let setting: GameSetting = settings[indexPath.row]

        switch setting.type {
        case .gameThumbImage:

            updateGameThumbImageView()
            break

        case .gameTitle:

            updateGameTitleLabel(cell.infoLabel)
            break
        }
    }

    /// 更新「作品缩略图视图」
    func updateGameThumbImageView() {

    }

    /// 更新「作品标题标签」
    func updateGameTitleLabel(_ label: UILabel) {

        // 创建提示框

        let alert = UIAlertController(title: NSLocalizedString("EditGameTitle", comment: ""), message: nil, preferredStyle: .alert)

        // 输入框

        alert.addTextField { [weak self] textField in

            guard let s = self else { return }

            textField.font = .systemFont(ofSize: GVC.alertTextFieldFontSize, weight: .regular)
            textField.text = s.game.title
            textField.returnKeyType = .done
            textField.delegate = self
        }

        // 「确认」操作

        let confirmAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { [weak self] _ in

            guard let s = self else { return }

            guard let title = alert.textFields?.first?.text, !title.isEmpty else {
                let toast = Toast.default(text: NSLocalizedString("EmptyTitleNotAllowed", comment: ""))
                toast.show()
                return
            }

            s.saveGameTitle(title) {
                s.settingsTableView.reloadData()
                Logger.composition.info("saved game title: \"\(title)\"")
            }
        }
        alert.addAction(confirmAction)

        // 「取消」操作

        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
        }
        alert.addAction(cancelAction)

        // 兼容 iPad 应用

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = label
            popoverController.sourceRect = label.bounds
        }

        // 展示提示框

        present(alert, animated: true, completion: nil)
    }
}

extension GameSettingsViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard let text = textField.text else { return true }
        if range.length + range.location > text.count { return false }
        let newLength = text.count + string.count - range.length
        return newLength <= 255
    }
}
