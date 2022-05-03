///
/// PublicationViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension PublicationViewController {

    @objc func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }

    @objc func gameSettingsButtonDidTap() {

        pushGameSettingsVC()
    }

    @objc func publishButtonDidTap() {

    }

    @objc func pullToRefreshArchives() {

        syncArchives() { [weak self] in
            guard let s = self else { return }
            s.loadArchives() {
                DispatchQueue.main.async {
                    s.archivesCollectionView.reloadData()
                    s.archivesCollectionView.refreshControl?.endRefreshing()
                }
            }
        }
    }
}

extension PublicationViewController {

    /// 准备档案数量
    func prepareArchivesCount() -> Int {

        if archives.isEmpty {
            archivesCollectionView.showNoDataInfo(title: NSLocalizedString("NoArchivesAvailable", comment: ""))
        } else {
            archivesCollectionView.hideNoDataInfo()
        }

        return archives.count
    }

    /// 准备「档案集合视图」单元格
    func prepareArchiveCollectionViewCell(indexPath: IndexPath) -> UICollectionViewCell {

        let archive: MetaTemplate = archives[indexPath.item]

        guard let cell = archivesCollectionView.dequeueReusableCell(withReuseIdentifier: ArchiveCollectionViewCell.reuseId, for: indexPath) as? ArchiveCollectionViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备「标题标签」

        cell.titleLabel.text = archive.title

        // 准备「缩略图视图」

        let thumbURL = URL(string: "\(GUC.templateThumbsBaseURLString)/\(archive.thumbFileName)")!
        cell.thumbImageView.kf.setImage(with: thumbURL)

        return cell
    }

    /// 准备「模版集合视图」单元格尺寸
    func prepareArchiveCollectionViewCellSize(indexPath: IndexPath) -> CGSize {

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

        let cellWidth: CGFloat = ((archivesCollectionView.bounds.width - CGFloat(numberOfCellsPerRow + 1) * VC.archiveCollectionViewCellSpacing) / CGFloat(numberOfCellsPerRow)).rounded(.down)
        let cellHeight: CGFloat = (cellWidth / GVC.defaultSceneAspectRatio).rounded(.down)

        return CGSize(width: cellWidth, height: cellHeight)
    }

    /// 选择「档案集合视图」单元格
    func selectArchiveCollectionViewCell(indexPath: IndexPath) {

        let _: MetaTemplate = archives[indexPath.item]
    }

    /// 跳转至「作品设置控制器」
    func pushGameSettingsVC() {

        let gameSettingsVC = GameSettingsViewController(game: game)
        gameSettingsVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(gameSettingsVC, animated: true)
    }
}
