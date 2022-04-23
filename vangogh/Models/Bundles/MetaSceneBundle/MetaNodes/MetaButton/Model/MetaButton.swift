///
/// MetaButton
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaButton: MetaNode {

    var index: Int
    var uuid: String
    var nodeType: MetaNodeType
    var startTimeMilliseconds: Int64
    var durationMilliseconds: Int64

    var info: String

    var center: CGPoint
    var size: CGSize
    var cornerRadius: CGFloat
    var fontSize: CGFloat
    var backgroundImageName: String
    var highlightedBackgroundImageName: String
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
        case cornerRadius
        case fontSize = "font_size"
        case backgroundImageName = "background_image_name"
        case highlightedBackgroundImageName = "highlighted_background_image_name"
        case backgroundColorCode = "background_color_code"
        case foregroundColorCode = "foreground_color_code"
    }

    init(index: Int, uuid: String = UUID().uuidString.lowercased(), nodeType: MetaNodeType = .button, startTimeMilliseconds: Int64 = 0, durationMilliseconds: Int64 = GVC.defaultNodeItemDurationMilliseconds, info: String = MetaNodeValueConstants.defaultButtonInfo, center: CGPoint = MetaNodeValueConstants.defaultButtonCenter, size: CGSize = MetaNodeValueConstants.defaultButtonSize, cornerRadius: CGFloat = MetaNodeValueConstants.defaultButtonCornerRadius, fontSize: CGFloat = MetaNodeValueConstants.defaultButtonFontSize, backgroundImageName: String, highlightedBackgroundImageName: String, backgroundColorCode: [Decimal] = MetaNodeValueConstants.defaultButtonBackgroundColorCode, foregroundColorCode: [Decimal] = MetaNodeValueConstants.defaultButtonForegroundColorCode) {

        self.index = index
        self.uuid = uuid
        self.nodeType = nodeType
        self.startTimeMilliseconds = startTimeMilliseconds
        self.durationMilliseconds = durationMilliseconds

        self.info = info

        self.center = center
        self.size = size
        self.cornerRadius = cornerRadius
        self.fontSize = fontSize
        self.backgroundImageName = backgroundImageName
        self.highlightedBackgroundImageName = highlightedBackgroundImageName
        self.backgroundColorCode = backgroundColorCode
        self.foregroundColorCode = foregroundColorCode
    }
}
