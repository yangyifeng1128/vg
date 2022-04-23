///
/// TargetAssetCollectionViewCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Photos
import SnapKit
import UIKit

class TargetAssetCollectionViewCell: UICollectionViewCell {

    static let reuseId: String = "TargetAssetCollectionViewCell"

    /// 视图布局常量枚举值
    enum ViewLayoutConstants {
        static let videoDurationLabelFontSize: CGFloat = 13
    }

    private lazy var maskLayer: CAShapeLayer = {
        self.layer.mask = $0
        return $0
    }(CAShapeLayer())

    override var bounds: CGRect {
        set {
            super.bounds = newValue
            maskLayer.frame = newValue
            let newPath: CGPath = UIBezierPath(roundedRect: newValue, cornerRadius: GVC.defaultViewCornerRadius).cgPath
            if let animation = self.layer.animation(forKey: "bounds.size")?.copy() as? CABasicAnimation {
                animation.keyPath = "path"
                animation.fromValue = maskLayer.path
                animation.toValue = newPath
                maskLayer.path = newPath
                maskLayer.add(animation, forKey: "path")
            } else {
                maskLayer.path = newPath
            }
        }
        get {
            return super.bounds
        }
    }

    var thumbImageView: UIImageView! // 缩略图视图
    var videoDurationLabel: UILabel! // 视频时长标签

    var assetIdentifier: String!

    override init(frame: CGRect) {

        super.init(frame: frame)

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {

        contentView.backgroundColor = GVC.defaultViewBackgroundColor

        // 添加缩略图视图

        thumbImageView = UIImageView(frame: contentView.bounds)
        thumbImageView.contentMode = .scaleAspectFill
        contentView.addSubview(thumbImageView)

        // 添加视频时长标签

        videoDurationLabel = UILabel()
        videoDurationLabel.isHidden = true
        videoDurationLabel.font = .systemFont(ofSize: ViewLayoutConstants.videoDurationLabelFontSize, weight: .regular)
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

    override func prepareForReuse() {

        super.prepareForReuse()

        thumbImageView.image = nil
    }
}
