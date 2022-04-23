///
/// MetaActionType
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

enum MetaActionType: String, CaseIterable, Codable {

    case openGame
    case quitGame

    case transitScene

    var metaType: MetaAction.Type {
        switch self {
        case .openGame:
            return MetaOpenGame.self
        case .quitGame:
            return MetaQuitGame.self
        case .transitScene:
            return MetaTransitScene.self
        }
    }
}
