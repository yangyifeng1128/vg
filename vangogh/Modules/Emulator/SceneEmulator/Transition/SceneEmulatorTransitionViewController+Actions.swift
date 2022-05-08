///
/// SceneEmulatorTransitionViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import OSLog
import UIKit

extension SceneEmulatorTransitionViewController {

    @objc func defaultButtonDidTap() {

        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension SceneEmulatorTransitionViewController {

    /// 准备模版数量
    func prepareNextScenesCount() -> Int {

        if nextScenes.isEmpty {
            nextScenesCollectionView.showNoDataInfo(title: NSLocalizedString("NoScenesAvailable", comment: ""))
        } else {
            nextScenesCollectionView.hideNoDataInfo()
        }

        return nextScenes.count
    }

    /// 准备「模版集合视图」单元格
    func prepareNextSceneCollectionViewCell(indexPath: IndexPath) -> UICollectionViewCell {

        let nextScene: MetaScene = nextScenes[indexPath.item]

        guard let cell = nextScenesCollectionView.dequeueReusableCell(withReuseIdentifier: NextSceneCollectionViewCell.reuseId, for: indexPath) as? NextSceneCollectionViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备「标题标签」

        cell.titleLabel.text = nextScene.title

        return cell
    }

    /// 准备「模版集合视图」单元格尺寸
    func prepareNextSceneCollectionViewCellSize(indexPath: IndexPath) -> CGSize {

        var numberOfCellsPerRow: Int
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            numberOfCellsPerRow = 2
            break
        case .pad, .mac, .tv, .carPlay, .unspecified:
            numberOfCellsPerRow = 3
            break
        @unknown default:
            numberOfCellsPerRow = 2
            break
        }

        let cellWidth: CGFloat = ((nextScenesCollectionView.bounds.width - CGFloat(numberOfCellsPerRow + 1) * VC.nextSceneCollectionViewCellSpacing) / CGFloat(numberOfCellsPerRow)).rounded(.down)
        let cellHeight: CGFloat = (cellWidth / GVC.defaultSceneAspectRatio).rounded(.down)

        return CGSize(width: cellWidth, height: cellHeight)
    }

    /// 选择「模版集合视图」单元格
    func selectNextSceneCollectionViewCell(indexPath: IndexPath) {

        let nextScene: MetaScene = nextScenes[indexPath.item]

        print(nextScene)
    }
}
