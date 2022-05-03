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

extension TransitionEditorViewController {

    /// 准备条件数量
    func prepareConditionsCount() -> Int {

        if conditions.isEmpty {
            conditionsTableView.showNoDataInfo(title: NSLocalizedString("NoConditionsAvailable", comment: ""))
        } else {
            conditionsTableView.hideNoDataInfo()
        }

        return conditions.count
    }

    /// 准备「条件表格视图」单元格
    func prepareConditionTableViewCell(indexPath: IndexPath) -> UITableViewCell {

        guard let cell = conditionsTableView.dequeueReusableCell(withIdentifier: TransitionEditorConditionTableViewCell.reuseId) as? TransitionEditorConditionTableViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备「or 标签」

        cell.orLabel.isHidden = indexPath.row == conditions.count - 1 ? true : false

        // 准备「删除按钮」

        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(conditionWillDelete), for: .touchUpInside)

        // 准备「标题标签」

        cell.titleLabel.attributedText = prepareConditionTitleLabelAttributedText(startScene: startScene, condition: conditions[indexPath.row])

        return cell
    }

    /// 准备「条件标题标签」文本
    func prepareConditionTitleLabelAttributedText(startScene: MetaScene, condition: MetaCondition) -> NSMutableAttributedString {

        let completeConditionTitleString: NSMutableAttributedString = NSMutableAttributedString(string: "")

        // 准备「点」

        let dotStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.mgLabel!, .font: UIFont.systemFont(ofSize: TransitionEditorConditionTableViewCell.VC.titleLabelFontSize, weight: .semibold)]
        let dotString: NSAttributedString = NSAttributedString(string: NSLocalizedString("Dot", comment: ""), attributes: dotStringAttributes)

        // 准备「开始场景」

        let startSceneTitleStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.mgLabel!]
        let startSceneTitleString: NSAttributedString = NSAttributedString(string: NSLocalizedString("Scene", comment: "") + " " + startScene.index.description, attributes: startSceneTitleStringAttributes)
        completeConditionTitleString.append(startSceneTitleString)
        completeConditionTitleString.append(dotString)

        // FIXME：重新处理「MetaTransition - MetaCondition」

        // 准备「组件」

//        if let conditionDescriptor = MetaConditionDescriptorManager.shared.load(nodeType: condition.nodeType, nodeBehaviorType: condition.nodeBehaviorType) {

        // 准备「组件标题」

        let nodeTitleStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.accent!]
        let nodeTitle: String = "node type"
//            if condition.nodeIndex == 0 {
//                nodeTitle = conditionDescriptor.nodeTypeAlias
//            } else {
//                nodeTitle = conditionDescriptor.nodeTypeAlias + " " + condition.nodeIndex.description
//            }
        let nodeTitleString: NSAttributedString = NSAttributedString(string: nodeTitle, attributes: nodeTitleStringAttributes)
        completeConditionTitleString.append(nodeTitleString)
        completeConditionTitleString.append(dotString)

        // 准备「组件行为标题」

        let nodeBehaviorTitleStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.mgLabel!]
        let nodeBehaviorTitleString: NSAttributedString = NSAttributedString(string: /* conditionDescriptor.nodeBehaviorTypeAlias */ "action type", attributes: nodeBehaviorTitleStringAttributes)
        completeConditionTitleString.append(nodeBehaviorTitleString)

        // 准备「参数」

//            let parametersTitleStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.secondaryLabel]
//            var parametersTitle: String = ""
//            if let parameters = condition.parameters {
//                parametersTitle.append(" " + parameters)
//                let parametersTitleString: NSAttributedString = NSAttributedString(string: parametersTitle, attributes: parametersTitleStringAttributes)
//                completeConditionTitleString.append(parametersTitleString)
//            }
//        }

        return completeConditionTitleString
    }

    /// 选择「条件表格视图」单元格
    func selectConditionTableViewCell(indexPath: IndexPath) {

        let _: MetaCondition = conditions[indexPath.row]
    }
}
