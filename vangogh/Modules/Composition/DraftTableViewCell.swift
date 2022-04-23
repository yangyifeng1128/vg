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
    enum ViewLayoutConstants {
        static let moreButtonWidth: CGFloat = 40
        static let mtimeLabelFontSize: CGFloat = 14
        static let titleLabelFontSize: CGFloat = 18
    }

    var thumbImageView: RoundedImageView! // 缩略图视图
    var moreButton: UIButton! // 「更多」按钮
    var mtimeLabel: UILabel! // 最近修改时间标签
    var titleLabel: UILabel! // 标题标签

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

        // 添加缩略图视图

        thumbImageView = RoundedImageView(cornerRadius: GlobalViewLayoutConstants.defaultViewCornerRadius)
        thumbImageView.backgroundColor = GlobalViewLayoutConstants.defaultViewBackgroundColor
        contentView.addSubview(thumbImageView)
        let thumbImageViewHeight: CGFloat = CompositionViewController.ViewLayoutConstants.draftTableViewCellHeight - 16
        let thumbImageViewWidth: CGFloat = thumbImageViewHeight * GlobalViewLayoutConstants.defaultSceneAspectRatio
        thumbImageView.snp.makeConstraints { make -> Void in
            make.width.equalTo(thumbImageViewWidth)
            make.height.equalTo(thumbImageViewHeight)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }

        // 添加「更多」按钮

        moreButton = UIButton()
        moreButton.tintColor = .secondaryLabel
        moreButton.setImage(.more, for: .normal)
        moreButton.imageView?.tintColor = .secondaryLabel
        contentView.addSubview(moreButton)
        moreButton.snp.makeConstraints { make -> Void in
            make.width.equalTo(ViewLayoutConstants.moreButtonWidth)
            make.height.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }

        // 添加「最近修改时间」标签

        mtimeLabel = UILabel()
        mtimeLabel.font = .systemFont(ofSize: ViewLayoutConstants.mtimeLabelFontSize, weight: .regular)
        mtimeLabel.textColor = .secondaryLabel
        contentView.addSubview(mtimeLabel)
        mtimeLabel.snp.makeConstraints { make -> Void in
            make.left.equalTo(thumbImageView.snp.right).offset(12)
            make.right.equalTo(moreButton.snp.left).offset(-12)
            make.bottom.equalTo(thumbImageView).offset(-8)
        }

        // 添加标题标签

        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: ViewLayoutConstants.titleLabelFontSize, weight: .regular)
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

    override func prepareForReuse() {

        super.prepareForReuse()

        thumbImageView.image = nil
    }
}
