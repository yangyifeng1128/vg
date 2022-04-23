///
/// TransparentCoachMarkBodyView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Instructions
import UIKit

class TransparentCoachMarkArrowView: UIImageView, CoachMarkArrowView {

    /// 初始化
    init(orientation: CoachMarkArrowOrientation) {

        if orientation == .top {
            super.init(image: .sketchArrowUp)
        } else {
            super.init(image: .sketchArrowDown)
        }

        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: self.image?.size.width ?? 0).isActive = true
        heightAnchor.constraint(equalToConstant: self.image?.size.width ?? 0).isActive = true
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }
}
