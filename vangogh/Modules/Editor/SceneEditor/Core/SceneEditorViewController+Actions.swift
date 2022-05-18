///
/// SceneEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVFoundation
import FittedSheets
import Photos
import UIKit

extension SceneEditorViewController {

    @objc func closeButtonDidTap() {

        print("[SceneEditor] did tap closeButton")

        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @objc func saveButtonDidTap() {

        print("[SceneEditor] did tap saveButton")

        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @objc func sceneSettingsButtonDidTap() {

        print("[SceneEditor] did tap sceneSettingsButton")

        openSceneSettings()
    }

    @objc func sceneTitleLabelDidTap() {

        print("[SceneEditor] did tap sceneTitleLabel")
    }

    @objc func playerViewContainerDidTap() {

        print("[SceneEditor] did tap playerViewContainer")

        // 关闭先前展示的「Sheet 视图控制器」（如果有的话）

        dismissPreviousBottomSheetViewController()
    }

    @objc func previewButtonDidTap() {

        print("[SceneEditor] did tap previewButton")

        previewScene()
    }

    @objc func playButtonDidTap() {

        print("[SceneEditor] did tap playButton")

        playOrPause()
    }

    @objc func playerItemDidPlayToEndTime() {

        print("[SceneEditor] player item did play to end time")

        loop()
    }

    @objc func didEnterBackground() {

        print("[SceneEditor] did enter background")

        // 保存场景资源包

        saveSceneBundle() { [weak self] in

            guard let s = self else { return }

            // 暂停播放

            if !s.timeline.videoChannel.isEmpty {
                s.pause()
            }

            // 关闭先前展示的「Sheet 视图控制器」（如果有的话）

            s.dismissPreviousBottomSheetViewController()
        }
    }

    @objc func willEnterForeground() {

        print("[SceneEditor] will enter foreground")

        loadingIndicatorView.startAnimating()
        reloadPlayer()
    }

    func openSceneSettings() {

        let sceneSettingsVC = SceneSettingsViewController(sceneBundle: sceneBundle, gameBundle: gameBundle)
        sceneSettingsVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(sceneSettingsVC, animated: true)
    }

    func previewScene() {

        let sceneEmulatorVC = SceneEmulatorViewController(sceneBundle: sceneBundle, gameBundle: gameBundle)
        sceneEmulatorVC.definesPresentationContext = true
        sceneEmulatorVC.modalPresentationStyle = .currentContext

        present(sceneEmulatorVC, animated: true) {
            sceneEmulatorVC.reloadPlayer()
        }
    }

    func playOrPause() {

        if let player = player {

            if player.timeControlStatus == .playing {

                playButton.isPlaying = false
                player.pause()

            } else {

                playButton.isPlaying = true
                player.play()

                timelineView.unselectAllTrackItemViews()
                timelineView.unselectAllNodeItemViews()
                timelineView.resetBottomView(bottomViewType: .timeline)
            }
        }
    }

    func loop() {

        if let player = player, player.timeControlStatus == .playing {

            playButton.isPlaying = false
            player.pause()

            player.seek(to: .zero)
            player.play()
            playButton.isPlaying = true
        }
    }

    func pause() {

        if let player = player, player.timeControlStatus == .playing {

            playButton.isPlaying = false
            player.pause()
        }
    }

    func resume() {

        if let player = player, player.timeControlStatus != .playing {

            playButton.isPlaying = true
            player.play()

            timelineView.unselectAllTrackItemViews()
            timelineView.unselectAllNodeItemViews()
            timelineView.resetBottomView(bottomViewType: .timeline)
        }
    }

    /// 添加镜头片段
    func addFootage() {

        let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { [weak self] status in
                guard let s = self else { return }
                DispatchQueue.main.async {
                    s.pushTargetAssetsVC()
                }
            })
            break
        case .authorized, .limited:
            pushTargetAssetsVC()
            break
        default:
            let alert = UIAlertController(title: NSLocalizedString("PhotoLibraryAuthorizationDenied", comment: ""), message: NSLocalizedString("PhotoLibraryAuthorizationDeniedInfo", comment: ""), preferredStyle: .alert)
            alert.overrideUserInterfaceStyle = SceneEditorViewController.preferredUserInterfaceStyle // 单独强制设置用户界面风格
            let openSettingsAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("OpenSettings", comment: ""), style: .default) { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            alert.addAction(openSettingsAction)
            let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            }
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }

    /// 跳转至「目标素材控制器」
    func pushTargetAssetsVC() {

        let targetAssetsVC = TargetAssetsViewController()
        targetAssetsVC.delegate = self
        targetAssetsVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(targetAssetsVC, animated: true)
    }

    func deleteMetaFootage(_ footage: MetaFootage) {

        // 创建提示框

        let alert = UIAlertController(title: NSLocalizedString("DeleteFootage", comment: ""), message: NSLocalizedString("DeleteFootageInfo", comment: ""), preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = SceneEditorViewController.preferredUserInterfaceStyle // 单独强制设置用户界面风格

        // 「确认」操作

        let confirmAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { [weak self] _ in

            guard let s = self else { return }

            DispatchQueue.global(qos: .background).async {
                MetaSceneBundleManager.shared.deleteMetaFootage(sceneBundle: s.sceneBundle, footage: footage)
                DispatchQueue.main.sync {
                    s.loadingIndicatorView.startAnimating()
                    s.currentTime = CMTimeMake(value: s.sceneBundle.currentTimeMilliseconds, timescale: GVC.preferredTimescale)
                    s.reloadPlayer()
                }
            }
        }
        alert.addAction(confirmAction)

        // 「取消」操作

        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
        }
        alert.addAction(cancelAction)

        // 展示提示框

        present(alert, animated: true, completion: nil)
    }

