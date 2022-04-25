///
/// AppSetting
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Foundation

class AppSetting {

    /// 应用程序设置类型枚举值
    enum AppSettingType: String, CaseIterable {
        case generalSettings = "GeneralSettings"
        case feedback = "Feedback"
        case termsOfService = "TermsOfService"
        case privacyPolicy = "PrivacyPolicy"
        case about = "About"
    }

    /// 应用程序设置类型
    private(set) var type: AppSettingType
    /// 标题
    private(set) var title: String

    /// 初始化
    init(type: AppSettingType, title: String) {

        self.type = type
        self.title = title
    }
}

class AppSettingManager {

    /// 单例
    static var shared = AppSettingManager()

    /// 设置列表
    private lazy var settings: [AppSetting] = {

        var settings = [AppSetting]()
        for type in AppSetting.AppSettingType.allCases {
            settings.append(AppSetting(type: type, title: NSLocalizedString(type.rawValue, comment: "")))
        }
        return settings
    }()

    /// 获取设置列表
    func get() -> [AppSetting] {

        return settings
    }
}
