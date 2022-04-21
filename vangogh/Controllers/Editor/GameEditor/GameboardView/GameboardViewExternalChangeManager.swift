///
/// GameboardViewExternalChangeManager
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

class GameboardViewExternalChangeManager {

    // 作品板视图外部变更类型枚举值

    enum GameboardViewExternalChangeType: Int {
        case updateGameTitle = 1
        case updateSceneTitle = 2
        case updateSceneThumbImage = 3
        case addTransition = 4
    }

    static var shared = GameboardViewExternalChangeManager()

    var changeDict: [GameboardViewExternalChangeType: Any?] = [:]

    func set(key: GameboardViewExternalChangeType, value: Any?) {

        changeDict[key] = value
    }

    func get() -> [GameboardViewExternalChangeType: Any?] {

        return changeDict
    }

    func removeAll() {

        changeDict.removeAll()
    }
}
