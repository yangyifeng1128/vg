///
/// MetaRule
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaRule: Codable, Equatable {

    var uuid: String
    var conditions: [MetaCondition]
    var actions: [MetaAction]

    enum CodingKeys: String, CodingKey {
        case uuid
        case conditions
        case actions
    }

    init(uuid: String, conditions: [MetaCondition], actions: [MetaAction]) {

        self.uuid = uuid
        self.conditions = conditions
        self.actions = actions
    }

    required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try container.decode(String.self, forKey: .uuid)
        conditions = try container.decode([MetaCondition].self, forKey: .conditions)
        actions = try container.decode([AnyMetaAction].self, forKey: .actions).map { $0.base }
    }

    func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(conditions, forKey: .conditions)
        try container.encode(actions.map(AnyMetaAction.init), forKey: .actions)
    }

    func evaluate(facts: [MetaFact]) -> Bool {

        return true
    }

    func run(facts: [MetaFact]) {

        for action in actions {

            action.run(facts: facts)
        }
    }
}

extension MetaRule: CustomStringConvertible {

    var description: String {
        return "{ uuid: \(uuid), conditions: \(conditions), actions: \(actions) }"
    }
}

extension MetaRule: Hashable {

    func hash(into hasher: inout Hasher) {

        hasher.combine(uuid)
    }
}

func == (lhs: MetaRule, rhs: MetaRule) -> Bool {

    return lhs.uuid == rhs.uuid
}
