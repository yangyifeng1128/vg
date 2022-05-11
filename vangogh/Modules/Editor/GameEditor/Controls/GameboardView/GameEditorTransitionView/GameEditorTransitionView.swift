///
/// GameEditorTransitionView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class GameEditorTransitionView: UIView {

    /// 视图布局常量枚举值
    enum VC {
        static let tailWidth: CGFloat = 2
        static let headWidth: CGFloat = 10
        static let headLength: CGFloat = 8
        static let pulseWidth: CGFloat = 3
    }

    /// 脉冲动画图层
    var pulseAnimationLayer: CALayer!
    /// 脉冲动画组
    var pulseAnimationGroup: CAAnimationGroup!
    /// 脉冲动画时长
    var pulseAnimationDuration: TimeInterval = 1.2

    /// 箭头图层颜色
    var arrowLayerColor: CGColor!
    /// 开始场景
    var startScene: MetaScene!
    /// 结束场景
    var endScene: MetaScene!

    /// 初始化
    init(startScene: MetaScene, endScene: MetaScene) {

        super.init(frame: .zero)

        self.startScene = startScene
        self.endScene = endScene

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = .clear

        arrowLayerColor = UIColor.tertiaryLabel.cgColor
        updateView()
    }
}
