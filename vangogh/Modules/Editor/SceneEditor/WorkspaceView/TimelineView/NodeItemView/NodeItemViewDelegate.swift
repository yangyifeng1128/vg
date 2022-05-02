///
/// NodeItemViewDelegate
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

protocol NodeItemViewDelegate: AnyObject {

    func nodeItemViewWillBeginExpanding(node: MetaNode)
    func nodeItemViewDidExpand(node: MetaNode, expandedWidth: CGFloat, edgeX: CGFloat, withLeftEar: Bool)
    func nodeItemViewDidEndExpanding(node: MetaNode)
}
