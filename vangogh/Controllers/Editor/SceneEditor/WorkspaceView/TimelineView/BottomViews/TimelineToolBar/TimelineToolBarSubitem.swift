///
/// TimelineToolBarSubitemManager
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class TimelineToolBarSubitem {

    private(set) var nodeType: MetaNodeType
    private(set) var title: String?
    private(set) var icon: UIImage?
    private(set) var backgroundColor: UIColor?

    init(nodeType: MetaNodeType) {

        self.nodeType = nodeType
        self.title = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: nodeType)
        self.icon = MetaNodeTypeManager.shared.getNodeTypeIcon(nodeType: nodeType)
        self.backgroundColor = MetaNodeTypeManager.shared.getNodeTypeBackgroundColor(nodeType: nodeType)
    }
}

class TimelineToolBarSubitemManager {

    static var shared = TimelineToolBarSubitemManager()

    private lazy var items: [TimelineToolBarItem.TimelineToolBarItemType: [TimelineToolBarSubitem]] = {

        var items: [TimelineToolBarItem.TimelineToolBarItemType: [TimelineToolBarSubitem]] = [:]

        items[.audio] = [
            TimelineToolBarSubitem(nodeType: .music),
            TimelineToolBarSubitem(nodeType: .voiceOver)]

        items[.sticker] = [
            TimelineToolBarSubitem(nodeType: .text),
            TimelineToolBarSubitem(nodeType: .animatedImage),
            TimelineToolBarSubitem(nodeType: .button)]

        items[.ask] = [
            TimelineToolBarSubitem(nodeType: .vote),
            TimelineToolBarSubitem(nodeType: .multipleChoice),
            TimelineToolBarSubitem(nodeType: .hotspot)]

        items[.answer] = [
            TimelineToolBarSubitem(nodeType: .checkpoint),
            TimelineToolBarSubitem(nodeType: .bulletScreen)]

        items[.artboard] = [
            TimelineToolBarSubitem(nodeType: .sketch),
            TimelineToolBarSubitem(nodeType: .coloring)]

        items[.camera] = [
            TimelineToolBarSubitem(nodeType: .camera),
            TimelineToolBarSubitem(nodeType: .arCamera)]

        items[.microphone] = [
            TimelineToolBarSubitem(nodeType: .duet)]

        return items
    }()

    func get(toolBarItemType: TimelineToolBarItem.TimelineToolBarItemType) -> [TimelineToolBarSubitem]? {

        return items[toolBarItemType]
    }
}
