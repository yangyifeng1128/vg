///
/// TemplateCollectionViewCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class TemplateCollectionViewCell: RoundedCollectionViewCell {

    static let reuseId: String = "TemplateCollectionViewCell"

    /// 视图布局常量枚举值
    enum VC {
        static let titleLabelHeight: CGFloat = 48
        static let titleLabelFontSize: CGFloat = 13
    }

    /// 缩略图视图
    var thumbImageView: UIImageView!
    /// 标题标签
    var titleLabel: AttributedLabel!

    /// 初始化
    override init(frame: CGRect) {

        super.init(frame: frame)

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        contentView.backgroundColor = GVC.defaultViewBackgroundColor

        // 初始化「缩略图视图」

        thumbImageView = UIImageView(frame: contentView.bounds)
        thumbImageView.contentMode = .scaleAspectFill
        contentView.addSubview(thumbImageView)

        // 初始化「标题标签」

        titleLabel = AttributedLabel()
        titleLabel.insets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 4)
        titleLabel.backgroundColor = UIColor.secondarySystemGroupedBackground.withAlphaComponent(0.6)
        titleLabel.font = .systemFont(ofSize: VC.titleLabelFontSize, weight: .regular)
        titleLabel.textColor = .mgLabel
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(VC.titleLabelHeight)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    /// 准备重用单元格
    override func prepareForReuse() {

        super.prepareForReuse()

        thumbImageView.image = nil
    }
}
