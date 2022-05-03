///
/// MetaFootage
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

enum MetaFootageType: Int, Codable {
    case image = 0
    case video = 1
}

class MetaFootage: Codable, Equatable {

    var index: Int
    var uuid: String
    var footageType: MetaFootageType
    var leftMarkTimeMilliseconds: Int64
    var durationMilliseconds: Int64
    var maxDurationMilliseconds: Int64

    enum CodingKeys: String, CodingKey {
        case index
        case uuid
        case footageType = "footage_type"
        case leftMarkTimeMilliseconds = "left_mark_time_milliseconds"
        case durationMilliseconds = "duration_milliseconds"
        case maxDurationMilliseconds = "max_duration_milliseconds"
    }

    init(index: Int, uuid: String = UUID().uuidString.lowercased(), footageType: MetaFootageType, leftMarkTimeMilliseconds: Int64 = 0, durationMilliseconds: Int64, maxDurationMilliseconds: Int64) {

        self.index = index
        self.uuid = uuid
        self.footageType = footageType
        self.leftMarkTimeMilliseconds = leftMarkTimeMilliseconds
        self.durationMilliseconds = durationMilliseconds
        self.maxDurationMilliseconds = maxDurationMilliseconds
    }
}

extension MetaFootage: CustomStringConvertible {

    var description: String {
        return "{ index: \(index), uuid: \(uuid), footageType: \(footageType), leftMarkTimeMilliseconds: \(leftMarkTimeMilliseconds), durationMilliseconds: \(durationMilliseconds), maxDurationMilliseconds: \(maxDurationMilliseconds) }"
    }
}

extension MetaFootage: Hashable {

    func hash(into hasher: inout Hasher) {

        hasher.combine(uuid)
    }
}

func == (lhs: MetaFootage, rhs: MetaFootage) -> Bool {

    return lhs.uuid == rhs.uuid
}
