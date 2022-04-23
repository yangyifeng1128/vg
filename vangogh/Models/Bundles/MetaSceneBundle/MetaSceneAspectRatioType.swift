///
/// MetaSceneAspectRatioTypeManager
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

enum MetaSceneAspectRatioType: String, CaseIterable, Codable {
    case h4w3 = "4:3"
    case h16w9 = "16:9"
    // case h195w90 = "19.5:9"
}

class MetaSceneAspectRatioTypeManager {

    static var shared = MetaSceneAspectRatioTypeManager()

    func calculateWidth(height: CGFloat, aspectRatioType: MetaSceneAspectRatioType) -> CGFloat {

        return (height * getAspectRatio(aspectRatioType: aspectRatioType)).rounded()
    }

    func calculateHeight(width: CGFloat, aspectRatioType: MetaSceneAspectRatioType) -> CGFloat {

        return (width / getAspectRatio(aspectRatioType: aspectRatioType)).rounded()
    }

    func getAspectRatio(aspectRatioType: MetaSceneAspectRatioType) -> CGFloat {

        switch aspectRatioType {
        case .h4w3:
            return 0.75
        case .h16w9:
            return 0.5625
            // case .h195w90:
            //    return 0.4615
        }
    }
}
