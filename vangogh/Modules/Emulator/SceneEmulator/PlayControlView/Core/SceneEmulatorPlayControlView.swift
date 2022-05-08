///
/// SceneEmulatorPlayControlView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class SceneEmulatorPlayControlView: UIView {

    /// 视图布局常量枚举值
    enum VC {
        static let height: CGFloat = 176
        static let paddingX: CGFloat = 12
        static let playButtonWidth: CGFloat = 42
        static let playButtonImageEdgeInset: CGFloat = 9.2
        static let gameboardButtonHeight: CGFloat = 46
    }

    /// 数据源
    weak var dataSource: SceneEmulatorPlayControlViewDataSource? {
        didSet { reloadData() }
    }
    /// 代理
    weak var delegate: SceneEmulatorPlayControlViewDelegate?

    /// 进度视图
    var progressView: SceneEmulatorProgressView!
    /// 环形进度视图
    var circleProgressView: SceneEmulatorCircleProgressView!
    /// 播放按钮
    var playButton: SceneEmulatorPlayButton!
    /// 作品板按钮
    var gameboardButton: SceneEmulatorGameboardButton!

    /// 初始化
    init() {

        super.init(frame: .zero)

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        // 初始化「进度视图」

        progressView = SceneEmulatorProgressView()
        progressView.isHidden = true
        addSubview(progressView)
        progressView.snp.makeConstraints { make -> Void in
            make.height.equalTo(SceneEmulatorProgressView.VC.height)
            make.left.right.equalToSuperview().inset(VC.paddingX)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-80)
        }

        // 初始化「环形进度视图」

        circleProgressView = SceneEmulatorCircleProgressView()
        addSubview(circleProgressView)
        circleProgressView.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.playButtonWidth + SceneEmulatorCircleProgressView.VC.trackLayerLineWidth * 2)
            make.left.equalToSuperview().offset(VC.paddingX)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化「播放按钮」

        playButton = SceneEmulatorPlayButton(imageEdgeInset: VC.playButtonImageEdgeInset)
        playButton.addTarget(self, action: #selector(playButtonDidTap), for: .touchUpInside)
        circleProgressView.addSubview(playButton)
        playButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.playButtonWidth)
            make.center.equalToSuperview()
        }

        // 初始化「作品板按钮」

        gameboardButton = SceneEmulatorGameboardButton(cornerRadius: VC.gameboardButtonHeight / 2)
        gameboardButton.isHidden = true
        gameboardButton.infoLabel.attributedText = prepareGameboardButtonInfoLabelAttributedText()
        gameboardButton.infoLabel.numberOfLines = 1
        gameboardButton.infoLabel.lineBreakMode = .byTruncatingTail
        gameboardButton.addTarget(self, action: #selector(gameboardButtonDidTap), for: .touchUpInside)
        addSubview(gameboardButton)
        gameboardButton.snp.makeConstraints { make -> Void in
            make.height.equalTo(VC.gameboardButtonHeight)
            make.centerY.equalTo(circleProgressView)
            make.left.equalTo(playButton.snp.right).offset(VC.paddingX)
            make.right.equalToSuperview().offset(-VC.paddingX)
        }
    }
}
