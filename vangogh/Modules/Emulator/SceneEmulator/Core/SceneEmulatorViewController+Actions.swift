///
/// SceneEmulatorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVKit
import UIKit

extension SceneEmulatorViewController {

    @objc func closeButtonDidTap() {

        print("[SceneEmulator] did tap closeButton")

        let parentVC = presentingViewController?.children.last

        if let gameEditorVC = parentVC as? GameEditorViewController {

            gameBundle.selectedSceneIndex = 1 // FIXME：保存当前选中的场景
            print(gameEditorVC)

        } else if let sceneEditorVC = parentVC as? SceneEditorViewController {

            sceneEditorVC.needsReloadPlayer = false // 禁止重新加载播放器
        }

        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @objc func playButtonDidTap() {

        print("[SceneEmulator] did tap playButton")

        playOrPause()
    }

    @objc func playerItemDidPlayToEndTime() {

        print("[SceneEmulator] player item did play to end time")

        loop()
    }

    @objc func didEnterBackground() {

        print("[SceneEmulator] did enter background")

        if !timeline.videoChannel.isEmpty {
            pause()
        }

        saveSceneBundle()
    }

    @objc func willEnterForeground() {

        print("[SceneEmulator] will enter foreground")

        loadingView.startAnimating()
        reloadPlayer()
    }
}

extension SceneEmulatorViewController {

    func reloadPlayer() {

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in

            guard let s = self else { return }

            // （重新）加载时间线

            s.reloadTimeline()
            DispatchQueue.main.sync {
                s.loadingView.progress = 0.33
            }

            // （重新）初始化播放器

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
                s.loadingView.progress = 0.67
            }

            // （重新）初始化界面

            DispatchQueue.main.async {
                s.updatePlayerRelatedViews() // 更新播放器相关的界面
                s.loadingView.stopAnimating() // 停止加载视图的加载动画
                if !s.timeline.videoChannel.isEmpty {
                    s.playOrPause() // 立即播放
                }
            }
        }
    }

    func reloadTimeline() {

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

        let scale = UIScreen.main.scale
        timeline.renderSize = CGSize(width: renderSize.width * scale, height: renderSize.height * scale)
    }

    func updatePlayerRelatedViews() {

        if timeline.videoChannel.isEmpty {

            playerView.rendererView.player = nil

            playerView.rendererView.image = .sceneBackground
            playerView.rendererView.contentMode = .scaleAspectFill
            playButton.isHidden = true
            noDataView.isHidden = false
            view.bringSubviewToFront(noDataView)

        } else {

            playerView.rendererView.player = player

            playerView.rendererView.image = nil
            playButton.isHidden = false
            noDataView.isHidden = true
            view.sendSubviewToBack(noDataView)
        }

        playerView.updateNodeViews(nodes: sceneBundle.nodes)
        progressView.updateNodeItemViews(nodes: sceneBundle.nodes, playerItemDurationMilliseconds: playerItem.duration.milliseconds())
    }

    func addPeriodicTimeObserver() {

        let interval: CMTime = CMTimeMake(value: 1, timescale: 100)
        periodicTimeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] currentTime in
            guard let s = self else { return }
            s.currentTime = currentTime
        }
    }

    func removePeriodicTimeObserver() {

        if let timeObserver = periodicTimeObserver {
            player.removeTimeObserver(timeObserver)
            periodicTimeObserver = nil
        }
    }

    func updateViewsWhenTimeElapsed(to time: CMTime) {

        if let duration = player.currentItem?.duration {
            progressView.value = SceneEmulatorProgressView.maximumValue * time.seconds / duration.seconds
        }

        playerView.showOrHideNodeViews(at: time)
    }
}

extension SceneEmulatorViewController {

    func playOrPause() {

        if let player = player {

            if player.timeControlStatus == .playing {

                playButton.isPlaying = false
                player.pause()

                closeButtonContainer.isHidden = false
                progressView.isHidden = false

            } else {

                playButton.isPlaying = true
                player.play()

                closeButtonContainer.isHidden = true
                progressView.isHidden = true
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
            progressView.value = 0
        }
    }

    func pause() {

        playButton.isPlaying = false
        if let player = player {
            player.pause()
        }

        closeButtonContainer.isHidden = true
        progressView.isHidden = true
    }
}
