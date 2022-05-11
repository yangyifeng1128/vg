///
/// NodeItemBottomBarItemCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class NodeItemBottomBarItemCell: UICollectionViewCell {

    static let reuseId: String = "NodeItemBottomBarItemCell"

    /// 视图布局常量枚举值
    enum VC {
        static let titleLabelFontSize: CGFloat = 16
        static let iconViewWidth: CGFloat = 20
    }

    /// 信息视图
    var infoView: RoundedView!
    /// 标题标签
    var titleLabel: UILabel!
    /// 图标视图
    var iconView: UIImageView!

    /// 操作栏项列表
    private var actionBarItems: [TrackItemBottomBarItem]!

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
            make.width.height.equalTo(VC.iconViewWidth)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
        }

        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: VC.titleLabelFontSize, weight: .regular)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.centerY.equalToSuperview()
            make.left.equalTo(iconView.snp.right).offset(4)
            make.right.equalToSuperview()
        }
    }

    /// 准备重用单元格
    override func prepareForReuse() {

        super.prepareForReuse()

        iconView.image = nil
    }
}
