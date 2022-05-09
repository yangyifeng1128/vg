///
/// SceneEmulatorTransitionViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import OSLog
import UIKit

extension SceneEmulatorTransitionViewController {

    @objc func defaultButtonDidTap() {

        print("default button tapped")

        let parentVC = presentingViewController?.children.last

        if let sceneEmulatorVC = parentVC as? SceneEmulatorViewController {

            sceneEmulatorVC.needsReloadPlayer = false // 禁止重新加载播放器
        }

        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension SceneEmulatorTransitionViewController {

    /// 准备后续场景提示器数量
    func prepareNextSceneIndicatorsCount() -> Int {

        if nextSceneIndicators.isEmpty {
            nextSceneIndicatorsCollectionView.showNoDataInfo(title: NSLocalizedString("NoScenesAvailable", comment: ""))
        } else {
            nextSceneIndicatorsCollectionView.hideNoDataInfo()
        }

        return nextSceneIndicators.count
    }

    /// 准备「后续场景提示器集合视图」单元格
    func prepareNextSceneIndicatorCollectionViewCell(indexPath: IndexPath) -> UICollectionViewCell {

        let nextScene: NextSceneIndicator = nextSceneIndicators[indexPath.item]

        guard let cell = nextSceneIndicatorsCollectionView.dequeueReusableCell(withReuseIdentifier: NextSceneIndicatorCollectionViewCell.reuseId, for: indexPath) as? NextSceneIndicatorCollectionViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备「标题标签」

        cell.hero.id = "SceneEmulatorPlayerView"
        cell.titleLabel.text = nextScene.title

        return cell
    }

    /// 准备「后续场景提示器集合视图」单元格尺寸
    func prepareNextSceneIndicatorCollectionViewCellSize(indexPath: IndexPath) -> CGSize {

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

        let cellWidth: CGFloat = ((nextSceneIndicatorsCollectionView.bounds.width - CGFloat(numberOfCellsPerRow + 1) * VC.nextSceneIndicatorCollectionViewCellSpacing) / CGFloat(numberOfCellsPerRow)).rounded(.down)
        let cellHeight: CGFloat = (cellWidth / GVC.defaultSceneAspectRatio).rounded(.down)

        return CGSize(width: cellWidth, height: cellHeight)
    }

    /// 选择「后续场景提示器集合视图」单元格
    func selectNextSceneIndicatorCollectionViewCell(indexPath: IndexPath) {

        let nextSceneIndicator: NextSceneIndicator = nextSceneIndicators[indexPath.item]

        if nextSceneIndicator.type == .loop {

            presentingViewController?.dismiss(animated: true, completion: nil)
        }

        print(nextSceneIndicator)
    }
}