    func addMetaNode(nodeType: MetaNodeType) {

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let s = self else { return }
            let node: MetaNode = MetaSceneBundleManager.shared.addMetaNode(sceneBundle: s.sceneBundle, nodeType: nodeType, startTimeMilliseconds: s.currentTime.milliseconds())
            DispatchQueue.main.async {
                s.playerView.addNodeView(node: node)
                s.playerView.showOrHideNodeViews(at: s.currentTime)
                s.timelineView.addNodeItemView(node: node)
                s.timelineView.updateNodeItemViewContainer()
            }
        }
    }

    func deleteMetaNode(_ node: MetaNode) {

        // 创建提示框

        let alert = UIAlertController(title: NSLocalizedString("DeleteNode", comment: ""), message: NSLocalizedString("DeleteNodeInfo", comment: ""), preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = SceneEditorViewController.preferredUserInterfaceStyle // 单独强制设置用户界面风格

        // 「确认」操作

        let confirmAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { [weak self] _ in

            guard let s = self else { return }

            DispatchQueue.global(qos: .background).async {
                MetaSceneBundleManager.shared.deleteMetaNode(sceneBundle: s.sceneBundle, node: node)
                DispatchQueue.main.sync {

                    s.dismissPreviousBottomSheetViewController() // 关闭先前展示的「Sheet 视图控制器」（如果有的话）

                    s.playerView.removeNodeView(node: node)
                    s.timelineView.removeNodeItemView(node: node)
                    s.timelineView.updateNodeItemViewContainer()
                    s.timelineView.resetBottomView(bottomViewType: .timeline)
                }
            }
        }
        alert.addAction(confirmAction)

        // 「取消」操作

        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
        }
        alert.addAction(cancelAction)

        // 展示提示框

        present(alert, animated: true, completion: nil)
    }

    func isSceneBundleEmpty() -> Bool {

        return sceneBundle.footages.isEmpty && sceneBundle.nodes.isEmpty
    }

    func requestPhotoLibraryAuthorization(handler: @escaping (PHAuthorizationStatus) -> Void) {

        let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { status in
                handler(status)
            })
        } else {
            handler(status)
        }
    }
}

extension SceneEditorViewController {

    func presentAddNodeItemSheetViewController(toolBarItem: TimelineToolBarItem) {

        // 关闭先前展示的「Sheet 视图控制器」（如果有的话）

        dismissPreviousBottomSheetViewController()

        // 展示「添加组件项 Sheet 视图控制器」

        let addNodeItemVC: AddNodeItemViewController = AddNodeItemViewController(toolBarItem: toolBarItem)
        addNodeItemVC.delegate = self

        let sheetHeight: CGFloat = view.safeAreaInsets.bottom + AddNodeItemViewController.VC.height

        presentSheetViewController(controller: addNodeItemVC, sizes: [.fixed(sheetHeight)], cornerRadius: GVC.bottomSheetViewCornerRadius)
    }

    func presentEditNodeItemSheetViewController(node: MetaNode) {

        // 关闭先前展示的「Sheet 视图控制器」（如果有的话）

        dismissPreviousBottomSheetViewController()

        // 激活「播放器-组件」视图

        if let nodeView = playerView.nodeViewList.first(where: { $0.node.uuid == node.uuid }) {
            nodeView.isActive = true
        }

        // 展示「编辑组件项 Sheet 视图控制器」

        let editNodeItemVC = EditNodeItemViewController(node: node, rules: sceneBundle.findNodeRules(index: node.index))
        editNodeItemVC.delegate = self

        let minSheetHeight: CGFloat = view.safeAreaInsets.bottom + SceneEditorViewController.VC.workspaceViewHeight + SceneEditorViewController.VC.actionBarViewHeight
        let maxSheetHeight: CGFloat = view.safeAreaInsets.bottom + SceneEditorViewController.VC.workspaceViewHeight + SceneEditorViewController.VC.actionBarViewHeight + renderSize.height

        presentSheetViewController(controller: editNodeItemVC, sizes: [.fixed(minSheetHeight), .fixed(maxSheetHeight)], cornerRadius: 0)
    }

    func presentSheetViewController(controller: UIViewController, sizes: [SheetSize], cornerRadius: CGFloat) {

        // 展示「Sheet 视图控制器」

        let options: SheetOptions = SheetOptions(
            pullBarHeight: GVC.bottomSheetViewPullBarHeight,
            shouldExtendBackground: true,
            useInlineMode: true
        )

        bottomSheetViewController = SheetViewController(controller: controller, sizes: sizes, options: options)
        if let vc = bottomSheetViewController {
            vc.gripSize = CGSize(width: GVC.bottomSheetViewGripWidth, height: GVC.bottomSheetViewGripHeight)
            vc.gripColor = .mgLabel
            vc.cornerRadius = cornerRadius
            vc.allowGestureThroughOverlay = true
            vc.didDismiss = { [weak self] vc -> Void in
                guard let s = self else { return }
                s.dismissPreviousBottomSheetViewController()
            }
            vc.animateIn(to: view, in: self)
        }
    }

    func dismissPreviousBottomSheetViewController() {

        // 取消激活全部已激活的「播放器-组件视图」

        playerView.nodeViewList.filter({ $0.isActive }).forEach {
            $0.isActive = false
        }

        // 关闭先前展示的「Sheet 视图控制器」

        if let vc = bottomSheetViewController {
            vc.animateOut()
            bottomSheetViewController = nil
        }
    }
}
