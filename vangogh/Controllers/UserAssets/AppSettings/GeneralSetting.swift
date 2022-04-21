///
/// GeneralSettingManager
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Foundation

class GeneralSetting {

    // 通用设置类型枚举值

    enum GeneralSettingType: String, CaseIterable {
        case darkMode = "DarkMode"
    }

    private(set) var type: GeneralSettingType
    private(set) var title: String

    init(type: GeneralSettingType, title: String) {

        self.type = type
        self.title = title
    }
}

class GeneralSettingManager {

    static var shared = GeneralSettingManager()

    private lazy var settings: [GeneralSetting] = {

        var settings = [GeneralSetting]()
        for type in GeneralSetting.GeneralSettingType.allCases {
            settings.append(GeneralSetting(type: type, title: NSLocalizedString(type.rawValue, comment: "")))
        }
        return settings
    }()

    func get() -> [GeneralSetting] {

        return settings
    }
}
