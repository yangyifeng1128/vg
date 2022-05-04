///
/// GlobalConstants
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

/// 全局键常量
enum GKC {

    static let agreementsSigned: String = "agreementsSigned"
    static let currentMainTabBarItemIndex: String = "currentMainTabBarItemIndex"
    static let firstTourOfGameEditorEnded: String = "firstTourOfGameEditorEnded"
    static let ignoresSystemUserInterfaceStyle: String = "ignoresSystemUserInterfaceStyle"
    static let isInLightMode: String = "isInLightMode"
    static let isOldFriend: String = "isOldFriend"
    static let localGamesCounter: String = "localGamesCounter"
    static let skippedCoachMarksCountOfGameEditor: String = "skippedCoachMarksCountOfGameEditor"
    static let snappedTimeMillisecondsPool: String = "snappedTimeMillisecondsPool"

    static let downloadTemplatesURLSessionIdentifier: String = "\(Bundle.main.bundleIdentifier!).downloadTemplatesURLSession"
    static let loadTrackItemContentViewThumbImageQueueIdentifier: String = "\(Bundle.main.bundleIdentifier!).loadTrackItemContentViewThumbImageQueue"

    /**
     * /editor/[user_uuid]
     * /editor/[user_uuid]/[game_uuid]
     * /editor/[user_uuid]/[game_uuid]/source
     * /editor/[user_uuid]/[game_uuid]/source/[game_uuid].json
     * /editor/[user_uuid]/[game_uuid]/source/scenes
     * /editor/[user_uuid]/[game_uuid]/source/scenes/[scene_id]
     * /editor/[user_uuid]/[game_uuid]/source/scenes/[scene_id]/[scene_id].json
     * /editor/[user_uuid]/[game_uuid]/source/scenes/[scene_id]/...
     * /editor/[user_uuid]/[game_uuid]/source/thumbs
     * /editor/[user_uuid]/[game_uuid]/source/thumbs/...
     * /editor/[user_uuid]/[game_uuid]/records
     * /editor/[user_uuid]/[game_uuid]/records/1.0
     * /editor/[user_uuid]/[game_uuid]/records/1.0/[record_uuid]
     * /editor/[user_uuid]/[game_uuid]/records/1.0/[record_uuid]/[record_uuid].json
     * /editor/[user_uuid]/[game_uuid]/records/1.0/[record_uuid]/...
     * /editor/[user_uuid]/[game_uuid]/archives
     * /editor/[user_uuid]/[game_uuid]/archives/1.0
     * /editor/shared/templates
     * /editor/shared/templates/[template_uuid]
     * /editor/shared/templates/[template_uuid]/...
     *
     * /emulator/[user_uuid]
     * /emulator/[user_uuid]/[game_uuid]
     * /emulator/[user_uuid]/[game_uuid]/source
     * /emulator/[user_uuid]/[game_uuid]/source/...
     * /emulator/[user_uuid]/[game_uuid]/records
     * /emulator/[user_uuid]/[game_uuid]/records/1.0
     * /emulator/[user_uuid]/[game_uuid]/records/1.0/[record_uuid]
     * /emulator/[user_uuid]/[game_uuid]/records/1.0/[record_uuid]/[record_uuid].json
     * /emulator/[user_uuid]/[game_uuid]/records/1.0/[record_uuid]/...
     * /emulator/[user_uuid]/[game_uuid]/archives
     * /emulator/[user_uuid]/[game_uuid]/archives/1.0
     */

    static let editorDirectoryName: String = "editor"
    static let emulatorDirectoryName: String = "emulator"
    static let sourceDirectoryName: String = "source"
    static let recordsDirectoryName: String = "records"
    static let archivesDirectoryName: String = "archives"
    static let scenesDirectoryName: String = "scenes"
    static let thumbImageFilesDirectoryName: String = "thumbs"
    static let sharedDirectoryName: String = "shared"
    static let templatesDirectoryName: String = "templates"
}

/// 全局值常量
enum GVC {

    // 默认值常量

