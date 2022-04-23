///
/// NodeItemBottomBarItemManager
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Foundation
import UIKit

class NodeItemBottomBarItem {

    // 组件项底部栏项目类型枚举值

    enum NodeItemBottomBarItemType: String, CaseIterable {
        case edit = "EditNode"
        case delete = "Delete"
    }

    private(set) var type: NodeItemBottomBarItemType
    private(set) var title: String
    private(set) var icon: UIImage?
    private(set) var tintColor: UIColor?

    init(type: NodeItemBottomBarItemType, title: String, icon: UIImage? = .rectangle, tintColor: UIColor? = .mgLabel) {

        self.type = type
        self.title = title
        self.icon = icon
        self.tintColor = tintColor
    }
}

class NodeItemBottomBarItemManager {

    static var shared = NodeItemBottomBarItemManager()

    private lazy var items: [NodeItemBottomBarItem] = {

        var items = [NodeItemBottomBarItem]()
        items.append(NodeItemBottomBarItem(type: .edit, title: NSLocalizedString(NodeItemBottomBarItem.NodeItemBottomBarItemType.edit.rawValue, comment: ""), icon: .editInfo))
        items.append(NodeItemBottomBarItem(type: .delete, title: NSLocalizedString(NodeItemBottomBarItem.NodeItemBottomBarItemType.delete.rawValue, comment: ""), icon: .delete, tintColor: .secondaryLabel))

        return items
    }()

    func get() -> [NodeItemBottomBarItem] {

        return items
    }
}
