///
/// SceneEmulatorTransitionViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import OSLog
import UIKit

extension SceneEmulatorTransitionViewController {

    @objc func closeButtonDidTap() {

        guard let sceneEmulatorVC = presentingViewController as? SceneEmulatorViewController else { return }

        sceneEmulatorVC.dismiss(animated: false) {
            sceneEmulatorVC.presentingViewController?.dismiss(animated: true)
        }
    }
}

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

        // 准备「缩略图视图」

        cell.thumbImageView.image = .sceneBackgroundThumb
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let s = self else { return }
            if let thumbImage = MetaThumbManager.shared.loadSceneThumbImage(sceneUUID: nextSceneDescriptor.scene.uuid, gameUUID: s.gameBundle.uuid) {
                DispatchQueue.main.async {
                    cell.thumbImageView.image = thumbImage
                }
            }
        }

        // 准备「图标视图」

        if indexPath.item == 0 {
            cell.iconView.image = .replay
            cell.iconView.tintColor = .secondaryLabel
        }

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
            willRestartSelectedScene()
        } else if nextSceneDescriptor.type == .redirectTo {
            willRedirectToScene(nextSceneDescriptor.scene)
        }

        Logger.sceneEmulator.info("\"\(nextSceneDescriptor.type.rawValue)\" -> \"\(nextSceneDescriptor.scene)\"")
    }

    /// 即将重启场景模拟器
    func willRestartSelectedScene() {

        guard let sceneEmulatorVC = presentingViewController as? SceneEmulatorViewController else { return }

        restartSelectedScene() { sceneBundle in
            sceneEmulatorVC.sceneBundle = sceneBundle
            sceneEmulatorVC.dismiss(animated: true) {
                sceneEmulatorVC.resumePlayer()
            }
        }
    }

    func willRedirectToScene(_ scene: MetaScene) {

        guard let sceneEmulatorVC = presentingViewController as? SceneEmulatorViewController else { return }

        redirectToScene(scene) { (sceneBundle, gameBundle) in
            sceneEmulatorVC.sceneBundle = sceneBundle
            sceneEmulatorVC.gameBundle = gameBundle
            sceneEmulatorVC.dismiss(animated: true) {
                sceneEmulatorVC.reloadPlayer()
            }
        }
    }
}

extension SceneEmulatorTransitionViewController {

    /// 切换至手动穿梭
    func switchToManualTransition() {

        stopUpNextTimer() { [weak self] in
            guard let s = self else { return }
            s.updateTitleLabelText("请选择下一个场景")
        }
    }

    /// 开启后续计时器
    func startUpNextTimer() {

        upNextTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let s = self else { return }
            s.upNextTimeSeconds -= 1
            if s.upNextTimeSeconds == 0 {
                s.stopUpNextTimer() {
                    s.willRestartSelectedScene()
                }
            } else {
                s.updateTitleLabelText(s.prepareTitleLabelText())
            }
        }
    }

    /// 更新「标题标签」文本
    func updateTitleLabelText(_ text: String) {

        titleLabel.text = text
    }

    /// 停止后续计时器
    func stopUpNextTimer(completion handler: (() -> Void)? = nil) {

        if let upNextTimer = upNextTimer {
            upNextTimer.invalidate()
        }
        upNextTimer = nil

        if let handler = handler {
            handler()
        }
    }
}
