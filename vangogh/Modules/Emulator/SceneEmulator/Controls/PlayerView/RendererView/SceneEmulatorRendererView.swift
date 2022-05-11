///
/// SceneEmulatorRendererView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVKit
import UIKit

class SceneEmulatorRendererView: RoundedImageView {

    /// 图层类
    override static var layerClass: AnyClass { AVPlayerLayer.self }

    /// 播放器图层
    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    /// 播放器
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }

    /// 渲染缩放比例
    var renderScale: CGFloat!

    /// 初始化
    init(renderScale: CGFloat) {

        super.init(cornerRadius: GVC.standardDeviceCornerRadius * renderScale)

        self.renderScale = renderScale

        backgroundColor = .black
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }
}
