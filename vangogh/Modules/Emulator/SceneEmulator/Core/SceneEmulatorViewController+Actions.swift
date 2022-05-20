///
/// SceneEmulatorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVKit
import OSLog
import UIKit

extension SceneEmulatorViewController {

    @objc func closeButtonDidTap() {

        let parentVC = presentingViewController?.children.last

        if let gameEditorVC = parentVC as? GameEditorViewController {

            // FIXME
            print("如果在SceneEmulator中改变了scene，返回前看看变没变: \(gameEditorVC.gameBundle.selectedSceneIndex)")

        } else if let sceneEditorVC = parentVC as? SceneEditorViewController {

            sceneEditorVC.needsReloadPlayer = false // 禁止重新加载播放器
        }

        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @objc func playerItemDidPlayToEndTime() {

        Logger.sceneEmulator.info("player item did play to end time")

        stop()

        presentSceneEmulatorTransitionVC()
    }

    @objc func didEnterBackground() {

        Logger.sceneEmulator.info("application did enter background")

        // 保存场景资源包

        saveSceneBundle() { [weak self] in

            guard let s = self else { return }

            // 暂停播放

            s.stop()
        }
    }

    @objc func willEnterForeground() {

        Logger.sceneEmulator.info("application will enter foreground")

        // 恢复播放器

        resumePlayer()
    }
}

extension SceneEmulatorViewController {

    /// 重新加载播放器
    func reloadPlayer() {

        loadingIndicatorView.startAnimating()

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in

            guard let s = self else { return }

            // 重新加载轨道项列表

            s.reloadTrackItems()

            DispatchQueue.main.sync {
                s.loadingIndicatorView.progress = 0.33
            }

            // 重新初始化播放器

            let compositionGenerator = CompositionGenerator(timeline: s.timeline)
            s.playerItem = compositionGenerator.buildPlayerItem()

            if s.player == nil {
                s.player = AVPlayer.init(playerItem: s.playerItem)
                try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []) // 如果手机处于静音模式，则打开音频播放
            } else {
                s.removePeriodicTimeObserver() // 移除周期时刻观察器
                NotificationCenter.default.removeObserver(s) // 移除其他全部监听器
                s.player.replaceCurrentItem(with: s.playerItem)
            }

            s.player.seek(to: CMTimeMake(value: s.sceneBundle.currentTimeMilliseconds, timescale: GVC.preferredTimescale), toleranceBefore: .zero, toleranceAfter: .zero)
            s.addPeriodicTimeObserver() // 添加周期时刻观察器
            NotificationCenter.default.addObserver(s, selector: #selector(s.playerItemDidPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: s.player.currentItem) // 添加「播放完毕」监听器
            NotificationCenter.default.addObserver(s, selector: #selector(s.didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil) // 添加「进入后台」监听器
            NotificationCenter.default.addObserver(s, selector: #selector(s.willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil) // 添加「进入前台」监听器
            DispatchQueue.main.sync {
                s.loadingIndicatorView.progress = 0.67
            }

            // 重新初始化界面

            DispatchQueue.main.async {
                s.playerView.rendererView.player = s.player
                s.playerView.interactionView.updateNodeViews(nodes: s.sceneBundle.nodes)
                s.playControlView.progressView.updateNodeItemViews(nodes: s.sceneBundle.nodes, playerItemDurationMilliseconds: s.playerItem.duration.milliseconds())
                s.loadingIndicatorView.stopAnimating()
                s.playOrPause()
            }
        }
    }

    /// 重新加载轨道项列表
    func reloadTrackItems() {

        var trackItems: [TrackItem] = []

        for footage in sceneBundle.footages {

            var trackItem: TrackItem?

            if footage.footageType == .image {

                let footageURL: URL = MetaSceneBundleManager.shared.getMetaImageFootageFileURL(footageUUID: footage.uuid, sceneUUID: sceneBundle.sceneUUID, gameUUID: sceneBundle.gameUUID)

                if let image = CIImage(contentsOf: footageURL) {
                    let resource: ImageResource = ImageResource(image: image, duration: CMTimeMake(value: footage.durationMilliseconds, timescale: GVC.preferredTimescale))
                    trackItem = TrackItem(resource: resource)
                }

            } else if footage.footageType == .video {

                let footageURL: URL = MetaSceneBundleManager.shared.getMetaVideoFootageFileURL(footageUUID: footage.uuid, sceneUUID: sceneBundle.sceneUUID, gameUUID: sceneBundle.gameUUID)

                let asset: AVAsset = AVAsset(url: footageURL)
                let resource: AVAssetTrackResource = AVAssetTrackResource(asset: asset)
                resource.selectedTimeRange = CMTimeRange(start: CMTimeMake(value: footage.leftMarkTimeMilliseconds, timescale: GVC.preferredTimescale), duration: CMTimeMake(value: footage.durationMilliseconds, timescale: GVC.preferredTimescale))
                trackItem = TrackItem(resource: resource)
            }

            if let trackItem = trackItem {

                let videoTransition: NoneTransition = NoneTransition(duration: .zero)
                trackItem.videoTransition = videoTransition
                trackItem.videoConfiguration.contentMode = .aspectFill // 此处采用 aspectFill（而非 aspectFit）的原因是尽量将视频填满播放器

                trackItems.append(trackItem)
            }
        }

        timeline.videoChannel = trackItems
        timeline.audioChannel = trackItems

        try? Timeline.reloadVideoStartTime(providers: timeline.videoChannel)

        let scale: CGFloat = UIScreen.main.scale
        timeline.renderSize = CGSize(width: playerView.renderSize.width * scale, height: playerView.renderSize.height * scale)
    }

    /// 添加周期时刻观察器
    func addPeriodicTimeObserver() {

        let interval: CMTime = CMTimeMake(value: 1, timescale: 100)
        periodicTimeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] currentTime in
            guard let s = self else { return }
            s.currentTime = currentTime
        }
    }

    /// 移除周期时刻观察器
    func removePeriodicTimeObserver() {

        if let timeObserver = periodicTimeObserver {
            player.removeTimeObserver(timeObserver)
            periodicTimeObserver = nil
        }
    }

    /// 恢复播放器
    func resumePlayer() {

        if let player = player {

            player.seek(to: CMTimeMake(value: sceneBundle.currentTimeMilliseconds, timescale: GVC.preferredTimescale), toleranceBefore: .zero, toleranceAfter: .zero)
            play()
        }
    }
}

extension SceneEmulatorViewController {

    /// 播放或暂停播放
    func playOrPause() {

        if player.timeControlStatus == .playing {
            pause()
        } else {
            play()
        }
    }

    /// 播放
    func play() {

        player.play()
        playControlView.play()

        closeButtonContainer.isHidden = true
    }

    /// 暂停播放
    func pause() {

        player.pause()
        playControlView.pause()

        closeButtonContainer.isHidden = false
    }

    /// 停止播放
    func stop() {

        player.pause()
        playControlView.stop()

        player.seek(to: .zero)
        playControlView.seek(to: 0)

        closeButtonContainer.isHidden = true
    }
}
