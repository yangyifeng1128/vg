///
/// MetaCheckpointView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class MetaCheckpointView: MetaNodeView {

    // 视图布局常量枚举值

    enum ViewLayoutConstants {
        static let height: CGFloat = 128
    }

    private(set) var checkpoint: MetaCheckpoint!
    override var node: MetaNode! {
        get {
            return checkpoint
        }
    }

    init(checkpoint: MetaCheckpoint) {

        super.init()

        self.checkpoint = checkpoint

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {

        backgroundColor = UIColor.colorWithRGBA(rgba: checkpoint.backgroundColorCode)
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
