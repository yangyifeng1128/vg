///
/// MetaAnimatedImage
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaAnimatedImage: MetaNode {

    var index: Int
    var uuid: String
    var nodeType: MetaNodeType
    var startTimeMilliseconds: Int64
    var durationMilliseconds: Int64

    var center: CGPoint
    var size: CGSize
    var backgroundColorCode: [Decimal]

    enum CodingKeys: String, CodingKey {
        case index
        case uuid
        case nodeType = "node_type"
        case startTimeMilliseconds = "start_time_milliseconds"
        case durationMilliseconds = "duration_milliseconds"
        case center
        case size
        case backgroundColorCode = "background_color_code"
    }

    init(index: Int, uuid: String = UUID().uuidString.lowercased(), nodeType: MetaNodeType = .animatedImage, startTimeMilliseconds: Int64 = 0, durationMilliseconds: Int64 = GlobalValueConstants.defaultNodeItemDurationMilliseconds, center: CGPoint = MetaNodeValueConstants.defaultAnimatedImageCenter, size: CGSize = MetaNodeValueConstants.defaultAnimatedImageSize, backgroundColorCode: [Decimal] = MetaNodeValueConstants.defaultAnimatedImageBackgroundColorCode) {

        self.index = index
        self.uuid = uuid
        self.nodeType = nodeType
        self.startTimeMilliseconds = startTimeMilliseconds
        self.durationMilliseconds = durationMilliseconds

        self.center = center
        self.size = size
        self.backgroundColorCode = backgroundColorCode
    }
}
