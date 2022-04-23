///
/// MetaAction
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

protocol MetaAction: Codable {

    var sensor: MetaSensor { get set }
    var actionType: MetaActionType { get set }

    func run(facts: [MetaFact])
}

class AnyMetaAction: Codable {

    var base: MetaAction

    enum CodingKeys: String, CodingKey {
        case actionType = "action_type"
        case base
    }

    init(_ base: MetaAction) {

        self.base = base
    }

    required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MetaActionType.self, forKey: .actionType)
        base = try type.metaType.init(from: decoder)
    }

    func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(base.actionType, forKey: .actionType)
        try base.encode(to: encoder)
    }
}
