///
/// SceneEmulatorPlayControlView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension SceneEmulatorPlayControlView {

    @objc func playButtonDidTap() {

        delegate?.playButtonDidTap()
    }

    @objc func gameboardButtonDidTap() {

        delegate?.gameboardButtonDidTap()
    }
}

extension SceneEmulatorPlayControlView {

    /// 重新加载数据
    func reloadData() {

        updateGameboardButtonInfoLabel()
    }

    /// 更新「作品板按钮信息标签」
    func updateGameboardButtonInfoLabel() {

        gameboardButton.infoLabel.attributedText = prepareGameboardButtonInfoLabelAttributedText()
        gameboardButton.infoLabel.numberOfLines = 1
        gameboardButton.infoLabel.lineBreakMode = .byTruncatingTail
    }

    /// 准备「场景标题标签」文本
    func prepareGameboardButtonInfoLabelAttributedText() -> NSMutableAttributedString {

        let completeTitleString: NSMutableAttributedString = NSMutableAttributedString(string: "")

        guard let dataSource = dataSource, let scene = dataSource.selectedScene() else { return completeTitleString }

        // 准备场景标题

        var gameTitleString: NSAttributedString
        let gameTitleStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.mgLabel!]
        gameTitleString = NSAttributedString(string: "草稿 2", attributes: gameTitleStringAttributes)
        completeTitleString.append(gameTitleString)

        // 准备场景标题

        var sceneTitleString: NSAttributedString
        if let sceneTitle = scene.title, !sceneTitle.isEmpty {

            let colonStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.secondaryLabel]
            let colonString: NSAttributedString = NSAttributedString(string: NSLocalizedString("Colon", comment: ""), attributes: colonStringAttributes)
            completeTitleString.append(colonString)

            let sceneTitleStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.mgLabel!]
            sceneTitleString = NSAttributedString(string: sceneTitle, attributes: sceneTitleStringAttributes)
            completeTitleString.append(sceneTitleString)
        }

        // 准备段落样式

        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        completeTitleString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, completeTitleString.length))

        return completeTitleString
    }
}

extension SceneEmulatorPlayControlView {

    /// 播放
    func play() {

        playButton.isPlaying = true
        gameboardButton.isHidden = true
        progressView.isHidden = true
    }

    /// 暂停
    func pause() {

        playButton.isPlaying = false
        gameboardButton.isHidden = false
        progressView.isHidden = false
    }

    /// 更新进度
    func seek(to progress: CGFloat) {

        progressView.progress = progress
        circleProgressView.progress = progress
    }
}
