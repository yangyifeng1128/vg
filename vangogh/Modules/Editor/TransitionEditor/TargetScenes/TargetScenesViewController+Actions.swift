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

        if let thumbImage = MetaThumbManager.shared.loadSceneThumbImage(sceneUUID: targetScene.uuid, gameUUID: gameBundle.uuid) {
            cell.thumbImageView.image = thumbImage
        } else {
            cell.thumbImageView.image = .sceneBackgroundThumb
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
        let titleStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.mgLabel!]
        if let title = scene.title, !title.isEmpty {
            titleString = NSAttributedString(string: title, attributes: titleStringAttributes)
        } else {
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

        addTransition(from: selectedScene.index, to: targetScene.index) { [weak self] in
            guard let s = self else { return }
            s.navigationController?.popViewController(animated: true)
        }
    }
}
