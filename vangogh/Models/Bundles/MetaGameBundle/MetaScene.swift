///
/// MetaScene
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaScene: Codable, Equatable {

    /// 索引
    private(set) var index: Int
    /// UUID
    private(set) var uuid: String
    /// 标题
    var title: String?
    /// 中心位置
    var center: CGPoint

    enum CodingKeys: String, CodingKey {
        case index
        case uuid
        case title
        case center
    }

    /// 初始化
    init(index: Int, uuid: String = UUID().uuidString.lowercased(), title: String? = "", center: CGPoint) {

        self.index = index
        self.uuid = uuid
        self.title = title
        self.center = center
    }
}

extension MetaScene: CustomStringConvertible {

    var description: String {
        if let title = title, !title.isEmpty {
            return "\(index).\(title)"
        } else {
            return "\(index)"
        }
    }
}

extension MetaScene: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

func == (lhs: MetaScene, rhs: MetaScene) -> Bool {
    return lhs.uuid == rhs.uuid
}
