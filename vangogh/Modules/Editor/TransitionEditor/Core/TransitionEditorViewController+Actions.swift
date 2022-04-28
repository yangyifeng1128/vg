///
/// TransitionEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension TransitionEditorViewController {

    @objc func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }

    @objc func addConditionButtonDidTap() {

        print("[TransitionEditor] did tap addConditionButton")
    }

    @objc func conditionWillDelete(sender: UIButton) {

        let index = sender.tag
        let condition = conditions[index]

        // 创建提示框

        let alert = UIAlertController(title: NSLocalizedString("DeleteCondition", comment: ""), message: NSLocalizedString("DeleteConditionInfo", comment: ""), preferredStyle: .alert)

        // 「确认」操作

        let confirmAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { [weak self] _ in

            guard let s = self else { return }

            // 保存「删除条件」信息

            s.gameBundle.deleteCondition(transition: s.transition, condition: condition)
            DispatchQueue.global(qos: .background).async {
                MetaGameBundleManager.shared.save(s.gameBundle)
            }

            // 重新加载条件

            s.conditions = s.transition.conditions
            s.conditionsTableView.reloadData()
        }
        alert.addAction(confirmAction)

        // 「取消」操作

        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
        }
        alert.addAction(cancelAction)

        // 展示提示框

        present(alert, animated: true, completion: nil)
    }
}
