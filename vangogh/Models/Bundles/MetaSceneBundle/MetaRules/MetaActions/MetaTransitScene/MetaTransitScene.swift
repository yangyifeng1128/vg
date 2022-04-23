///
/// MetaTransitScene
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

class MetaTransitScene: MetaAction {

    var sensor: MetaSensor
    var actionType: MetaActionType

    var from: Int
    var to: Int

    enum CodingKeys: String, CodingKey {
        case sensor
        case actionType = "action_type"
        case from
        case to
    }

    init(sensor: MetaSensor, actionType: MetaActionType = .openGame, from: Int, to: Int) {

        self.sensor = sensor
        self.actionType = actionType

        self.from = from
        self.to = to
    }

    func run(facts: [MetaFact]) {
    }
}
