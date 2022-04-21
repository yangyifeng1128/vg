///
/// MetaNode
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Foundation

protocol MetaNode: Codable {

    var index: Int { get set }
    var uuid: String { get set }
    var nodeType: MetaNodeType { get set }
    var startTimeMilliseconds: Int64 { get set }
    var durationMilliseconds: Int64 { get set }
}

class AnyMetaNode: Codable {

    var base: MetaNode

    enum CodingKeys: String, CodingKey {
        case nodeType = "node_type"
        case base
    }

    init(_ base: MetaNode) {

        self.base = base
    }

    required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MetaNodeType.self, forKey: .nodeType)
        base = try type.metaType.init(from: decoder)
    }

    func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(base.nodeType, forKey: .nodeType)
        try base.encode(to: encoder)
    }
}
