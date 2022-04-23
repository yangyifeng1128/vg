///
/// MetaBulletScreenCellModel
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import DanmakuKit
import UIKit

class MetaBulletScreenCellModel: DanmakuCellModel {

    var identifier: String
    var cellClass: DanmakuCell.Type
    var type: DanmakuCellType

    var info: String
    var track: UInt?
    var displayTime: Double

    var font: UIFont
    var size: CGSize

    init(comment: MetaComment) {

        self.identifier = UUID().uuidString.lowercased()
        self.cellClass = MetaBulletScreenCell.self
        self.type = .floating

        self.info = comment.info
        self.displayTime = Double(MetaNodeValueConstants.defaultCommentDurationTimeMilliseconds / 1000)

        self.font = .systemFont(ofSize: MetaNodeValueConstants.defaultCommentFontSize, weight: .regular)
        self.size = NSString(string: info).boundingRect(with: CGSize(width: CGFloat(Float.infinity
            ), height: MetaNodeValueConstants.defaultCommentHeight), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [.font: font], context: nil).size
    }

    func isEqual(to cellModel: DanmakuCellModel) -> Bool {

        return identifier == cellModel.identifier
    }
}

func == (lhs: MetaBulletScreenCellModel, rhs: MetaBulletScreenCellModel) -> Bool {

    return lhs.identifier == rhs.identifier
}
