///
/// CompositionViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AwaitToast
import CoreData
import OSLog
import SnapKit
import UIKit

extension CompositionViewController {

    @objc func settingsButtonDidTap() {

        // 进入「应用程序设置」

        pushAppSettingsVC()
    }

    @objc func composeButtonDidTap() {

        // 进入「新建作品视图」

        pushNewGameVC()
    }

    @objc func moreButtonDidTap(sender: UIButton) {

        // 显示更多关于草稿

        showMoreAboutDraft(sender: sender)
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
            DispatchQueue.main.async { [weak self] in
                guard let s = self else { return }
                s.showAgreements()
            }
        }
    }

    /// 显示协议
    func showAgreements() {

        let agreementsVC: AgreementsViewController = AgreementsViewController()
        let agreementsNav: UINavigationController = UINavigationController(rootViewController: agreementsVC)
        agreementsNav.modalPresentationStyle = .overFullScreen
        agreementsNav.modalTransitionStyle = .crossDissolve

        present(agreementsNav, animated: true, completion: nil)
    }

    /// 进入「应用程序设置」
    func pushAppSettingsVC() {

        let settingsVC: AppSettingsViewController = AppSettingsViewController()
        settingsVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(settingsVC, animated: true)
    }

    /// 进入「新建作品视图」
    func pushNewGameVC() {

        let newGameVC: NewGameViewController = NewGameViewController(games: drafts)
        newGameVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(newGameVC, animated: true)
    }

    /// 进入「作品编辑器」
    func pushGameEditorVC(game: MetaGame) {

        guard let gameBundle = MetaGameBundleManager.shared.load(uuid: game.uuid) else { return }

        let gameEditorVC: GameEditorViewController = GameEditorViewController(game: game, gameBundle: gameBundle, parentType: .draft)
        gameEditorVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(gameEditorVC, animated: true)
    }

    /// 显示更多关于草稿
    func showMoreAboutDraft(sender: UIButton) {

        let index: Int = sender.tag
        let draft: MetaGame = drafts[index]

        // 弹出提示框

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // 编辑草稿标题

        let editDraftTitleAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("EditTitle", comment: ""), style: .default) { [weak self] _ in

            guard let s = self else { return }

            // 弹出「编辑草稿标题提示框」

            let editDraftTitleAlert = UIAlertController(title: NSLocalizedString("EditGameTitle", comment: ""), message: nil, preferredStyle: .alert)
            editDraftTitleAlert.addTextField { textField in
                textField.text = draft.title
                textField.font = .systemFont(ofSize: GVC.alertTextFieldFontSize, weight: .regular)
                textField.returnKeyType = .done
                textField.delegate = self
            }

            let confirmAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { _ in
                guard let title = editDraftTitleAlert.textFields?.first?.text, !title.isEmpty else {
                    let toast = Toast.default(text: NSLocalizedString("EmptyTitleNotAllowed", comment: ""))
                    toast.show()
                    return
                }
                draft.title = title
                CoreDataManager.shared.saveContext()
                s.draftsTableView.reloadData()
            }
            editDraftTitleAlert.addAction(confirmAction)

            let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            }
            editDraftTitleAlert.addAction(cancelAction)

            s.present(editDraftTitleAlert, animated: true, completion: nil)
        }
        alert.addAction(editDraftTitleAction)

        // 删除草稿

        let deleteDraftAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .default) { [weak self] _ in

            guard let s = self else { return }

            // 弹出「删除草稿提示框」

            let deleteDraftAlert = UIAlertController(title: NSLocalizedString("DeleteGame", comment: ""), message: NSLocalizedString("DeleteGameInfo", comment: ""), preferredStyle: .alert)

            let confirmAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { _ in
                s.deleteDraft(index: index)
                s.reloadDraftsTableView()
            }
            deleteDraftAlert.addAction(confirmAction)

            let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            }
            deleteDraftAlert.addAction(cancelAction)

            s.present(deleteDraftAlert, animated: true, completion: nil)
        }
        alert.addAction(deleteDraftAction)

        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
        }
        alert.addAction(cancelAction)

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        } // 兼容 iPad 应用

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
