///
/// GameEditorSceneExplorerView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension GameEditorSceneExplorerView {

    @objc func closeSceneButtonDidTap() {

        delegate?.closeSceneButtonDidTap()
    }

    @objc func deleteSceneButtonDidTap() {

        delegate?.deleteSceneButtonDidTap()
    }

    @objc func sceneTitleLabelDidTap() {

        delegate?.sceneTitleLabelDidTap()
    }

    @objc func manageTransitionsButtonDidTap() {

        delegate?.manageTransitionsButtonDidTap()
    }

    @objc func previewSceneButtonDidTap() {

        delegate?.previewSceneButtonDidTap()
    }

    @objc func editSceneButtonDidTap() {

        delegate?.editSceneButtonDidTap()
    }
}

extension GameEditorSceneExplorerView {

    /// 重新加载数据
    func reloadData() {

        updateSceneTitleLabel()
        transitionsTableView.reloadData()
    }

    /// 更新「场景标题标签」
    func updateSceneTitleLabel() {

        sceneTitleLabel.attributedText = prepareSceneTitleLabelAttributedText()
        sceneTitleLabel.numberOfLines = 2
        sceneTitleLabel.lineBreakMode = .byTruncatingTail
    }

    /// 准备「场景标题标签」文本
    func prepareSceneTitleLabelAttributedText() -> NSMutableAttributedString {

        let completeTitleString: NSMutableAttributedString = NSMutableAttributedString(string: "")

        guard let dataSource = dataSource, let scene = dataSource.selectedScene() else { return completeTitleString }

        // 准备场景索引

        let indexStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.secondaryLabel]
        let indexString: NSAttributedString = NSAttributedString(string: NSLocalizedString("Scene", comment: "") + " " + scene.index.description + "  ", attributes: indexStringAttributes)
        completeTitleString.append(indexString)

        // 准备场景标题

        let titleStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.mgLabel!, .underlineStyle: NSUnderlineStyle.single.rawValue, .underlineColor: UIColor.secondaryLabel]
        var titleString: NSAttributedString
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
}

extension GameEditorSceneExplorerView {

    /// 准备穿梭器数量
    func prepareTransitionsCount() -> Int {

        guard let dataSource = dataSource else { fatalError("Unexpected data source") }

        let transitionsCount: Int = dataSource.numberOfTransitionTableViewCells()

        if transitionsCount <= 0 {

            manageTransitionsButton.snp.updateConstraints { make -> Void in
                make.height.equalTo(VC.manageTransitionsButtonMinHeight)
            }
            manageTransitionsButton.isHidden = true

            transitionsTableView.showNoDataInfo(title: NSLocalizedString("NoTransitionsAvailable", comment: ""), oops: false)
            transitionsView.isHidden = true

        } else {

            manageTransitionsButton.snp.updateConstraints { make -> Void in
                make.height.equalTo(VC.manageTransitionsButtonHeight)
            }
            // manageTransitionsButton.isHidden = false
            manageTransitionsButton.isHidden = true

            transitionsTableView.hideNoDataInfo()
        }

        return transitionsCount
    }
}
