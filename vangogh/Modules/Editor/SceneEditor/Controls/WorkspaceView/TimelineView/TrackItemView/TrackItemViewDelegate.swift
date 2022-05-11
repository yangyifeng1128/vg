///
/// TrackItemViewDelegate
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

protocol TrackItemViewDelegate: AnyObject {

    func trackItemViewWillBeginExpanding(footage: MetaFootage)
    func trackItemViewDidExpand(expandedWidth: CGFloat, edgeX: CGFloat, withLeftEar: Bool)
    func trackItemViewDidEndExpanding(footage: MetaFootage, cursorTimeOffsetMilliseconds: Int64)
}
