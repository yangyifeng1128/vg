///
/// GameSetting
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Foundation

class GameSetting {

    /// 作品设置类型枚举值
    enum GameSettingType: String, CaseIterable {
        case gameThumbImage = "GameThumbImage"
        case gameTitle = "GameTitle"
    }

    /// 作品设置类型
    private(set) var type: GameSettingType
    /// 标题
    private(set) var title: String

    /// 初始化
    init(type: GameSettingType, title: String) {

        self.type = type
        self.title = title
    }
}

class GameSettingManager {

    /// 单例
    static var shared = GameSettingManager()

    /// 设置列表
    private lazy var settings: [GameSetting] = {

        var settings = [GameSetting]()
        for type in GameSetting.GameSettingType.allCases {
            settings.append(GameSetting(type: type, title: NSLocalizedString(type.rawValue, comment: "")))
        }
        return settings
    }()

    /// 获取设置列表
    func get() -> [GameSetting] {

        return settings
    }
}
