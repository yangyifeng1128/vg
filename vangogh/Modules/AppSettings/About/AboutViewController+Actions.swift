///
/// AboutViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

extension AboutViewController {

    /// 点击「返回按钮」
    @objc func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }
}
