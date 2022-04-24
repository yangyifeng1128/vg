///
/// TimelineToolBarItemCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class TimelineToolBarItemCell: UICollectionViewCell {

    static let reuseId: String = "TimelineToolBarItemCell"

    /// 视图布局常量枚举值
    enum VC {
        static let titleLabelFontSize: CGFloat = 11
        static let iconViewWidth: CGFloat = 22
    }

    var titleLabel: UILabel!
    var iconView: UIImageView!

    override init(frame: CGRect) {

        super.init(frame: frame)

        // 初始化视图

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {

        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: VC.titleLabelFontSize, weight: .regular)
        titleLabel.textColor = .mgLabel
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }

        iconView = UIImageView()
        contentView.addSubview(iconView)
        iconView.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.iconViewWidth)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-8)
        }
    }

    override func prepareForReuse() {

        super.prepareForReuse()

        iconView.image = nil
    }
}
