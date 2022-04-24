///
/// TimelineCursorView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class TimelineCursorView: UIView {

    /// 视图布局常量枚举值
    enum VC {
        static let width: CGFloat = TimelineMeasureView.VC.markWidth * 2
    }

    init() {

        super.init(frame: .zero)

        // 初始化视图

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {

        isUserInteractionEnabled = false
        backgroundColor = .accent
    }
}
