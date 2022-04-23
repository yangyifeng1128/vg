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

        let conditionsTitle: String = ""

        // FIXME：重新处理「MetaCondition」描述信息

//        for (i, condition) in conditions.enumerated() {
//            conditionsTitle.append("\"" + condition.description + "\"")
//            if i < conditions.count - 1 {
//                conditionsTitle.append(" " + NSLocalizedString("Or", comment: "") + " ")
//            }
//        }

        return NSLocalizedString("If", comment: "") + " \(conditionsTitle)" + NSLocalizedString("Then", comment: "") + " \(from) -> \(to)"
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
