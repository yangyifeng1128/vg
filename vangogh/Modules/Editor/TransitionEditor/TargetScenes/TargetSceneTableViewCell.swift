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
    enum VC {
        static let indexLabelFontSize: CGFloat = 20
        static let titleLabelFontSize: CGFloat = 16
        static let chevronViewWidth: CGFloat = 24
    }

    /// 缩略图视图
    var thumbImageView: RoundedImageView!
    /// 索引标签
    var indexLabel: UILabel!
    /// 标题标签
    var titleLabel: UILabel!
    /// chevron 视图
    var chevronView: UIImageView!

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

        thumbImageView = RoundedImageView(cornerRadius: GVC.defaultViewCornerRadius)
        thumbImageView.contentMode = .scaleAspectFill
        contentView.addSubview(thumbImageView)
        let thumbImageViewHeight: CGFloat = TargetScenesViewController.VC.targetSceneTableViewCellHeight - 16
        let thumbImageViewWidth: CGFloat = thumbImageViewHeight * GVC.defaultSceneAspectRatio
        thumbImageView.snp.makeConstraints { make -> Void in
            make.width.equalTo(thumbImageViewWidth)
            make.height.equalTo(thumbImageViewHeight)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }

        // 初始化「索引标签」

        indexLabel = UILabel()
        indexLabel.font = .systemFont(ofSize: VC.indexLabelFontSize, weight: .regular)
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

        // 初始化「标题标签」

        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: VC.titleLabelFontSize, weight: .regular)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.left.equalTo(thumbImageView.snp.right).offset(12)
            make.right.equalToSuperview().offset(-24)
            make.top.bottom.equalTo(thumbImageView)
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
    }

    /// 准备重用单元格
    override func prepareForReuse() {

        super.prepareForReuse()

        thumbImageView.image = nil
    }
}
