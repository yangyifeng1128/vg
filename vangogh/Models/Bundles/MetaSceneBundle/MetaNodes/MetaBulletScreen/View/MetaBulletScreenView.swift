///
/// MetaBulletScreenView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import DanmakuKit
import SnapKit
import UIKit

class MetaBulletScreenView: MetaNodeView {

    /// 视图布局常量枚举值
    enum VC {
    }

    private(set) var bulletScreen: MetaBulletScreen!
    override var node: MetaNode! {
        get {
            return bulletScreen
        }
    }

    private var rendererView: DanmakuView!

    /// 初始化
    init(bulletScreen: MetaBulletScreen) {

        super.init()

        self.bulletScreen = bulletScreen

        // 初始化视图

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = UIColor.colorWithRGBA(rgba: bulletScreen.backgroundColorCode)

        rendererView = DanmakuView()
        addSubview(rendererView)
    }

    override func layout(parent: UIView) {

        // 更新渲染器视图布局

        rendererView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }
        bulletScreen.comments.forEach {
            rendererView.shoot(danmaku: MetaBulletScreenCellModel(comment: $0))
        }
        rendererView.play()

        // 更新当前视图布局

        parent.addSubview(self)

        snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }
    }
}