    static let appVersion: String = "1.0.0"
    static let defaultImageTrackItemDurationMilliseconds: Int64 = 5000 /* 5s */
    static let defaultNodeItemDurationMilliseconds: Int64 = 5000 /* 5s */
    static let defaultTimelineItemWidthPerSecond: Double = 20 /* 20px */
    static let minTrackItemDurationMilliseconds: Int64 = 3000 /* 3s */
    static let minNodeItemDurationMilliseconds: Int64 = 3000 /* 3s */
    static let nilGameUUID: String = "0"
    static let nilSceneUUID: String = "0"
    static let preferredTimescale: Int32 = 1000
    static let snappedTimeMillisecondsThreshold: Int64 = 300 /* 300ms */

    // 视图布局常量

    static let addSceneViewBackgroundColor: UIColor? = .accent
    static let alertTextFieldFontSize: CGFloat = 16
    static let bottomSheetViewGripWidth: CGFloat = 64
    static let bottomSheetViewGripHeight: CGFloat = 5
    static let bottomSheetViewPullBarHeight: CGFloat = 24
    static let bottomSheetViewCornerRadius: CGFloat = 32
    static let defaultGameboardViewContentOffset: CGPoint = CGPoint(x: -1, y: -1) // 代表当前作品板居中
    static let defaultSceneAspectRatio: CGFloat = 0.75
    static let defaultSceneControlBackgroundColor: UIColor = UIColor.systemGroupedBackground.withAlphaComponent(0.9)
    static let defaultTopBarButtonContainerWidth: CGFloat = 64
    static let defaultTopBarButtonContainerPadding: CGFloat = 12
    static let defaultTopBarTitleLabelFontSize: CGFloat = 16
    static let defaultViewBackgroundColor: UIColor = .systemGray3
    static let defaultViewCornerRadius: CGFloat = 8
    static let standardDeviceCornerRadius: CGFloat = 32 /* 39 */
    static let standardDeviceSize: CGSize = CGSize(width: 375, height: 667) /* CGSize(width: 390, height: 694) */
    static let timelineItemEarViewWidth: CGFloat = 24
}

/// 全局 URL 常量
enum GUC {

    static let baseURLString: String = "https://api.artbean.cn/v1/vangogh"
    static let templatesURLString: String = "\(baseURLString)/sample-drawings"
    static let templateBundlesBaseURLString: String = "https://api.artbean.cn/sample-drawing-bundles"
    static let templateThumbsBaseURLString: String = "https://api.artbean.cn/sample-drawing-thumbs"
    static let metaGameURLScheme: String = "metagame"
}

/// 自定义颜色
extension UIColor {

    static let accent: UIColor? = UIColor(named: "Accent")
    static let bcBlue: UIColor? = UIColor(named: "BCBlue")
    static let bcBrown: UIColor? = UIColor(named: "BCBrown")
    static let bcCyan: UIColor? = UIColor(named: "BCCyan")
    static let bcGreen: UIColor? = UIColor(named: "BCGreen")
    static let bcGrey: UIColor? = UIColor(named: "BCGrey")
    static let bcIndigo: UIColor? = UIColor(named: "BCIndigo")
    static let bcPurple: UIColor? = UIColor(named: "BCPurple")
    static let bcRed: UIColor? = UIColor(named: "BCRed")
    static let bcTeal: UIColor? = UIColor(named: "BCTeal")
    static let bcYellow: UIColor? = UIColor(named: "BCYellow")
    static let mgLabel: UIColor? = UIColor(named: "MGLabel")
    static let fcBlue: UIColor? = UIColor(named: "FCBlue")
    static let fcBrown: UIColor? = UIColor(named: "FCBrown")
    static let fcCyan: UIColor? = UIColor(named: "FCCyan")
    static let fcGreen: UIColor? = UIColor(named: "FCGreen")
    static let fcIndigo: UIColor? = UIColor(named: "FCIndigo")
    static let fcPurple: UIColor? = UIColor(named: "FCPurple")
    static let fcRed: UIColor? = UIColor(named: "FCRed")
    static let fcTeal: UIColor? = UIColor(named: "FCTeal")
    static let fcYellow: UIColor? = UIColor(named: "FCYellow")
}

/// 自定义图像
extension UIImage {

