///
/// MetaOpenGame
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

class MetaOpenGame: MetaAction {

    var sensor: MetaSensor
    var actionType: MetaActionType

    var gameUUID: String

    enum CodingKeys: String, CodingKey {
        case sensor
        case actionType = "action_type"
        case gameUUID = "game_uuid"
    }

    init(sensor: MetaSensor, actionType: MetaActionType = .openGame, gameUUID: String) {

        self.sensor = sensor
        self.actionType = actionType

        self.gameUUID = gameUUID
    }

    func run(facts: [MetaFact]) {
    }
}
