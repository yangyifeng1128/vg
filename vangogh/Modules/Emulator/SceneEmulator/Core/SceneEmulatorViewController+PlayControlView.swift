///
/// SceneEmulatorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVKit
import UIKit

extension SceneEmulatorViewController: SceneEmulatorPlayControlViewDataSource {

    func selectedScene() -> MetaScene? {

        return gameBundle.selectedScene()
    }
}

extension SceneEmulatorViewController: SceneEmulatorPlayControlViewDelegate {

    func playButtonDidTap() {

        playOrPause()
    }

    func gameboardButtonDidTap() {

        print("gameboard button did tap")
    }
}

extension SceneEmulatorViewController: SceneEmulatorProgressViewDelegate {

    func progressViewDidBeginSliding() {

        print("[SceneEmulator] did begin sliding progressView")

        if player.timeControlStatus == .playing {

//            playButton.isPlaying = false
            player.pause()
        }
    }

    func progressViewDidEndSliding(to value: Double) {

        print("[SceneEmulator] did end sliding progressView to \(value * 100 / GVC.maxProgressValue)%")

        // 重新定位播放时刻

        if let duration = player.currentItem?.duration {

            let currentTimeMilliseconds: Int64 = Int64((duration.seconds * 1000 * value / GVC.maxProgressValue).rounded())
            player.seek(to: CMTimeMake(value: currentTimeMilliseconds, timescale: GVC.preferredTimescale), toleranceBefore: .zero, toleranceAfter: .zero)
        }
    }
}
