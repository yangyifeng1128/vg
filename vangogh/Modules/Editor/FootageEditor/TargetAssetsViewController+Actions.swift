///
/// TargetAssetsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Photos
import UIKit

extension TargetAssetsViewController {

    @objc func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }

    @objc func collectionViewDidSwipeLeft() {

        var index = menuControl.selectedSegmentIndex - 1
        if index < 0 { index = menuItems.count - 1 }
        menuControl.selectedSegmentIndex = index
        menuControl.sendActions(for: .valueChanged)
    }

    @objc func collectionViewDidSwipeRight() {

        var index = menuControl.selectedSegmentIndex + 1
        if index > menuItems.count - 1 { index = 0 }
        menuControl.selectedSegmentIndex = index
        menuControl.sendActions(for: .valueChanged)
    }

    @objc func menuControlDidChange() {

        loadAssets(menuItemIndex: menuControl.selectedSegmentIndex)
    }
}

extension TargetAssetsViewController {

    /// 准备目标素材数量
    func prepareTargetAssetsCount() -> Int {

        if assets.count == 0 {
            var noDataInfoTitle: String = NSLocalizedString("NoPicturesAvailable", comment: "")
            switch menuControl.selectedSegmentIndex {
            case 0:
                noDataInfoTitle = NSLocalizedString("NoPicturesAvailable", comment: "")
                break
            case 1:
                noDataInfoTitle = NSLocalizedString("NoVideosAvailable", comment: "")
                break
            default:
                break
            }
            targetAssetsCollectionView.showNoDataInfo(title: noDataInfoTitle)
        } else {
            targetAssetsCollectionView.hideNoDataInfo()
        }

        return assets.count
    }

    /// 准备「目标素材集合视图」单元格
    func prepareTargetAssetCollectionViewCell(indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = targetAssetsCollectionView.dequeueReusableCell(withReuseIdentifier: TargetAssetCollectionViewCell.reuseId, for: indexPath) as? TargetAssetCollectionViewCell else {
            fatalError("Unexpected cell type")
        }

        let asset = assets.object(at: indexPath.item)

        // 准备「缩略图视图」

        cell.assetIdentifier = asset.localIdentifier

        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        let scale = UIScreen.main.scale
        let targetSize: CGSize = CGSize(width: targetAssetCollectionViewCellSize.width * scale, height: targetAssetCollectionViewCellSize.height * scale)
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (image, info) in
            if cell.assetIdentifier == asset.localIdentifier {
                cell.thumbImageView.image = image
            }
        }

        // 准备「视频时长标签」

        if asset.mediaType == .video {
            cell.videoDurationLabel.isHidden = false
            let formatter: DateComponentsFormatter = DateComponentsFormatter()
            formatter.unitsStyle = .positional
            formatter.allowedUnits = [.minute, .second]
            formatter.zeroFormattingBehavior = [.pad]
            cell.videoDurationLabel.text = formatter.string(from: asset.duration)
        } else {
            cell.videoDurationLabel.isHidden = true
            cell.videoDurationLabel.text = ""
        }

        return cell
    }

    /// 准备「目标素材集合视图」单元格尺寸
    func prepareTargetAssetCollectionViewCellSize() {

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

        let cellSpacing = VC.targetAssetCollectionViewCellSpacing

        let cellWidth: CGFloat = ((view.bounds.width - VC.targetAssetsCollectionViewInsetX * 2 - CGFloat(numberOfCellsPerRow + 1) * cellSpacing) / CGFloat(numberOfCellsPerRow)).rounded(.down)
        let cellHeight: CGFloat = (cellWidth / GVC.defaultSceneAspectRatio).rounded(.down)

        targetAssetCollectionViewCellSize = CGSize(width: cellWidth, height: cellHeight)
    }

    /// 选择「目标素材集合视图」单元格
    func selectTargetAssetCollectionViewCell(indexPath: IndexPath, cell: TargetAssetCollectionViewCell) {

        let targetAsset: PHAsset = assets[indexPath.item]

        delegate?.assetDidPick(targetAsset, thumbImage: cell.thumbImageView.image)

        navigationController?.popViewController(animated: true)
    }
}
