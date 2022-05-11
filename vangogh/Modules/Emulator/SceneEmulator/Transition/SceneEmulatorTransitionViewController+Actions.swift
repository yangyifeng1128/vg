///
/// SceneEmulatorTransitionViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import OSLog
import UIKit

extension SceneEmulatorTransitionViewController {

    /// 准备「标题标签」文本
    func prepareTitleLabelText() -> String {

        return String.localizedStringWithFormat(NSLocalizedString("UpNextIn", comment: ""), upNextTimeSeconds)
    }

    /// 准备后续场景描述符数量
    func prepareNextSceneDescriptorsCount() -> Int {

        if nextSceneDescriptors.isEmpty {
            nextSceneDescriptorsCollectionView.showNoDataInfo(title: NSLocalizedString("NoNextSceneDescriptorsAvailable", comment: ""))
        } else {
            nextSceneDescriptorsCollectionView.hideNoDataInfo()
        }

        return nextSceneDescriptors.count
    }

    /// 准备「后续场景描述符集合视图」单元格
    func prepareNextSceneDescriptorCollectionViewCell(indexPath: IndexPath) -> UICollectionViewCell {

        let nextSceneDescriptor: NextSceneDescriptor = nextSceneDescriptors[indexPath.item]

        guard let cell = nextSceneDescriptorsCollectionView.dequeueReusableCell(withReuseIdentifier: NextSceneDescriptorCollectionViewCell.reuseId, for: indexPath) as? NextSceneDescriptorCollectionViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备「标题标签」

        cell.titleLabel.text = nextSceneDescriptor.scene.title

        return cell
    }

    /// 准备「后续场景描述符集合视图」单元格尺寸
    func prepareNextSceneDescriptorCollectionViewCellSize(indexPath: IndexPath) -> CGSize {

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

        let cellWidth: CGFloat = ((nextSceneDescriptorsCollectionView.bounds.width - CGFloat(numberOfCellsPerRow + 1) * VC.nextSceneDescriptorCollectionViewCellSpacing) / CGFloat(numberOfCellsPerRow)).rounded(.down)
        let cellHeight: CGFloat = (cellWidth / GVC.defaultSceneAspectRatio).rounded(.down)

        return CGSize(width: cellWidth, height: cellHeight)
    }

    /// 选择「后续场景描述符集合视图」单元格
    func selectNextSceneDescriptorCollectionViewCell(indexPath: IndexPath) {

        let nextSceneDescriptor: NextSceneDescriptor = nextSceneDescriptors[indexPath.item]

        if nextSceneDescriptor.type == .restart {
            willRestartSceneEmulator()
        }

        Logger.sceneEmulator.info("\"\(nextSceneDescriptor.type.rawValue)\" -> \"\(nextSceneDescriptor.scene)\"")
    }

    /// 即将重启场景模拟器
    func willRestartSceneEmulator() {

        guard let sceneEmulatorVC = presentingViewController as? SceneEmulatorViewController else { return }

        restartSelectedScene() { sceneBundle in
            sceneEmulatorVC.sceneBundle = sceneBundle
            sceneEmulatorVC.needsReloadPlayer = false
            sceneEmulatorVC.dismiss(animated: true, completion: nil)
        }
    }
}

extension SceneEmulatorTransitionViewController {

    /// 开启后续计时器
    func startUpNextTimer() {

        upNextTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let s = self else { return }
            s.upNextTimeSeconds -= 1
            if s.upNextTimeSeconds == 0 {
                s.stopUpNextTimer()
                s.willRestartSceneEmulator()
            } else {
                s.updateTitleLabelText()
            }
        }
    }

    /// 更新「标题标签」文本
    func updateTitleLabelText() {

        titleLabel.text = prepareTitleLabelText()
    }

    /// 停止后续计时器
    func stopUpNextTimer() {

        if let upNextTimer = upNextTimer {
            upNextTimer.invalidate()
        }
        upNextTimer = nil
    }
}
