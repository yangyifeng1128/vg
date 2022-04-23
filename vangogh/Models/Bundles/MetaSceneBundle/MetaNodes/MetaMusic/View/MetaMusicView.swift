///
/// MetaMusicView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class MetaMusicView: MetaNodeView {

    // 视图布局常量枚举值

    enum ViewLayoutConstants {
        static let height: CGFloat = 160
    }

    private(set) var music: MetaMusic!
    override var node: MetaNode! {
        get {
            return music
        }
    }

    init(music: MetaMusic) {

        super.init()

        self.music = music

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {

        backgroundColor = UIColor.colorWithRGBA(rgba: music.backgroundColorCode)
    }

    override func layout(parent: UIView) {

        guard let playerView = playerView, let renderScale = playerView.renderScale else { return }

        // 更新当前视图布局

        parent.addSubview(self)

        snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(ViewLayoutConstants.height * renderScale)
            make.left.bottom.equalToSuperview()
        }
    }
}
