///
/// MetaComment
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaComment: Codable {

    var info: String
    var startTimeMilliseconds: Int64
    var foregroundColorCode: [Decimal]

    enum CodingKeys: String, CodingKey {
        case info
        case startTimeMilliseconds = "start_time_milliseconds"
        case foregroundColorCode = "foreground_color_code"
    }

    init(info: String, startTimeMilliseconds: Int64, foregroundColorCode: [Decimal] = MetaNodeValueConstants.defaultCommentForegroundColorCode) {

        self.info = info
        self.startTimeMilliseconds = startTimeMilliseconds
        self.foregroundColorCode = foregroundColorCode
    }
}

extension MetaComment: CustomStringConvertible {

    var description: String {
        return "\(startTimeMilliseconds)s: \(info)"
    }
}
