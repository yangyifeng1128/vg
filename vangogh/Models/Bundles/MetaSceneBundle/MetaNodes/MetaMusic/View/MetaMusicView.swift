///
/// MetaMusicView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class MetaMusicView: MetaNodeView {

    /// 视图布局常量枚举值
    enum VC {
        static let height: CGFloat = 160
    }

    private(set) var music: MetaMusic!
    override var node: MetaNode! {
        get {
            return music
        }
    }

    /// 初始化
    init(music: MetaMusic) {

        super.init()

        self.music = music

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = UIColor.colorWithRGBA(rgba: music.backgroundColorCode)
    }

    override func reloadData() {

        guard let dataSource = dataSource else { return }

        let renderScale: CGFloat = dataSource.renderScale()
        
        // 更新当前视图布局

        // parent.addSubview(self)

        snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(VC.height * renderScale)
            make.left.bottom.equalToSuperview()
        }
    }
}
