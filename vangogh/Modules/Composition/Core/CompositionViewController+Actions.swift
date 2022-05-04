///
/// CompositionViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AwaitToast
import OSLog
import UIKit

extension CompositionViewController {

    @objc func settingsButtonDidTap() {

        pushAppSettingsVC()
    }

    @objc func composeButtonDidTap() {

        pushNewGameVC()
    }

    @objc func moreButtonDidTap(button: UIButton) {

        showMoreAboutDraft(sourceButton: button)
    }
}

extension CompositionViewController {

    /// 显示消息
    func showMessage() {

        if let message = draftSavedMessage {
            let toast: Toast = Toast.default(text: message)
            toast.show()
            draftSavedMessage = nil
        }
    }

    /// 签署协议
    func signAgreements() {

        let agreementsSigned: Bool = UserDefaults.standard.bool(forKey: GKC.agreementsSigned)
        if !agreementsSigned {
            presentAgreementsVC()
        }
    }

    /// 展示协议
    func presentAgreementsVC() {

        let agreementsVC: AgreementsViewController = AgreementsViewController()
        let agreementsNav: UINavigationController = UINavigationController(rootViewController: agreementsVC)
        agreementsNav.modalPresentationStyle = .overFullScreen
        agreementsNav.modalTransitionStyle = .crossDissolve

        present(agreementsNav, animated: true, completion: nil)
    }

    /// 跳转至「应用程序设置控制器」
    func pushAppSettingsVC() {

        let settingsVC: AppSettingsViewController = AppSettingsViewController()
        settingsVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(settingsVC, animated: true)
    }

    /// 跳转至「新建作品视图控制器」
    func pushNewGameVC() {

        let newGameVC: NewGameViewController = NewGameViewController(games: drafts)
        newGameVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(newGameVC, animated: true)
    }

    /// 跳转至「作品编辑器控制器」
    func pushGameEditorVC(game: MetaGame) {

        guard let gameBundle = MetaGameBundleManager.shared.load(uuid: game.uuid) else { return }

        let gameEditorVC: GameEditorViewController = GameEditorViewController(game: game, gameBundle: gameBundle, parentType: .draft)
        gameEditorVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(gameEditorVC, animated: true)
    }
}

extension CompositionViewController {

    /// 准备「草稿表格视图」单元格
    func prepareDraftTableViewCell(indexPath: IndexPath) -> UITableViewCell {

        let draft: MetaGame = drafts[indexPath.row]

        guard let cell = draftsTableView.dequeueReusableCell(withIdentifier: DraftTableViewCell.reuseId) as? DraftTableViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备「更多按钮」

        cell.moreButton.tag = indexPath.row
        cell.moreButton.addTarget(self, action: #selector(moreButtonDidTap), for: .touchUpInside)

        // 准备「标题标签」

        cell.titleLabel.text = draft.title

        // 准备「最近修改时间标签」

        let mtimeFormatter = DateFormatter()
        mtimeFormatter.dateStyle = .medium
        mtimeFormatter.timeStyle = .short
        cell.mtimeLabel.text = mtimeFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(draft.mtime)))

        // 准备「缩略图视图」

        cell.thumbImageView.image = .sceneBackgroundThumb

        return cell
    }

    /// 选择「草稿表格视图」单元格
    func selectDraftTableViewCell(indexPath: IndexPath) {

        let draft: MetaGame = drafts[indexPath.row]

        openDraft(draft) { [weak self] in
            guard let s = self else { return }
            s.pushGameEditorVC(game: draft)
            Logger.composition.info("loaded draft: \"\(draft.title)\"")
        }
    }

    /// 显示更多关于草稿
    func showMoreAboutDraft(sourceButton: UIButton) {

        let index: Int = sourceButton.tag
        let draft: MetaGame = drafts[index]

        // 创建提示框

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // 「编辑草稿标题」操作

        let editDraftTitleAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("EditTitle", comment: ""), style: .default) { [weak self] _ in

            guard let s = self else { return }

            // 创建提示框

            let editDraftTitleAlert = UIAlertController(title: NSLocalizedString("EditGameTitle", comment: ""), message: nil, preferredStyle: .alert)

            // 输入框

            editDraftTitleAlert.addTextField { textField in
                textField.text = draft.title
                textField.font = .systemFont(ofSize: GVC.alertTextFieldFontSize, weight: .regular)
                textField.returnKeyType = .done
                textField.delegate = self
            }

            // 「确认」操作

            let confirmAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { _ in

                guard let title = editDraftTitleAlert.textFields?.first?.text, !title.isEmpty else {
                    let toast = Toast.default(text: NSLocalizedString("EmptyTitleNotAllowed", comment: ""))
                    toast.show()
                    return
                }

                s.saveDraftTitle(draft, newTitle: title) {
                    s.draftsTableView.reloadData()
                    Logger.composition.info("saved draft title: \"\(title)\"")
                }
            }
            editDraftTitleAlert.addAction(confirmAction)

            // 「取消」操作

            let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            }
            editDraftTitleAlert.addAction(cancelAction)

            // 展示提示框

            s.present(editDraftTitleAlert, animated: true, completion: nil)
        }
        alert.addAction(editDraftTitleAction)

        // 「删除草稿」操作

        let deleteDraftAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .default) { [weak self] _ in

            guard let s = self else { return }

            // 创建提示框

            let deleteDraftAlert = UIAlertController(title: NSLocalizedString("DeleteGame", comment: ""), message: NSLocalizedString("DeleteGameInfo", comment: ""), preferredStyle: .alert)

            // 「确认」操作

            let confirmAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { _ in

                let draftTitle: String = draft.title

                s.deleteDraft(draft) {
                    s.draftsTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                    s.reloadDraftsTableView()
                    Logger.composition.info("deleted draft: \"\(draftTitle)\"")
                }
            }
            deleteDraftAlert.addAction(confirmAction)

            // 「取消」操作

            let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            }
            deleteDraftAlert.addAction(cancelAction)

            // 展示提示框

            s.present(deleteDraftAlert, animated: true, completion: nil)
        }
        alert.addAction(deleteDraftAction)

        // 「取消」操作

        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
        }
        alert.addAction(cancelAction)

        // 兼容 iPad 应用

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sourceButton
            popoverController.sourceRect = sourceButton.bounds
        }

        // 展示提示框

        present(alert, animated: true, completion: nil)
    }

    /// 重新加载「草稿表格视图」
    func reloadDraftsTableView() {

        draftsTableView.reloadData()

        if !drafts.isEmpty {
            draftsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            draftsView.isHidden = false
        } else {
            draftsView.isHidden = true
        }
    }
}

extension CompositionViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard let text = textField.text else { return true }
        if range.length + range.location > text.count { return false }
        let newLength = text.count + string.count - range.length
        return newLength <= 255
    }
}
