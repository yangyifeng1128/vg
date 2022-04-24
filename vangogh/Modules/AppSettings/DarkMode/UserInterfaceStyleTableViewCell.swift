///
/// UserInterfaceStyleTableViewCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class UserInterfaceStyleTableViewCell: UITableViewCell {

    static let reuseId: String = "UserInterfaceStyleTableViewCell"

    /// 视图布局常量枚举值
    enum VC {
        static let titleLabelFontSize: CGFloat = 16
        static let checkmarkViewWidth: CGFloat = 20
    }

    /// 标题标签
    var titleLabel: UILabel!
    /// 勾选视图
    var checkmarkView: UIImageView!

    /// 初始化
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // 初始化视图

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

        // 初始化「勾选视图」

        checkmarkView = UIImageView(image: .check)
        checkmarkView.isHidden = true
        checkmarkView.tintColor = .accent
        contentView.addSubview(checkmarkView)
        checkmarkView.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.checkmarkViewWidth)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }

    /// 准备重用单元格
    override func prepareForReuse() {

        super.prepareForReuse()
    }
}
