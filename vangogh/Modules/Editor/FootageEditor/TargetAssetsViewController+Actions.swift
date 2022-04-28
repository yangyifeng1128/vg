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

    /// 选择目标素材
    func selectTargetAsset(_ targetAsset: PHAsset, cell: TargetAssetCollectionViewCell) {

        delegate?.assetDidPick(targetAsset, thumbImage: cell.thumbImageView.image)

        navigationController?.popViewController(animated: true)
    }
}
