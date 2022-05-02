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

    /// 选择场景设置
    func selectSceneSetting(_ setting: SceneSetting, cell: SceneSettingTableViewCell) {

        switch setting.type {
        case .sceneThumbImage:

            editSceneThumbImage()
            break

        case .sceneTitle:

            editSceneTitle(sourceView: cell.infoLabel)
            break

        case .aspectRatio:

            editAspectRatio(sourceView: cell.infoLabel)
            break
        }
    }

    /// 编辑场景缩略图
    func editSceneThumbImage() {

    }

    /// 编辑场景标题
    func editSceneTitle(sourceView: UIView) {

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
                Logger.composition.info("saved scene title: \"\(title)\"")
            }
        }
        alert.addAction(confirmAction)

        // 「取消」操作
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
        }
        alert.addAction(cancelAction)

        // 兼容 iPad 应用

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView.bounds
        }

        // 展示提示框

        present(alert, animated: true, completion: nil)
    }

    /// 编辑尺寸比例
    func editAspectRatio(sourceView: UIView) {

        // 创建提示框

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // 「选择尺寸比例」操作

        for aspectRatioType in MetaSceneAspectRatioType.allCases {
            alert.addAction(UIAlertAction(title: aspectRatioType.rawValue, style: .default) { [weak self] _ in
                guard let s = self else { return }
                s.sceneBundle.aspectRatioType = aspectRatioType
                DispatchQueue.global(qos: .background).async {
                    MetaSceneBundleManager.shared.save(s.sceneBundle)
                }
                s.settingsTableView.reloadData()
            })
        }

        // 「取消」操作

        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
        }
        alert.addAction(cancelAction)

        // 兼容 iPad 应用

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView.bounds
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
