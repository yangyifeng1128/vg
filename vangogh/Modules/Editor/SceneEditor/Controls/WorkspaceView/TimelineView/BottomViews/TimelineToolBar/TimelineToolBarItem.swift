///
/// TimelineToolBarItem
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class TimelineToolBarItem {

    // 时间线工具栏项目类型枚举值

    enum TimelineToolBarItemType: String, CaseIterable {
        case audio = "Audio"
        case sticker = "Sticker"
        case ask = "Ask"
        case answer = "Answer"
        case artboard = "Artboard"
        case camera = "Camera"
        case microphone = "Microphone"
    }

    private(set) var type: TimelineToolBarItemType
    private(set) var title: String
    private(set) var icon: UIImage?
    private(set) var iconTintColor: UIColor?

    init(type: TimelineToolBarItemType, title: String, icon: UIImage? = .rectangle, iconTintColor: UIColor? = .mgLabel) {

        self.type = type
        self.title = title
        self.icon = icon
        self.iconTintColor = iconTintColor
    }
}

class TimelineToolBarItemManager {

    static var shared = TimelineToolBarItemManager()

    private lazy var items: [TimelineToolBarItem] = {

        var items = [TimelineToolBarItem]()
        items.append(TimelineToolBarItem(type: .audio, title: NSLocalizedString(TimelineToolBarItem.TimelineToolBarItemType.audio.rawValue, comment: ""), icon: .audioPlus, iconTintColor: .fcRed))
        items.append(TimelineToolBarItem(type: .sticker, title: NSLocalizedString(TimelineToolBarItem.TimelineToolBarItemType.sticker.rawValue, comment: ""), icon: .stickerPlus, iconTintColor: .fcYellow))
        items.append(TimelineToolBarItem(type: .ask, title: NSLocalizedString(TimelineToolBarItem.TimelineToolBarItemType.ask.rawValue, comment: ""), icon: .askPlus, iconTintColor: .fcGreen))
        items.append(TimelineToolBarItem(type: .answer, title: NSLocalizedString(TimelineToolBarItem.TimelineToolBarItemType.answer.rawValue, comment: ""), icon: .answerPlus, iconTintColor: .fcBlue))
        items.append(TimelineToolBarItem(type: .artboard, title: NSLocalizedString(TimelineToolBarItem.TimelineToolBarItemType.artboard.rawValue, comment: ""), icon: .artboardPlus, iconTintColor: .fcIndigo))
        items.append(TimelineToolBarItem(type: .camera, title: NSLocalizedString(TimelineToolBarItem.TimelineToolBarItemType.camera.rawValue, comment: ""), icon: .cameraPlus, iconTintColor: .fcPurple))
        items.append(TimelineToolBarItem(type: .microphone, title: NSLocalizedString(TimelineToolBarItem.TimelineToolBarItemType.microphone.rawValue, comment: ""), icon: .microphonePlus, iconTintColor: .fcBrown))

        return items
    }()

    func get() -> [TimelineToolBarItem] {

        return items
    }
}
