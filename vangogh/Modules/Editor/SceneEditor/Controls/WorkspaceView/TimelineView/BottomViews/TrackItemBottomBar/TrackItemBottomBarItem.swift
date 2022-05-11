///
/// TrackItemBottomBarItem
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Foundation
import UIKit

class TrackItemBottomBarItem {

    // 轨道项底部栏项目类型枚举值

    enum TrackItemBottomBarItemType: String, CaseIterable {
        case delete = "Delete"
    }

    private(set) var type: TrackItemBottomBarItemType
    private(set) var title: String
    private(set) var icon: UIImage?
    private(set) var tintColor: UIColor?

    init(type: TrackItemBottomBarItemType, title: String, icon: UIImage? = .rectangle, tintColor: UIColor? = .mgLabel) {

        self.type = type
        self.title = title
        self.icon = icon
        self.tintColor = tintColor
    }
}

class TrackItemBottomBarItemManager {

    static var shared = TrackItemBottomBarItemManager()

    private lazy var items: [TrackItemBottomBarItem] = {

        var items = [TrackItemBottomBarItem]()
        items.append(TrackItemBottomBarItem(type: .delete, title: NSLocalizedString(TrackItemBottomBarItem.TrackItemBottomBarItemType.delete.rawValue, comment: ""), icon: .delete))

        return items
    }()

    func get() -> [TrackItemBottomBarItem] {

        return items
    }
}
