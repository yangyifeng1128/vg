///
/// MetaNodeConstants
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

enum MetaNodeKeyConstants {
}

enum MetaNodeValueConstants {

    static let defaultNodeBackgroundColorCode: [Decimal] = [0, 0, 0, 0.1]

    static let defaultAnimatedImageCenter: CGPoint = CGPoint(x: defaultAnimatedImageSize.width / 2, y: defaultAnimatedImageSize.height / 2)
    static let defaultAnimatedImageSize: CGSize = CGSize(width: 100, height: 100)
    static let defaultAnimatedImageBackgroundColorCode: [Decimal] = [0, 0, 0, 0.4]

    static let defaultButtonInfo: String = "确定"
    static let defaultButtonCenter: CGPoint = CGPoint(x: defaultButtonSize.width / 2, y: defaultButtonSize.height / 2)
    static let defaultButtonSize: CGSize = CGSize(width: 104, height: 56)
    static let defaultButtonCornerRadius: CGFloat = 16
    static let defaultButtonFontSize: CGFloat = 18
    static let defaultButtonBackgroundColorCode: [Decimal] = [255, 255, 255, 1]
    static let defaultButtonForegroundColorCode: [Decimal] = [0, 0, 0, 1]

    static let defaultColoringStrokeColorCode: [Decimal] = [255, 0, 0, 1]

    static let defaultBulletScreenBackgroundColorCode: [Decimal] = [0, 0, 0, 0.2]
    static let defaultCommentDurationTimeMilliseconds: Int64 = 9000
    static let defaultCommentFontSize: CGFloat = 18
    static let defaultCommentForegroundColorCode: [Decimal] = [0, 0, 0, 1]
    static let defaultCommentHeight: CGFloat = 32

    static let defaultDuetHint: String = "请说话，我在听呢"

    static let defaultHotspotSize: CGSize = CGSize(width: 80, height: 80)

    static let defaultMultipleChoiceQuestion: String = "在以下选项中，请问哪个是正确答案？"
    static let defaultMultipleChoiceOptions: [String] = ["选项一", "选项二", "选项三", "选项四"]

    static let defaultSketchStrokeColorCode: [Decimal] = [0, 0, 0, 1]

    static let defaultTextInfo: String = "请输入文字"
    static let defaultTextCenter: CGPoint = CGPoint(x: defaultTextSize.width / 2, y: defaultTextSize.height / 2)
    static let defaultTextSize: CGSize = CGSize(width: 128, height: 56)
    static let defaultTextFontSize: CGFloat = 18
    static let defaultTextForegroundColorCode: [Decimal] = [255, 255, 255, 1]

    static let defaultVoteQuestion: String = "你喜欢吃甜粽子还是咸粽子？"
    static let defaultVoteOptions: [String] = ["甜粽子", "咸粽子"]
}

enum MetaNodeURLConstants {
}

enum MetaNodeViewLayoutConstants {
}
