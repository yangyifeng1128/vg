///
/// SceneSetting
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Foundation

class SceneSetting {

    // 场景设置类型枚举值

    enum SceneSettingType: String, CaseIterable {
        case sceneThumbImage = "SceneThumbImage"
        case sceneTitle = "SceneTitle"
        case aspectRatio = "AspectRatio"
    }

    private(set) var type: SceneSettingType
    private(set) var title: String

    init(type: SceneSettingType, title: String) {

        self.type = type
        self.title = title
    }
}

class SceneSettingManager {

    static var shared = SceneSettingManager()

    private lazy var settings: [SceneSetting] = {

        var settings = [SceneSetting]()
        for type in SceneSetting.SceneSettingType.allCases {
            settings.append(SceneSetting(type: type, title: NSLocalizedString(type.rawValue, comment: "")))
        }
        return settings
    }()

    func get() -> [SceneSetting] {

        return settings
    }
}
