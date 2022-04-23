///
/// AppSettingManager
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Foundation

class AppSetting {

    /// 应用设置类型枚举值
    enum AppSettingType: String, CaseIterable {
        case generalSettings = "GeneralSettings"
        case feedback = "Feedback"
        case termsOfService = "TermsOfService"
        case privacyPolicy = "PrivacyPolicy"
        case about = "About"
    }

    private(set) var type: AppSettingType
    private(set) var title: String

    init(type: AppSettingType, title: String) {

        self.type = type
        self.title = title
    }
}

class AppSettingManager {

    static var shared = AppSettingManager()

    private lazy var settings: [AppSetting] = {

        var settings = [AppSetting]()
        for type in AppSetting.AppSettingType.allCases {
            settings.append(AppSetting(type: type, title: NSLocalizedString(type.rawValue, comment: "")))
        }
        return settings
    }()

    func get() -> [AppSetting] {

        return settings
    }
}
