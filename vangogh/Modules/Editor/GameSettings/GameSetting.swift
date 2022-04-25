///
/// GameSetting
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Foundation

class GameSetting {

    /// 作品设置枚举值
    enum GameSettingType: String, CaseIterable {
        case gameThumbImage = "GameThumbImage"
        case gameTitle = "GameTitle"
    }

    private(set) var type: GameSettingType
    private(set) var title: String

    init(type: GameSettingType, title: String) {

        self.type = type
        self.title = title
    }
}

class GameSettingManager {

    static var shared = GameSettingManager()

    private lazy var settings: [GameSetting] = {

        var settings = [GameSetting]()
        for type in GameSetting.GameSettingType.allCases {
            settings.append(GameSetting(type: type, title: NSLocalizedString(type.rawValue, comment: "")))
        }
        return settings
    }()

    func get() -> [GameSetting] {

        return settings
    }
}
