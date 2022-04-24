///
/// UserInterfaceStyleManager
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Foundation

class UserInterfaceStyle {

    /// 用户界面风格类型枚举值
    enum UserInterfaceStyleType: String, CaseIterable {
        case darkMode = "DarkMode"
        case lightMode = "LightMode"
    }

    /// 用户界面风格类型
    private(set) var type: UserInterfaceStyleType
    /// 标题
    private(set) var title: String

    /// 初始化
    init(type: UserInterfaceStyleType, title: String) {

        self.type = type
        self.title = title
    }
}

class UserInterfaceStyleManager {

    /// 单例
    static var shared = UserInterfaceStyleManager()

    /// 风格列表
    private lazy var styles: [UserInterfaceStyle] = {

        var styles = [UserInterfaceStyle]()
        for type in UserInterfaceStyle.UserInterfaceStyleType.allCases {
            styles.append(UserInterfaceStyle(type: type, title: NSLocalizedString(type.rawValue, comment: "")))
        }
        return styles
    }()

    /// 获取风格列表
    func get() -> [UserInterfaceStyle] {

        return styles
    }
}
