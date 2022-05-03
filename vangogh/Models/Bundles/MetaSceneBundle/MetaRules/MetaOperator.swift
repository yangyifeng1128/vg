///
/// MetaOperator
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaOperator: Equatable {

    var key: MetaOperatorKey
    var callback: (String, String) -> Bool

    enum CodingKeys: String, CodingKey {
        case key
        case callback
    }

    init(key: MetaOperatorKey, callback: @escaping (String, String) -> Bool) {

        self.key = key
        self.callback = callback
    }

    func evaluate(factValue: String, conditionValue: String) -> Bool {

        return callback(factValue, conditionValue)
    }
}

extension MetaOperator: Hashable {

    func hash(into hasher: inout Hasher) {

        hasher.combine(key)
    }
}

func == (lhs: MetaOperator, rhs: MetaOperator) -> Bool {

    return lhs.key == rhs.key
}
