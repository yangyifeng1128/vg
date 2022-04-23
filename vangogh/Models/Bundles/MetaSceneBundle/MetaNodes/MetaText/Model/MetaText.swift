///
/// MetaText
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaText: MetaNode {

    var index: Int
    var uuid: String
    var nodeType: MetaNodeType
    var startTimeMilliseconds: Int64
    var durationMilliseconds: Int64

    var info: String

    var center: CGPoint
    var size: CGSize
    var fontSize: CGFloat
    var backgroundColorCode: [Decimal]
    var foregroundColorCode: [Decimal]

    enum CodingKeys: String, CodingKey {
        case index
        case uuid
        case nodeType = "node_type"
        case startTimeMilliseconds = "start_time_milliseconds"
        case durationMilliseconds = "duration_milliseconds"
        case info
        case center
        case size
        case fontSize = "font_size"
        case backgroundColorCode = "background_color_code"
        case foregroundColorCode = "foreground_color_code"
    }

    init(index: Int, uuid: String = UUID().uuidString.lowercased(), nodeType: MetaNodeType = .text, startTimeMilliseconds: Int64 = 0, durationMilliseconds: Int64 = GlobalValueConstants.defaultNodeItemDurationMilliseconds, info: String = MetaNodeValueConstants.defaultTextInfo, center: CGPoint = MetaNodeValueConstants.defaultTextCenter, size: CGSize = MetaNodeValueConstants.defaultTextSize, fontSize: CGFloat = MetaNodeValueConstants.defaultTextFontSize, backgroundColorCode: [Decimal] = MetaNodeValueConstants.defaultNodeBackgroundColorCode, foregroundColorCode: [Decimal] = MetaNodeValueConstants.defaultTextForegroundColorCode) {

        self.index = index
        self.uuid = uuid
        self.nodeType = nodeType
        self.startTimeMilliseconds = startTimeMilliseconds
        self.durationMilliseconds = durationMilliseconds

        self.info = info

        self.center = center
        self.size = size
        self.fontSize = fontSize
        self.backgroundColorCode = backgroundColorCode
        self.foregroundColorCode = foregroundColorCode
    }
}
