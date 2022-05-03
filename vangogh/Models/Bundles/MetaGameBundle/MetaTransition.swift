///
/// MetaTransition
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaTransition: Codable, Equatable {

    var from: Int
    var to: Int
    var conditions: [MetaCondition]

    enum CodingKeys: String, CodingKey {
        case from
        case to
        case conditions
    }

    init(from: Int, to: Int, conditions: [MetaCondition]) {

        self.from = from
        self.to = to
        self.conditions = conditions
    }
}

extension MetaTransition: CustomStringConvertible {

    var description: String {

        return "\(from) -> \(to)"
    }
}

extension MetaTransition: Hashable {

    func hash(into hasher: inout Hasher) {

        hasher.combine(from)
        hasher.combine(to)
        hasher.combine(conditions)
    }
}

func == (lhs: MetaTransition, rhs: MetaTransition) -> Bool {

    return lhs.from == rhs.from && lhs.to == rhs.to && lhs.conditions == rhs.conditions
}
