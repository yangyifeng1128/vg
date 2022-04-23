///
/// MetaNodeEditorTableTypographyViewCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class MetaNodeEditorTableTypographyViewCell: UITableViewCell {

    static let reuseId: String = "MetaNodeEditorTableTypographyViewCell"

    /// 视图布局常量枚举值
    enum ViewLayoutConstants {
        static let height: CGFloat = 96
        static let titleLabelHeight: CGFloat = 20
        static let titleLabelFontSize: CGFloat = 14
        static let infoLabelFontSize: CGFloat = 16
    }

    var titleLabel: UILabel!
    var infoView: RoundedView!
    var infoLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {

        backgroundColor = .clear
        selectionStyle = .none

        // 添加标题标签

        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: ViewLayoutConstants.titleLabelFontSize, weight: .regular)
        titleLabel.textColor = .secondaryLabel
        titleLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.height.equalTo(ViewLayoutConstants.titleLabelHeight)
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview()
        }

        // 准备信息视图

        infoView = RoundedView()
        infoView.backgroundColor = .systemGroupedBackground
        contentView.addSubview(infoView)
        infoView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-16)
        }

        infoLabel = UILabel()
        infoLabel.font = .systemFont(ofSize: ViewLayoutConstants.infoLabelFontSize, weight: .regular)
        infoLabel.textColor = .mgLabel
        infoLabel.lineBreakMode = .byTruncatingTail
        infoView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make -> Void in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
    }

    override func prepareForReuse() {

        super.prepareForReuse()
    }
}
