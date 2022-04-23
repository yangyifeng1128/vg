///
/// NodeItemBottomBarItemCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class NodeItemBottomBarItemCell: UICollectionViewCell {

    static let reuseId: String = "NodeItemBottomBarItemCell"

    // 视图布局常量枚举值

    enum ViewLayoutConstants {
        static let titleLabelFontSize: CGFloat = 16
        static let iconViewWidth: CGFloat = 20
    }

    var infoView: RoundedView!
    var titleLabel: UILabel!
    var iconView: UIImageView!

    private var actionBarItems: [TrackItemBottomBarItem]!

    override init(frame: CGRect) {

        super.init(frame: frame)

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {

        infoView = RoundedView(cornerRadius: 4)
        contentView.addSubview(infoView)
        infoView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalToSuperview().inset(4)
            make.center.equalToSuperview()
        }

        iconView = UIImageView()
        contentView.addSubview(iconView)
        iconView.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(ViewLayoutConstants.iconViewWidth)
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }

        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: ViewLayoutConstants.titleLabelFontSize, weight: .regular)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.left.equalTo(iconView.snp.right).offset(4)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }

    override func prepareForReuse() {

        super.prepareForReuse()

        iconView.image = nil
    }
}
