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
    enum VC {
        static let height: CGFloat = 96
        static let titleLabelHeight: CGFloat = 20
        static let titleLabelFontSize: CGFloat = 14
        static let infoLabelFontSize: CGFloat = 16
    }

    var titleLabel: UILabel!
    var infoView: RoundedView!
    var infoLabel: UILabel!

    /// 初始化
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = .clear
        selectionStyle = .none

        // 初始化「标题标签」

        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: VC.titleLabelFontSize, weight: .regular)
        titleLabel.textColor = .secondaryLabel
        titleLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.height.equalTo(VC.titleLabelHeight)
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview()
        }

        // 初始化「信息视图」

        infoView = RoundedView()
        infoView.backgroundColor = .systemGroupedBackground
        contentView.addSubview(infoView)
        infoView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-16)
        }

        // 初始化「信息标签」

        infoLabel = UILabel()
        infoLabel.font = .systemFont(ofSize: VC.infoLabelFontSize, weight: .regular)
        infoLabel.textColor = .mgLabel
        infoLabel.lineBreakMode = .byTruncatingTail
        infoView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make -> Void in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
        }
    }

    /// 准备重用单元格
    override func prepareForReuse() {

        super.prepareForReuse()
    }
}
