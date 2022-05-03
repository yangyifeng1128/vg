///
/// MetaCondition
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaCondition: Codable, Equatable {

    var sensor: MetaSensor
    var operatorKey: MetaOperatorKey
    var value: String

    enum CodingKeys: String, CodingKey {
        case sensor
        case operatorKey = "operator_key"
        case value
    }

    init(sensor: MetaSensor, operatorKey: MetaOperatorKey, value: String) {

        self.sensor = sensor
        self.operatorKey = operatorKey
        self.value = value
    }
}

extension MetaCondition: Hashable {

    func hash(into hasher: inout Hasher) {

        hasher.combine(sensor)
        hasher.combine(operatorKey)
        hasher.combine(value)
    }
}

func == (lhs: MetaCondition, rhs: MetaCondition) -> Bool {

    return lhs.sensor == rhs.sensor && lhs.operatorKey == rhs.operatorKey && lhs.value == rhs.value
}
