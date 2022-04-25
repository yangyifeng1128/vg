///
/// TemplateCollectionViewCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class TemplateCollectionViewCell: UICollectionViewCell {

    static let reuseId: String = "TemplateCollectionViewCell"

    /// 视图布局常量枚举值
    enum VC {
        static let titleLabelHeight: CGFloat = 48
        static let titleLabelFontSize: CGFloat = 13
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
    var titleLabel: AttributedLabel! // 标题标签

    override init(frame: CGRect) {

        super.init(frame: frame)

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {

        contentView.backgroundColor = GVC.defaultViewBackgroundColor

        // 添加缩略图视图

        thumbImageView = UIImageView(frame: contentView.bounds)
        contentView.addSubview(thumbImageView)

        // 添加标题标签

        titleLabel = AttributedLabel()
        titleLabel.insets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 4)
        titleLabel.backgroundColor = .secondarySystemGroupedBackground
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
