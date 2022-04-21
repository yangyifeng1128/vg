///
/// MetaSensor
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaSensor: Codable, Equatable {

    var gameUUID: String
    var sceneUUID: String?
    var nodeUUID: String?
    var key: MetaSensorKey

    enum CodingKeys: String, CodingKey {
        case gameUUID = "game_uuid"
        case sceneUUID = "scene_uuid"
        case nodeUUID = "node_uuid"
        case key
    }

    init(gameUUID: String, sceneUUID: String? = nil, nodeUUID: String? = nil, key: MetaSensorKey) {

        self.gameUUID = gameUUID
        self.sceneUUID = sceneUUID
        self.nodeUUID = nodeUUID
        self.key = key
    }
}

extension MetaSensor: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(gameUUID)
        hasher.combine(sceneUUID)
        hasher.combine(nodeUUID)
        hasher.combine(key)
    }
}

func == (lhs: MetaSensor, rhs: MetaSensor) -> Bool {
    return lhs.gameUUID == rhs.gameUUID && lhs.sceneUUID == rhs.sceneUUID && lhs.nodeUUID == rhs.nodeUUID && lhs.key == rhs.key
}
