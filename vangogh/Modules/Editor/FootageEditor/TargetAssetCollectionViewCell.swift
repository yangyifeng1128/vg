///
/// TargetAssetCollectionViewCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class TargetAssetCollectionViewCell: RoundedCollectionViewCell {

    static let reuseId: String = "TargetAssetCollectionViewCell"

    /// 视图布局常量枚举值
    enum VC {
        static let videoDurationLabelFontSize: CGFloat = 13
    }

    /// 缩略图视图
    var thumbImageView: UIImageView!
    /// 视频时长标签
    var videoDurationLabel: UILabel!

    /// 素材标识符
    var assetIdentifier: String?

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

        // 初始化「视频时长标签」

        videoDurationLabel = UILabel()
        videoDurationLabel.isHidden = true
        videoDurationLabel.font = .systemFont(ofSize: VC.videoDurationLabelFontSize, weight: .regular)
        videoDurationLabel.textColor = .white
        videoDurationLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        videoDurationLabel.layer.shadowOpacity = 1
        videoDurationLabel.layer.shadowRadius = 0
        videoDurationLabel.layer.shadowColor = UIColor.black.cgColor
        contentView.addSubview(videoDurationLabel)
        videoDurationLabel.snp.makeConstraints { make -> Void in
            make.right.bottom.equalToSuperview().offset(-8)
        }
    }

    /// 准备重用单元格
    override func prepareForReuse() {

        super.prepareForReuse()

        thumbImageView.image = nil
    }
}
