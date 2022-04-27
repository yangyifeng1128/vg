///
/// SceneSettingTableViewCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class SceneSettingTableViewCell: UITableViewCell {

    static let reuseId: String = "SceneSettingTableViewCell"

    /// 视图布局常量枚举值
    enum VC {
        static let titleLabelFontSize: CGFloat = 16
        static let chevronViewWidth: CGFloat = 24
        static let infoLabelFontSize: CGFloat = 14
    }

    /// 标题标签
    var titleLabel: UILabel!
    /// chevron 视图
    var chevronView: UIImageView!
    /// 信息标签
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
        titleLabel.textColor = .mgLabel
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }

        // 初始化「chevron 视图」

        chevronView = UIImageView(image: .chevronRight)
        chevronView.tintColor = .tertiaryLabel
        contentView.addSubview(chevronView)
        chevronView.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.chevronViewWidth)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
        }

        // 初始化「信息标签」

        infoLabel = UILabel()
        infoLabel.font = .systemFont(ofSize: VC.infoLabelFontSize, weight: .regular)
        infoLabel.textColor = .secondaryLabel
        infoLabel.textAlignment = .right
        infoLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make -> Void in
            make.centerY.equalToSuperview()
            make.left.equalTo(titleLabel.snp.right).offset(8)
            make.right.equalTo(chevronView.snp.left).offset(-8)
        }
    }

    /// 准备重用单元格
    override func prepareForReuse() {

        super.prepareForReuse()
    }
}
