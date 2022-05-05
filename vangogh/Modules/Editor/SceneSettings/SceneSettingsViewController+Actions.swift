///
/// SceneSettingsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AwaitToast
import OSLog
import UIKit

extension SceneSettingsViewController {

    @objc func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }
}

extension SceneSettingsViewController {

    /// 准备「设置表格视图」单元格
    func prepareSettingTableViewCell(indexPath: IndexPath) -> UITableViewCell {

        let setting: SceneSetting = settings[indexPath.row]

        if setting.type == .sceneThumbImage {

            guard let cell = settingsTableView.dequeueReusableCell(withIdentifier: SceneSettingTableThumbImageViewCell.reuseId) as? SceneSettingTableThumbImageViewCell else {
                fatalError("Unexpected cell type")
            }

            cell.titleLabel.text = setting.title

            if let thumbImage = MetaThumbManager.shared.loadSceneThumbImage(sceneUUID: sceneBundle.sceneUUID, gameUUID: sceneBundle.gameUUID) {
                cell.thumbImageView.image = thumbImage
            } else {
                cell.thumbImageView.image = .sceneBackgroundThumb
            }

            return cell

        } else {

            guard let cell = settingsTableView.dequeueReusableCell(withIdentifier: SceneSettingTableViewCell.reuseId) as? SceneSettingTableViewCell else {
                fatalError("Unexpected cell type")
            }

            cell.titleLabel.text = setting.title

            switch setting.type {
            case .sceneTitle:
                var infoString: String?
                if let sceneTitle = gameBundle.selectedScene()?.title, !sceneTitle.isEmpty {
                    infoString = sceneTitle
                } else {
                    infoString = NSLocalizedString("Untitled", comment: "")
                }
                cell.infoLabel.text = infoString
                break
            case .aspectRatio:
                cell.infoLabel.text = sceneBundle.aspectRatioType.rawValue
                break
            default:
                break
            }

            return cell
        }
    }

    /// 选择「设置表格视图」单元格
    func selectSettingTableViewCell(indexPath: IndexPath, cell: SceneSettingTableViewCell) {

        let setting: SceneSetting = settings[indexPath.row]

        switch setting.type {
        case .sceneThumbImage:

            willUpdateSceneThumbImageView()
            break

        case .sceneTitle:

            willUpdateSceneTitleLabel(cell.infoLabel)
            break

        case .aspectRatio:

            willUpdateAspectRatioLabel(cell.infoLabel)
            break
        }
    }

    /// 更新「场景缩略图视图」
    func willUpdateSceneThumbImageView() {

    }

    /// 更新「场景标题标签」
    func willUpdateSceneTitleLabel(_ label: UILabel) {

        // 创建提示框

        let alert = UIAlertController(title: NSLocalizedString("EditSceneTitle", comment: ""), message: nil, preferredStyle: .alert)

        // 输入框

        alert.addTextField { [weak self] textField in

            guard let s = self else { return }

            textField.font = .systemFont(ofSize: GVC.alertTextFieldFontSize, weight: .regular)
            textField.text = s.gameBundle.selectedScene()?.title
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

            s.saveSceneTitle(title) {
                s.settingsTableView.reloadData()
                Logger.sceneEditor.info("saved scene title: \"\(title)\"")
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

    /// 更新「尺寸比例标签」
    func willUpdateAspectRatioLabel(_ label: UILabel) {

        // 创建提示框

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // 「选择尺寸比例」操作

        for aspectRatioType in MetaSceneAspectRatioType.allCases {
            alert.addAction(UIAlertAction(title: aspectRatioType.rawValue, style: .default) { [weak self] _ in
                guard let s = self else { return }
                s.saveAspectRatioType(aspectRatioType) {
                    s.settingsTableView.reloadData()
                    Logger.sceneEditor.info("saved aspect ratio: \"\(aspectRatioType.rawValue)\"")
                }
            })
        }

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

extension SceneSettingsViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard let text = textField.text else { return true }
        if range.length + range.location > text.count { return false }
        let newLength = text.count + string.count - range.length
        return newLength <= 255
    }
}
