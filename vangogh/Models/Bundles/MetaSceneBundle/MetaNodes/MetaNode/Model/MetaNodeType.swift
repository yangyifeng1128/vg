///
/// MetaNodeType
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

enum MetaNodeType: String, CaseIterable, Codable {

    case music
    case voiceOver = "voice_over"

    case text
    case animatedImage = "animated_image"
    case button

    case vote
    case multipleChoice = "multiple_choice"
    case hotspot

    case checkpoint = "checkpoint"
    case bulletScreen = "bullet_screen"

    case sketch
    case coloring

    case camera
    case arCamera = "ar_camera"

    case duet

    var metaType: MetaNode.Type {
        switch self {
        case .music:
            return MetaMusic.self
        case .voiceOver:
            return MetaVoiceOver.self
        case .text:
            return MetaText.self
        case .animatedImage:
            return MetaAnimatedImage.self
        case .button:
            return MetaButton.self
        case .vote:
            return MetaVote.self
        case .multipleChoice:
            return MetaMultipleChoice.self
        case .hotspot:
            return MetaHotspot.self
        case .checkpoint:
            return MetaCheckpoint.self
        case .bulletScreen:
            return MetaBulletScreen.self
        case .sketch:
            return MetaSketch.self
        case .coloring:
            return MetaColoring.self
        case .camera:
            return MetaCamera.self
        case .arCamera:
            return MetaARCamera.self
        case .duet:
            return MetaDuet.self
        }
    }
}

class MetaNodeTypeManager {

    static var shared = MetaNodeTypeManager()

    func getNodeTypeLocalizedTitle(nodeType: MetaNodeType) -> String? {

        var localizedTitle: String?

        switch nodeType {
        case .music:
            localizedTitle = NSLocalizedString("MusicNode", comment: "")
            break
        case .voiceOver:
            localizedTitle = NSLocalizedString("VoiceOverNode", comment: "")
            break
        case .text:
            localizedTitle = NSLocalizedString("TextNode", comment: "")
            break
        case .animatedImage:
            localizedTitle = NSLocalizedString("AnimatedImageNode", comment: "")
            break
        case .button:
            localizedTitle = NSLocalizedString("ButtonNode", comment: "")
            break
        case .vote:
            localizedTitle = NSLocalizedString("VoteNode", comment: "")
            break
        case .multipleChoice:
            localizedTitle = NSLocalizedString("MultipleChoiceNode", comment: "")
            break
        case .hotspot:
            localizedTitle = NSLocalizedString("HotspotNode", comment: "")
            break
        case .checkpoint:
            localizedTitle = NSLocalizedString("CheckpointNode", comment: "")
            break
        case .bulletScreen:
            localizedTitle = NSLocalizedString("BulletScreenNode", comment: "")
            break
        case .sketch:
            localizedTitle = NSLocalizedString("SketchNode", comment: "")
            break
        case .coloring:
            localizedTitle = NSLocalizedString("ColoringNode", comment: "")
            break
        case .camera:
            localizedTitle = NSLocalizedString("CameraNode", comment: "")
            break
        case .arCamera:
            localizedTitle = NSLocalizedString("ARCameraNode", comment: "")
            break
        case .duet:
            localizedTitle = NSLocalizedString("DuetNode", comment: "")
            break
        }

        return localizedTitle
    }

    func getNodeTypeIcon(nodeType: MetaNodeType) -> UIImage? {

        var icon: UIImage?

        switch nodeType {
        case .music:
            icon = .music
            break
        case .voiceOver:
            icon = .voiceOver
            break
        case .text:
            icon = .text
            break
        case .animatedImage:
            icon = .animatedImage
            break
        case .button:
            icon = .button
            break
        case .vote:
            icon = .vote
            break
        case .multipleChoice:
            icon = .multipleChoice
            break
        case .hotspot:
            icon = .hotspot
            break
        case .checkpoint:
            icon = .checkpoint
            break
        case .bulletScreen:
            icon = .bulletScreen
            break
        case .sketch:
            icon = .sketch
            break
        case .coloring:
            icon = .coloring
            break
        case .camera:
            icon = .camera
            break
        case .arCamera:
            icon = .arCamera
            break
        case .duet:
            icon = .duet
            break
        }

        return icon
    }

    func getNodeTypeBackgroundColor(nodeType: MetaNodeType) -> UIColor? {

        var color: UIColor?

        switch nodeType {
        case .music:
            color = .bcRed
            break
        case .voiceOver:
            color = .bcRed
            break
        case .text:
            color = .bcYellow
            break
        case .animatedImage:
            color = .bcYellow
            break
        case .button:
            color = .bcYellow
            break
        case .vote:
            color = .bcGreen
            break
        case .multipleChoice:
            color = .bcGreen
            break
        case .hotspot:
            color = .bcGreen
            break
        case .checkpoint:
            color = .bcBlue
            break
        case .bulletScreen:
            color = .bcBlue
            break
        case .sketch:
            color = .bcIndigo
            break
        case .coloring:
            color = .bcIndigo
            break
        case .camera:
            color = .bcPurple
            break
        case .arCamera:
            color = .bcPurple
            break
        case .duet:
            color = .bcBrown
            break
        }

        return color
    }

    func getNodeTypeTextColor(nodeType: MetaNodeType) -> UIColor? {

        var color: UIColor?

        switch nodeType {
        case .music:
            color = .fcRed
            break
        case .voiceOver:
            color = .fcRed
            break
        case .text:
            color = .fcYellow
            break
        case .animatedImage:
            color = .fcYellow
            break
        case .button:
            color = .fcYellow
            break
        case .vote:
            color = .fcGreen
            break
        case .multipleChoice:
            color = .fcGreen
            break
        case .hotspot:
            color = .fcGreen
            break
        case .checkpoint:
            color = .fcBlue
            break
        case .bulletScreen:
            color = .fcBlue
            break
        case .sketch:
            color = .fcIndigo
            break
        case .coloring:
            color = .fcIndigo
            break
        case .camera:
            color = .fcPurple
            break
        case .arCamera:
            color = .fcPurple
            break
        case .duet:
            color = .fcBrown
            break
        }

        return color
    }
}
