///
/// MetaColoring
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaColoring: MetaNode {

    var index: Int
    var uuid: String
    var nodeType: MetaNodeType
    var startTimeMilliseconds: Int64
    var durationMilliseconds: Int64

    var nodeAlignment: MetaNodeAlignment
    var backgroundColorCode: [Decimal]
    var strokeColorCode: [Decimal]

    enum CodingKeys: String, CodingKey {
        case index
        case uuid
        case nodeType = "node_type"
        case startTimeMilliseconds = "start_time_milliseconds"
        case durationMilliseconds = "duration_milliseconds"
        case nodeAlignment = "node_alignment"
        case backgroundColorCode = "background_color_code"
        case strokeColorCode = "stroke_color_code"
    }

    init(index: Int, uuid: String = UUID().uuidString.lowercased(), nodeType: MetaNodeType = .coloring, startTimeMilliseconds: Int64 = 0, durationMilliseconds: Int64 = GVC.defaultNodeItemDurationMilliseconds, nodeAlignment: MetaNodeAlignment = .bottomRight, backgroundColorCode: [Decimal] = MetaNodeValueConstants.defaultNodeBackgroundColorCode, strokeColorCode: [Decimal] = MetaNodeValueConstants.defaultColoringStrokeColorCode) {

        self.index = index
        self.uuid = uuid
        self.nodeType = nodeType
        self.startTimeMilliseconds = startTimeMilliseconds
        self.durationMilliseconds = durationMilliseconds

        self.nodeAlignment = nodeAlignment
        self.backgroundColorCode = backgroundColorCode
        self.strokeColorCode = strokeColorCode
    }
}
