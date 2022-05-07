///
/// SceneEditorPlayButton
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class SceneEditorPlayButton: UIButton {

    /// 播放图像
    private var playImage: UIImage? = .play
    /// 暂停图像
    private var pauseImage: UIImage? = .pause

    /// 图像边缘内边距
    private var imageEdgeInset: CGFloat!

    /// 播放状态
    var isPlaying: Bool = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let s = self else { return }
                s.setToggled()
            }
        }
    }

    /// 初始化
    init(imageEdgeInset: CGFloat) {

        super.init(frame: .zero)

        self.imageEdgeInset = imageEdgeInset

        setToggled()

        tintColor = .mgLabel
        adjustsImageWhenHighlighted = false
        imageView?.tintColor = .mgLabel
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 重写背景矩形区域
    override func backgroundRect(forBounds bounds: CGRect) -> CGRect {

        return CGRect(x: imageEdgeInset, y: imageEdgeInset, width: bounds.width - imageEdgeInset * 2, height: bounds.height - imageEdgeInset * 2)
    }
}

extension SceneEditorPlayButton {

    /// 设置切换状态
    private func setToggled() {

        if isPlaying {
            setBackgroundImage(pauseImage, for: .normal)
        } else {
            setBackgroundImage(playImage, for: .normal)
        }
    }
}
