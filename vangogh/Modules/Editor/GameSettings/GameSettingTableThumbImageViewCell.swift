///
/// GameSettingTableThumbImageViewCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class GameSettingTableThumbImageViewCell: UITableViewCell {

    static let reuseId: String = "GameSettingTableThumbImageViewCell"

    /// 视图布局常量枚举值
    enum VC {
        static let titleLabelFontSize: CGFloat = 16
        static let chevronViewWidth: CGFloat = 24
        static let thumbImageViewHeight: CGFloat = 56
    }

    /// 标题标签
    var titleLabel: UILabel!
    /// chevron 视图
    var chevronView: UIImageView!
    /// 缩略图视图
    var thumbImageView: RoundedImageView!

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

        // 初始化「缩略图视图」

        thumbImageView = RoundedImageView(cornerRadius: GVC.defaultViewCornerRadius)
        thumbImageView.contentMode = .scaleAspectFill
        contentView.addSubview(thumbImageView)
        let thumbImageViewHeight: CGFloat = GameSettingTableThumbImageViewCell.VC.thumbImageViewHeight
        let thumbImageViewWidth: CGFloat = thumbImageViewHeight * GVC.defaultSceneAspectRatio
        thumbImageView.snp.makeConstraints { make -> Void in
            make.width.equalTo(thumbImageViewWidth)
            make.height.equalTo(thumbImageViewHeight)
            make.centerY.equalToSuperview()
            make.right.equalTo(chevronView.snp.left).offset(-8)
        }
    }

    /// 准备重用单元格
    override func prepareForReuse() {

        super.prepareForReuse()
    }
}
