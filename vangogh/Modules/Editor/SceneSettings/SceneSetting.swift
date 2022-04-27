///
/// SceneSetting
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Foundation

class SceneSetting {

    /// 场景设置类型枚举值
    enum SceneSettingType: String, CaseIterable {
        case sceneThumbImage = "SceneThumbImage"
        case sceneTitle = "SceneTitle"
        case aspectRatio = "AspectRatio"
    }

    /// 场景设置类型
    private(set) var type: SceneSettingType
    /// 标题
    private(set) var title: String

    /// 初始化
    init(type: SceneSettingType, title: String) {

        self.type = type
        self.title = title
    }
}

class SceneSettingManager {

    /// 单例
    static var shared = SceneSettingManager()

    /// 设置列表
    private lazy var settings: [SceneSetting] = {

        var settings = [SceneSetting]()
        for type in SceneSetting.SceneSettingType.allCases {
            settings.append(SceneSetting(type: type, title: NSLocalizedString(type.rawValue, comment: "")))
        }
        return settings
    }()

    /// 获取设置列表
    func get() -> [SceneSetting] {

        return settings
    }
}
