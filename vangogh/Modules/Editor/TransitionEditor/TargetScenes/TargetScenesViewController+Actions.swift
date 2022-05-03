///
/// TargetScenesViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import OSLog
import UIKit

extension TargetScenesViewController {

    @objc func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }
}

extension TargetScenesViewController {

    /// 准备目标场景数量
    func prepareTargetScenesCount() -> Int {

        if targetScenes.isEmpty {
            targetScenesTableView.showNoDataInfo(title: NSLocalizedString("NoTargetScenesAvailable", comment: ""))
        } else {
            targetScenesTableView.hideNoDataInfo()
        }

        return targetScenes.count
    }

    /// 准备「目标场景表格视图」单元格
    func prepareTargetSceneTableViewCell(indexPath: IndexPath) -> UITableViewCell {

        let targetScene: MetaScene = targetScenes[indexPath.row]

        guard let cell = targetScenesTableView.dequeueReusableCell(withIdentifier: TargetSceneTableViewCell.reuseId) as? TargetSceneTableViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备「缩略图视图」

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let s = self else { return }
            if let thumbImage = MetaThumbManager.shared.loadSceneThumbImage(sceneUUID: targetScene.uuid, gameUUID: s.gameBundle.uuid) {
                DispatchQueue.main.async {
                    cell.thumbImageView.image = thumbImage
                }
            } else {
                DispatchQueue.main.async {
                    cell.thumbImageView.image = .sceneBackgroundThumb
                }
            }
        }

        // 准备「索引标签」

        cell.indexLabel.text = targetScene.index.description

        // 准备「标题标签」

        cell.titleLabel.attributedText = prepareTargetSceneTitleLabelAttributedText(scene: targetScene)
        cell.titleLabel.numberOfLines = 2
        cell.titleLabel.lineBreakMode = .byTruncatingTail

        return cell
    }

    /// 准备「目标场景标题标签」文本
    func prepareTargetSceneTitleLabelAttributedText(scene: MetaScene) -> NSMutableAttributedString {

        let completeTitleString: NSMutableAttributedString = NSMutableAttributedString(string: "")

        // 准备场景标题

        var titleString: NSAttributedString
        if let title = scene.title, !title.isEmpty {
            let titleStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.mgLabel!]
            titleString = NSAttributedString(string: title, attributes: titleStringAttributes)
        } else {
            let titleStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.secondaryLabel]
            titleString = NSAttributedString(string: NSLocalizedString("Untitled", comment: ""), attributes: titleStringAttributes)
        }
        completeTitleString.append(titleString)

        // 准备段落样式

        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        completeTitleString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, completeTitleString.length))

        return completeTitleString
    }

    /// 选择「目标场景表格视图」单元格
    func selectTargetSceneTableViewCell(indexPath: IndexPath) {

        let targetScene: MetaScene = targetScenes[indexPath.row]
        Logger.gameEditor.info("selected target scene: \(targetScene.index)")

        // FIXME：重新处理「MetaTransition - MetaCondition」

        var conditions = [MetaCondition]()
        let defaultCondition = MetaCondition(sensor: MetaSensor(gameUUID: gameBundle.uuid, sceneUUID: nil, nodeUUID: nil, key: .timeControl), operatorKey: .equalTo, value: "end")
        conditions.append(defaultCondition)
//        let testCondition = MetaCondition(nodeIndex: 0, nodeType: 1, nodeBehaviorType: 12, parameters: "2次")
//        conditions.append(testCondition)
//        let test2Condition = MetaCondition(nodeIndex: 1, nodeType: 2, nodeBehaviorType: 21)
//        conditions.append(test2Condition)
//        let test3Condition = MetaCondition(nodeIndex: 2, nodeType: 3, nodeBehaviorType: 31, parameters: "(B)")
//        conditions.append(test3Condition)
//        let test4Condition = MetaCondition(nodeIndex: 3, nodeType: 4, nodeBehaviorType: 41, parameters: "3次")
//        conditions.append(test4Condition)
//        let test5Condition = MetaCondition(nodeIndex: 4, nodeType: 5, nodeBehaviorType: 51, parameters: "(熊猫)")
//        conditions.append(test5Condition)

        if let transition = gameBundle.addTransition(from: gameBundle.selectedSceneIndex, to: targetScene.index, conditions: conditions) {

            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let s = self else { return }
                MetaGameBundleManager.shared.save(s.gameBundle)
            }

            GameEditorExternalChangeManager.shared.set(key: .addTransition, value: transition) // 保存作品编辑器外部变更字典
        }

        // 返回父视图

        navigationController?.popViewController(animated: true)
    }
}
