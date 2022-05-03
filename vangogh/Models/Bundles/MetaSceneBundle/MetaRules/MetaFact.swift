///
/// MetaFact
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaFact: Codable, Equatable {

    var sensor: MetaSensor
    var value: String

    enum CodingKeys: String, CodingKey {
        case sensor
        case value
    }

    init(sensor: MetaSensor, value: String) {

        self.sensor = sensor
        self.value = value
    }
}

extension MetaFact: Hashable {

    func hash(into hasher: inout Hasher) {

        hasher.combine(sensor)
        hasher.combine(value)
    }
}

func == (lhs: MetaFact, rhs: MetaFact) -> Bool {

    return lhs.sensor == rhs.sensor && lhs.value == rhs.value
}
