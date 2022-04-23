///
/// MetaSceneBundle
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaSceneBundle: Codable {

    private(set) var sceneUUID: String
    private(set) var gameUUID: String

    var aspectRatioType: MetaSceneAspectRatioType
    var currentTimeMilliseconds: Int64
    var maxFootageIndex: Int = 0
    var maxNodeIndex: Int = 0

    var footages: [MetaFootage] = []
    var nodes: [MetaNode] = []
    var rules: [MetaRule] = []

    enum CodingKeys: String, CodingKey {
        case sceneUUID = "scene_uuid"
        case gameUUID = "game_uuid"
        case aspectRatioType = "aspect_ratio_type"
        case currentTimeMilliseconds = "current_time_milliseconds"
        case maxFootageIndex = "max_footage_index"
        case maxNodeIndex = "max_node_index"
        case footages
        case nodes
        case rules
    }

    init(sceneUUID: String, gameUUID: String, aspectRatioType: MetaSceneAspectRatioType = .h16w9, currentTimeMilliseconds: Int64 = 0) {

        self.sceneUUID = sceneUUID
        self.gameUUID = gameUUID
        self.aspectRatioType = aspectRatioType
        self.currentTimeMilliseconds = currentTimeMilliseconds
    }

    required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        sceneUUID = try container.decode(String.self, forKey: .sceneUUID)
        gameUUID = try container.decode(String.self, forKey: .gameUUID)
        aspectRatioType = try container.decode(MetaSceneAspectRatioType.self, forKey: .aspectRatioType)
        currentTimeMilliseconds = try container.decode(Int64.self, forKey: .currentTimeMilliseconds)
        maxFootageIndex = try container.decode(Int.self, forKey: .maxFootageIndex)
        maxNodeIndex = try container.decode(Int.self, forKey: .maxNodeIndex)
        footages = try container.decode([MetaFootage].self, forKey: .footages)
        nodes = try container.decode([AnyMetaNode].self, forKey: .nodes).map { $0.base }
        rules = try container.decode([MetaRule].self, forKey: .rules)
    }

    func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sceneUUID, forKey: .sceneUUID)
        try container.encode(gameUUID, forKey: .gameUUID)
        try container.encode(aspectRatioType, forKey: .aspectRatioType)
        try container.encode(currentTimeMilliseconds, forKey: .currentTimeMilliseconds)
        try container.encode(maxFootageIndex, forKey: .maxFootageIndex)
        try container.encode(maxNodeIndex, forKey: .maxNodeIndex)
        try container.encode(footages, forKey: .footages)
        try container.encode(nodes.map(AnyMetaNode.init), forKey: .nodes)
        try container.encode(rules, forKey: .rules)
    }

    func updateNode(_ node: MetaNode) {

        for (i, n) in nodes.enumerated() {
            if n.uuid == node.uuid {
                nodes[i] = node
                break
            }
        }
    }

    func findNodeRules(index: Int) -> [MetaRule] {

        // FIXME：查找某个组件相关的规则

        return rules
    }
}

extension MetaSceneBundle: CustomStringConvertible {

    var description: String {
        let info: String = "sceneUUID: \(sceneUUID), gameUUID: \(gameUUID), aspectRatioType: \(aspectRatioType), currentTimeMilliseconds: \(currentTimeMilliseconds), maxFootageIndex: \(maxFootageIndex), maxNodeIndex: \(maxNodeIndex), footages: \(footages), nodes: \(nodes), rules: \(rules)"
        return info
    }
}
