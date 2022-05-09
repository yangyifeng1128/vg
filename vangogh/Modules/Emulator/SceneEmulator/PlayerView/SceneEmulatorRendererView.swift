///
/// SceneEmulatorRendererView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVKit
import UIKit

class SceneEmulatorRendererView: RoundedImageView {

    override static var layerClass: AnyClass { AVPlayerLayer.self }

    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }

    private(set) var renderScale: CGFloat!

    init(renderScale: CGFloat) {

        self.renderScale = renderScale
        super.init(cornerRadius: GVC.standardDeviceCornerRadius * renderScale)

        backgroundColor = .black
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }
}
