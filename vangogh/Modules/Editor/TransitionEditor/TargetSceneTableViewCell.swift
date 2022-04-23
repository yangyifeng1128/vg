///
/// TargetSceneTableViewCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class TargetSceneTableViewCell: UITableViewCell {

    static let reuseId: String = "TargetSceneTableViewCell"

    /// 视图布局常量枚举值
    enum ViewLayoutConstants {
        static let indexLabelFontSize: CGFloat = 20
        static let titleLabelFontSize: CGFloat = 16
        static let chevronViewWidth: CGFloat = 24
    }

    var thumbImageView: RoundedImageView! // 缩略图视图
    var indexLabel: UILabel! // 索引标签
    var titleLabel: UILabel! // 标题标签
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

        // 添加缩略图视图

        thumbImageView = RoundedImageView(cornerRadius: GlobalViewLayoutConstants.defaultViewCornerRadius)
        thumbImageView.contentMode = .scaleAspectFill
        contentView.addSubview(thumbImageView)
        let thumbImageViewHeight: CGFloat = TargetScenesViewController.ViewLayoutConstants.targetSceneTableViewCellHeight - 16
        let thumbImageViewWidth: CGFloat = thumbImageViewHeight * GlobalViewLayoutConstants.defaultSceneAspectRatio
        thumbImageView.snp.makeConstraints { make -> Void in
            make.width.equalTo(thumbImageViewWidth)
            make.height.equalTo(thumbImageViewHeight)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }

        indexLabel = UILabel()
        indexLabel.font = .systemFont(ofSize: ViewLayoutConstants.indexLabelFontSize, weight: .regular)
        indexLabel.textColor = .white
        indexLabel.textAlignment = .center
        indexLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        indexLabel.layer.shadowOpacity = 1
        indexLabel.layer.shadowRadius = 0
        indexLabel.layer.shadowColor = UIColor.black.cgColor
        thumbImageView.addSubview(indexLabel)
        indexLabel.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        // 添加标题标签

        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: ViewLayoutConstants.titleLabelFontSize, weight: .regular)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.left.equalTo(thumbImageView.snp.right).offset(12)
            make.right.equalToSuperview().offset(-24)
            make.top.bottom.equalTo(thumbImageView)
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

        thumbImageView.image = nil
    }
}
