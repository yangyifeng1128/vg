///
/// DarkModeTableViewCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class DarkModeTableViewCell: UITableViewCell {

    static let reuseId: String = "DarkModeTableViewCell"

    // 视图布局常量枚举值

    enum ViewLayoutConstants {
        static let titleLabelFontSize: CGFloat = 16
        static let checkmarkViewWidth: CGFloat = 20
    }

    var titleLabel: UILabel!
    var checkmarkView: UIImageView!

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

        // 准备 checkmarkView

        checkmarkView = UIImageView(image: .check)
        checkmarkView.isHidden = true
        checkmarkView.tintColor = .accent
        contentView.addSubview(checkmarkView)
        checkmarkView.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(ViewLayoutConstants.checkmarkViewWidth)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }

    override func prepareForReuse() {

        super.prepareForReuse()
    }
}
