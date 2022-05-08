///
/// NewGameViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import OSLog
import UIKit

extension NewGameViewController {

    @objc func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }

    @objc func newBlankGameButtonDidTap() {

        addGame { [weak self] game in
            guard let s = self else { return }
            s.pushGameEditorVC(game: game)
            Logger.composition.info("created a new blank game: \"\(game.title)\"")
        }
    }

    @objc func pullToRefreshTemplates() {

        syncTemplates() { [weak self] in
            guard let s = self else { return }
            s.loadTemplates() {
                DispatchQueue.main.async {
                    s.templatesCollectionView.reloadData()
                    s.templatesCollectionView.refreshControl?.endRefreshing()
                }
            }
        }
    }
}

extension NewGameViewController {

    /// 准备模版数量
    func prepareTemplatesCount() -> Int {

        if templates.isEmpty {
            templatesCollectionView.showNoDataInfo(title: NSLocalizedString("NoTemplatesAvailable", comment: ""))
        } else {
            templatesCollectionView.hideNoDataInfo()
        }

        return templates.count
    }

    /// 准备「模版集合视图」单元格
    func prepareTemplateCollectionViewCell(indexPath: IndexPath) -> UICollectionViewCell {

        let template: MetaTemplate = templates[indexPath.item]

        guard let cell = templatesCollectionView.dequeueReusableCell(withReuseIdentifier: TemplateCollectionViewCell.reuseId, for: indexPath) as? TemplateCollectionViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备「标题标签」

        cell.titleLabel.text = template.title

        // 准备「缩略图视图」

        let thumbURL = URL(string: "\(GUC.templateThumbsBaseURLString)/\(template.thumbFileName)")!
        cell.thumbImageView.kf.setImage(with: thumbURL)

        return cell
    }

    /// 准备「模版集合视图」单元格尺寸
    func prepareTemplateCollectionViewCellSize(indexPath: IndexPath) -> CGSize {

        var numberOfCellsPerRow: Int
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            numberOfCellsPerRow = 3
            break
        case .pad, .mac, .tv, .carPlay, .unspecified:
            numberOfCellsPerRow = 5
            break
        @unknown default:
            numberOfCellsPerRow = 3
            break
        }

        let cellWidth: CGFloat = ((templatesCollectionView.bounds.width - CGFloat(numberOfCellsPerRow + 1) * VC.templateCollectionViewCellSpacing) / CGFloat(numberOfCellsPerRow)).rounded(.down)
        let cellHeight: CGFloat = (cellWidth / GVC.defaultSceneAspectRatio).rounded(.down)

        return CGSize(width: cellWidth, height: cellHeight)
    }

    /// 选择「模版集合视图」单元格
    func selectTemplateCollectionViewCell(indexPath: IndexPath) {

        let template: MetaTemplate = templates[indexPath.item]

        addGame { [weak self] game in
            guard let s = self else { return }
            s.pushGameEditorVC(game: game)
            Logger.composition.info("created a new game \"\(game.title)\" with template \"\(template.title)\"")
        }
    }

    /// 跳转至「作品编辑器控制器」
    func pushGameEditorVC(game: MetaGame) {

        guard let gameBundle = MetaGameBundleManager.shared.load(uuid: game.uuid) else { return }

        let gameEditorVC: GameEditorViewController = GameEditorViewController(game: game, gameBundle: gameBundle, parentType: .new)
        gameEditorVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(gameEditorVC, animated: true)
    }
}
