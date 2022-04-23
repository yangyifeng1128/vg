///
/// UserInterfaceStyleManager
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Foundation

class UserInterfaceStyle {

    // 用户界面风格类型枚举值

    enum UserInterfaceStyleType: String, CaseIterable {
        case darkMode = "DarkMode"
        case lightMode = "LightMode"
    }

    private(set) var type: UserInterfaceStyleType
    private(set) var title: String

    init(type: UserInterfaceStyleType, title: String) {

        self.type = type
        self.title = title
    }
}

class UserInterfaceStyleManager {

    static var shared = UserInterfaceStyleManager()

    private lazy var settings: [UserInterfaceStyle] = {

        var settings = [UserInterfaceStyle]()
        for type in UserInterfaceStyle.UserInterfaceStyleType.allCases {
            settings.append(UserInterfaceStyle(type: type, title: NSLocalizedString(type.rawValue, comment: "")))
        }
        return settings
    }()

    func get() -> [UserInterfaceStyle] {

        return settings
    }
}
