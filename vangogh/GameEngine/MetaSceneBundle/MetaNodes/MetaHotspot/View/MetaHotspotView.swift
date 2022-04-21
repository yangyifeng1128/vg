///
/// MetaHotspotView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class MetaHotspotView: MetaNodeView {

    // 视图布局常量枚举值

    enum ViewLayoutConstants {
    }

    private(set) var hotspot: MetaHotspot!
    override var node: MetaNode! {
        get {
            return hotspot
        }
    }

    init(hotspot: MetaHotspot) {

        super.init()

        self.hotspot = hotspot

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {

        backgroundColor = UIColor.colorWithRGBA(rgba: hotspot.backgroundColorCode)
    }

    override func layout(parent: UIView) {

        guard let playerView = playerView, let renderScale = playerView.renderScale else { return }

        // 更新当前视图布局

        parent.addSubview(self)

        snp.makeConstraints { make -> Void in
            make.width.equalTo(hotspot.size.width * renderScale)
            make.height.equalTo(hotspot.size.height * renderScale)
        }
    }
}
