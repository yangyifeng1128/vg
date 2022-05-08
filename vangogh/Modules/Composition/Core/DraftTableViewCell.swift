///
/// DraftTableViewCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class DraftTableViewCell: UITableViewCell {

    static let reuseId: String = "DraftTableViewCell"

    /// 视图布局常量枚举值
    enum VC {
        static let moreButtonWidth: CGFloat = 40
        static let mtimeLabelFontSize: CGFloat = 14
        static let titleLabelFontSize: CGFloat = 16
    }

    /// 缩略图视图
    var thumbImageView: RoundedImageView!
    /// 更多按钮
    var moreButton: UIButton!
    /// 最近修改时间标签
    var mtimeLabel: UILabel!
    /// 标题标签
    var titleLabel: UILabel!

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

        // 初始化「缩略图视图」

        thumbImageView = RoundedImageView()
        thumbImageView.backgroundColor = GVC.defaultViewBackgroundColor
        contentView.addSubview(thumbImageView)
        let thumbImageViewHeight: CGFloat = CompositionViewController.VC.draftTableViewCellHeight - 16
        let thumbImageViewWidth: CGFloat = thumbImageViewHeight * GVC.defaultSceneAspectRatio
        thumbImageView.snp.makeConstraints { make -> Void in
            make.width.equalTo(thumbImageViewWidth)
            make.height.equalTo(thumbImageViewHeight)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }

        // 初始化「更多按钮」

        moreButton = UIButton()
        moreButton.tintColor = .secondaryLabel
        moreButton.setImage(.more, for: .normal)
        moreButton.imageView?.tintColor = .secondaryLabel
        contentView.addSubview(moreButton)
        moreButton.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.moreButtonWidth)
            make.height.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }

        // 添加「最近修改时间标签」

        mtimeLabel = UILabel()
        mtimeLabel.font = .systemFont(ofSize: VC.mtimeLabelFontSize, weight: .regular)
        mtimeLabel.textColor = .secondaryLabel
        contentView.addSubview(mtimeLabel)
        mtimeLabel.snp.makeConstraints { make -> Void in
            make.left.equalTo(thumbImageView.snp.right).offset(12)
            make.right.equalTo(moreButton.snp.left).offset(-12)
            make.bottom.equalTo(thumbImageView).offset(-8)
        }

        // 添加「标题标签」

        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: VC.titleLabelFontSize, weight: .regular)
        titleLabel.textColor = .mgLabel
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.width.equalTo(mtimeLabel)
            make.left.equalTo(mtimeLabel)
            make.top.equalTo(thumbImageView).offset(4)
            make.bottom.equalTo(mtimeLabel.snp.top).offset(-4)
        }
    }

    /// 准备重用单元格
    override func prepareForReuse() {

        super.prepareForReuse()

        thumbImageView.image = nil
    }
}
