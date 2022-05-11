///
/// MetaHotspotView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class MetaHotspotView: MetaNodeView {

    /// 视图布局常量枚举值
    enum VC {
    }

    private(set) var hotspot: MetaHotspot!
    override var node: MetaNode! {
        get {
            return hotspot
        }
    }

    /// 初始化
    init(hotspot: MetaHotspot) {

        super.init()

        self.hotspot = hotspot

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = UIColor.colorWithRGBA(rgba: hotspot.backgroundColorCode)
    }

    override func reloadData() {

        guard let dataSource = dataSource else { return }

        let renderScale: CGFloat = dataSource.renderScale()

        // 更新当前视图布局

        // parent.addSubview(self)

        snp.makeConstraints { make -> Void in
            make.width.equalTo(hotspot.size.width * renderScale)
            make.height.equalTo(hotspot.size.height * renderScale)
        }
    }
}
