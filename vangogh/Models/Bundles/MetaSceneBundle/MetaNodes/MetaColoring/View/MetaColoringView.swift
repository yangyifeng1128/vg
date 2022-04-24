///
/// MetaColoringView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class MetaColoringView: MetaNodeView {

    /// 视图布局常量枚举值
    enum VC {
        static let height: CGFloat = 196
    }

    private(set) var coloring: MetaColoring!
    override var node: MetaNode! {
        get {
            return coloring
        }
    }

    // 初始化
    init(coloring: MetaColoring) {

        super.init()

        self.coloring = coloring

        // 初始化视图

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = UIColor.colorWithRGBA(rgba: coloring.backgroundColorCode)
    }

    override func layout(parent: UIView) {

        guard let playerView = playerView, let renderScale = playerView.renderScale else { return }

        // 更新当前视图布局

        parent.addSubview(self)

        snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(VC.height * renderScale)
            make.left.bottom.equalToSuperview()
        }
    }
}
