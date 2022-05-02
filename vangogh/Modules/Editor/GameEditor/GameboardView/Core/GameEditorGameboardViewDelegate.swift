///
/// GameEditorGameboardViewDelegate
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

protocol GameEditorGameboardViewDelegate: UIScrollViewDelegate {

    func gameboardViewDidTap(location: CGPoint)
    func gameboardViewDidLongPress(location: CGPoint)
}