    static let add: UIImage? = UIImage(named: "Add")
    static let addLink: UIImage? = UIImage(named: "AddLink")
    static let addNote: UIImage? = UIImage(named: "AddNote")
    static let animatedImage: UIImage? = UIImage(named: "AnimatedImage")
    static let answerPlus: UIImage? = UIImage(named: "AnswerPlus")
    static let arCamera: UIImage? = UIImage(named: "ARCamera")
    static let arrowBack: UIImage? = UIImage(named: "ArrowBack")
    static let askPlus: UIImage? = UIImage(named: "AskPlus")
    static let artboardPlus: UIImage? = UIImage(named: "ArtboardPlus")
    static let audioPlus: UIImage? = UIImage(named: "AudioPlus")
    static let bulletScreen: UIImage? = UIImage(named: "BulletScreen")
    static let button: UIImage? = UIImage(named: "Button")
    static let camera: UIImage? = UIImage(named: "Camera")
    static let cameraPlus: UIImage? = UIImage(named: "CameraPlus")
    static let check: UIImage? = UIImage(named: "Check")
    static let checkpoint: UIImage? = UIImage(named: "Checkpoint")
    static let chevronLeft: UIImage? = UIImage(named: "ChevronLeft")
    static let chevronRight: UIImage? = UIImage(named: "ChevronRight")
    static let circle: UIImage? = UIImage(named: "Circle")
    static let close: UIImage? = UIImage(named: "Close")
    static let coloring: UIImage? = UIImage(named: "Coloring")
    static let compose: UIImage? = UIImage(named: "Compose")
    static let delete: UIImage? = UIImage(named: "Delete")
    static let downloading: UIImage? = UIImage(named: "Downloading")
    static let duet: UIImage? = UIImage(named: "Duet")
    static let edit: UIImage? = UIImage(named: "Edit")
    static let editInfo: UIImage? = UIImage(named: "EditInfo")
    static let editNote: UIImage? = UIImage(named: "EditNote")
    static let emulate: UIImage? = UIImage(named: "Emulate")
    static let gameBackgroundThumb: UIImage? = UIImage(named: "GameBackgroundThumb")
    static let gameSettings: UIImage? = UIImage(named: "GameSettings")
    static let goBack: UIImage? = UIImage(named: "GoBack")
    static let handPointUp: UIImage? = UIImage(named: "HandPointUp")
    static let hotspot: UIImage? = UIImage(named: "Hotspot")
    static let info: UIImage? = UIImage(named: "Info")
    static let microphonePlus: UIImage? = UIImage(named: "MicrophonePlus")
    static let more: UIImage? = UIImage(named: "More")
    static let multipleChoice: UIImage? = UIImage(named: "MultipleChoice")
    static let music: UIImage? = UIImage(named: "Music")
    static let open: UIImage? = UIImage(named: "Open")
    static let openInNew: UIImage? = UIImage(named: "OpenInNew")
    static let pause: UIImage? = UIImage(named: "Pause")
    static let play: UIImage? = UIImage(named: "Play")
    static let publish: UIImage? = UIImage(named: "Publish")
    static let rectangle: UIImage? = UIImage(named: "Rectangle")
    static let redo: UIImage? = UIImage(named: "Redo")
    static let save: UIImage? = UIImage(named: "Save")
    static let scan: UIImage? = UIImage(named: "Scan")
    static let sceneBackground: UIImage? = UIImage(named: "SceneBackground")
    static let sceneBackgroundThumb: UIImage? = UIImage(named: "SceneBackgroundThumb")
    static let sceneSettings: UIImage? = UIImage(named: "SceneSettings")
    static let settings: UIImage? = UIImage(named: "Settings")
    static let share: UIImage? = UIImage(named: "Share")
    static let sketch: UIImage? = UIImage(named: "Sketch")
    static let sketchArrowDown: UIImage? = UIImage(named: "SketchArrowDown")
    static let sketchArrowUp: UIImage? = UIImage(named: "SketchArrowUp")
    static let star: UIImage? = UIImage(named: "Star")
    static let stickerPlus: UIImage? = UIImage(named: "StickerPlus")
    static let text: UIImage? = UIImage(named: "Text")
    static let torch: UIImage? = UIImage(named: "Torch")
    static let torchOff: UIImage? = UIImage(named: "TorchOff")
    static let triangle: UIImage? = UIImage(named: "Triangle")
    static let triangleLeft: UIImage? = UIImage(named: "TriangleLeft")
    static let triangleRight: UIImage? = UIImage(named: "TriangleRight")
    static let undo: UIImage? = UIImage(named: "Undo")
    static let unfold: UIImage? = UIImage(named: "Unfold")
    static let voiceOver: UIImage? = UIImage(named: "VoiceOver")
    static let vote: UIImage? = UIImage(named: "Vote")
}
