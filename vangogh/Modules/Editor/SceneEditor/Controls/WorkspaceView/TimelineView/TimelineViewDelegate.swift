///
/// TimelineViewDelegate
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVFoundation

protocol TimelineViewDelegate: AnyObject {

    func timelineViewDidTap()
    func timelineViewWillBeginScrolling()
    func timelineViewDidEndScrolling(to time: CMTime, decelerate: Bool)

    func trackItemViewDidBecomeActive(footage: MetaFootage)
    func trackItemViewWillBeginExpanding(footage: MetaFootage)
    func trackItemViewDidEndExpanding(footage: MetaFootage, cursorTimeOffsetMilliseconds: Int64)

    func nodeItemViewDidBecomeActive(node: MetaNode)
    func nodeItemViewDidResignActive(node: MetaNode)
    func nodeItemViewWillBeginExpanding(node: MetaNode)
    func nodeItemViewDidEndExpanding(node: MetaNode)
    func nodeItemViewWillBeginEditing(node: MetaNode)

    func newFootageButtonDidTap()
}
