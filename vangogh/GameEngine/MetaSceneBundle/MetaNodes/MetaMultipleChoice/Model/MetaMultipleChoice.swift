///
/// MetaMultipleChoice
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaMultipleChoice: MetaNode {

    var index: Int
    var uuid: String
    var nodeType: MetaNodeType
    var startTimeMilliseconds: Int64
    var durationMilliseconds: Int64

    var question: String
    var options: [String]

    var nodeAlignment: MetaNodeAlignment
    var backgroundColorCode: [Decimal]

    enum CodingKeys: String, CodingKey {
        case index
        case uuid
        case nodeType = "node_type"
        case startTimeMilliseconds = "start_time_milliseconds"
        case durationMilliseconds = "duration_milliseconds"
        case question
        case options
        case nodeAlignment = "node_alignment"
        case backgroundColorCode = "background_color_code"
    }

    init(index: Int, uuid: String = UUID().uuidString.lowercased(), nodeType: MetaNodeType = .multipleChoice, startTimeMilliseconds: Int64 = 0, durationMilliseconds: Int64 = GlobalValueConstants.defaultNodeItemDurationMilliseconds, question: String = MetaNodeValueConstants.defaultMultipleChoiceQuestion, options: [String] = MetaNodeValueConstants.defaultMultipleChoiceOptions, nodeAlignment: MetaNodeAlignment = .bottomRight, backgroundColorCode: [Decimal] = MetaNodeValueConstants.defaultNodeBackgroundColorCode) {

        self.index = index
        self.uuid = uuid
        self.nodeType = nodeType
        self.startTimeMilliseconds = startTimeMilliseconds
        self.durationMilliseconds = durationMilliseconds

        self.question = question
        self.options = options

        self.nodeAlignment = nodeAlignment
        self.backgroundColorCode = backgroundColorCode
    }
}
