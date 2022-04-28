///
/// GameboardViewExternalChangeManager
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

class GameboardViewExternalChangeManager {

    /// 作品板视图外部变更类型枚举值
    enum GameboardViewExternalChangeType: Int {
        case updateGameTitle = 1
        case updateSceneTitle = 2
        case updateSceneThumbImage = 3
        case addTransition = 4
    }

    /// 单例
    static var shared = GameboardViewExternalChangeManager()

    /// 变更字典
    var changeDict: [GameboardViewExternalChangeType: Any?] = [:]

    /// 设置变更值
    func set(key: GameboardViewExternalChangeType, value: Any?) {

        changeDict[key] = value
    }

    /// 获取变更字典
    func get() -> [GameboardViewExternalChangeType: Any?] {

        return changeDict
    }

    /// 移除全部变更字典
    func removeAll() {

        changeDict.removeAll()
    }
}
