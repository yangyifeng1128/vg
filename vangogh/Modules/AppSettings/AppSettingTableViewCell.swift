///
/// AppSettingTableViewCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class AppSettingTableViewCell: UITableViewCell {

    static let reuseId: String = "AppSettingTableViewCell"

    // 视图布局常量枚举值

    enum ViewLayoutConstants {
        static let titleLabelFontSize: CGFloat = 16
        static let chevronViewWidth: CGFloat = 24
    }

    var titleLabel: UILabel!
    var chevronView: UIImageView!

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
        titleLabel.textColor = .mgLabel
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }

        // 准备 chevronView

        chevronView = UIImageView(image: .chevronRight)
        chevronView.tintColor = .tertiaryLabel
        contentView.addSubview(chevronView)
        chevronView.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(ViewLayoutConstants.chevronViewWidth)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
        }
    }

    override func prepareForReuse() {

        super.prepareForReuse()
    }
}
