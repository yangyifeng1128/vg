///
/// MetaCameraView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class MetaCameraView: MetaNodeView {

    /// 视图布局常量枚举值
    enum VC {
        static let height: CGFloat = 144
    }

    private(set) var camera: MetaCamera!
    override var node: MetaNode! {
        get {
            return camera
        }
    }

    /// 初始化
    init(camera: MetaCamera) {

        super.init()

        self.camera = camera

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = UIColor.colorWithRGBA(rgba: camera.backgroundColorCode)
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
