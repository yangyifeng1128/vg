///
/// GameEditorExternalChangeManager
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

class GameEditorExternalChangeManager {

    /// 作品编辑器外部变更类型枚举值
    enum GameEditorExternalChangeType: Int {
        case updateGameTitle = 1
        case updateSceneTitle = 2
        case updateSceneThumbImage = 3
        case addTransition = 4
    }

    /// 单例
    static var shared = GameEditorExternalChangeManager()

    /// 变更字典
    var changeDict: [GameEditorExternalChangeType: Any?] = [:]

    /// 设置变更记录
    func set(key: GameEditorExternalChangeType, value: Any?) {

        changeDict[key] = value
    }

    /// 获取变更字典
    func get() -> [GameEditorExternalChangeType: Any?] {

        return changeDict
    }

    /// 移除全部变更字典
    func removeAll() {

        changeDict.removeAll()
    }
}
