///
/// GeneralSettingManager
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Foundation

class GeneralSetting {

    /// 通用设置类型枚举值
    enum GeneralSettingType: String, CaseIterable {
        case darkMode = "DarkMode"
    }

    /// 通用设置类型
    private(set) var type: GeneralSettingType
    /// 标题
    private(set) var title: String

    /// 初始化
    init(type: GeneralSettingType, title: String) {

        self.type = type
        self.title = title
    }
}

class GeneralSettingManager {

    /// 单例
    static var shared = GeneralSettingManager()

    /// 设置列表
    private lazy var settings: [GeneralSetting] = {

        var settings = [GeneralSetting]()
        for type in GeneralSetting.GeneralSettingType.allCases {
            settings.append(GeneralSetting(type: type, title: NSLocalizedString(type.rawValue, comment: "")))
        }
        return settings
    }()

    /// 获取设置列表
    func get() -> [GeneralSetting] {

        return settings
    }
}
