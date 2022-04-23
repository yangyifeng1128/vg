///
/// TimelineCursorView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class TimelineCursorView: UIView {

    /// 视图布局常量枚举值
    enum ViewLayoutConstants {
        static let width: CGFloat = TimelineMeasureView.ViewLayoutConstants.markWidth * 2
    }

    init() {

        super.init(frame: .zero)

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {

        isUserInteractionEnabled = false
        backgroundColor = .accent
    }
}
