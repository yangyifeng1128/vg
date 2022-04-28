///
/// TargetAssetsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Photos
import UIKit

extension TargetAssetsViewController: PHPhotoLibraryChangeObserver {

    func photoLibraryDidChange(_ changeInstance: PHChange) {

        guard let changeDetails = changeInstance.changeDetails(for: assets) else { return }

        DispatchQueue.main.sync { [weak self] in

            guard let s = self else { return }

            // 重新获取素材

            s.assets = changeDetails.fetchResultAfterChanges

            if changeDetails.hasIncrementalChanges { // 如果存在增量更新
                s.targetAssetsCollectionView.performBatchUpdates({
                    if let removed = changeDetails.removedIndexes, !removed.isEmpty {
                        s.targetAssetsCollectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changeDetails.insertedIndexes, !inserted.isEmpty {
                        s.targetAssetsCollectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changeDetails.enumerateMoves { fromIndex, toIndex in
                        s.targetAssetsCollectionView.moveItem(at: IndexPath(item: fromIndex, section: 0), to: IndexPath(item: toIndex, section: 0))
                    }
                })
                // We are reloading items after the batch update since `PHFetchResultChangeDetails.changedIndexes` refers to items in the *after* state and not the *before* state as expected by `performBatchUpdates(_:completion:)`
                if let changed = changeDetails.changedIndexes, !changed.isEmpty {
                    s.targetAssetsCollectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                }
            } else {
                s.targetAssetsCollectionView.reloadData()
            }

            // 重置缓存素材

            resetCachedAssets()
        }
    }
}

extension TargetAssetsViewController {

    /// 加载素材列表
    func loadAssets(menuItemIndex: Int) {

        var type: PHAssetMediaType = .image
        switch menuItemIndex {
        case 0:
            type = .image
            break
        case 1:
            type = .video
            break
        default:
            break
        }

        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        assets = PHAsset.fetchAssets(with: type, options: options)

        targetAssetsCollectionView.reloadData()
        if assets.count > 0 {
            targetAssetsCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }

    /// 更新缓存素材列表
    func updateCachedAssets() {

        // The window you prepare ahead of time is twice the height of the visible rect

        let visibleRect = CGRect(origin: targetAssetsCollectionView.contentOffset, size: targetAssetsCollectionView.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)

        // Update only if the visible area is significantly different from the last preheated area

        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }

        // Compute the assets to start and stop caching

        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in targetAssetsCollectionView.indexPathsForElements(in: rect) }
            .map { indexPath in assets.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in targetAssetsCollectionView.indexPathsForElements(in: rect) }
            .map { indexPath in assets.object(at: indexPath.item) }

        // Update the assets the PHCachingImageManager is caching

        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: targetAssetsCollectionViewCellSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: targetAssetsCollectionViewCellSize, contentMode: .aspectFill, options: nil)

        // Store the computed rectangle for future comparison

        previousPreheatRect = preheatRect
    }

    private func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {

        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }

    func resetCachedAssets() {

        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
}

private extension UICollectionView {

    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {

        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}
