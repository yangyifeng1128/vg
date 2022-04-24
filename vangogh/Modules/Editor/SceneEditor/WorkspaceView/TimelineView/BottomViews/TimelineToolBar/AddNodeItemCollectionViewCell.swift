///
/// AddNodeItemCollectionViewCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class AddNodeItemCollectionViewCell: UICollectionViewCell {

    static let reuseId: String = "AddNodeItemCollectionViewCell"

    /// 视图布局常量枚举值
    enum VC {
        static let titleLabelFontSize: CGFloat = 13
    }

    var titleLabel: UILabel!
    var tagView: AddNodeItemTagView!

    override init(frame: CGRect) {

        super.init(frame: frame)

        // 初始化视图

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {

        tagView = AddNodeItemTagView()
        contentView.addSubview(tagView)
        tagView.snp.makeConstraints { make -> Void in
            make.width.equalTo(AddNodeItemTagView.VC.width)
            make.height.equalTo(AddNodeItemTagView.VC.height)
            make.centerX.equalToSuperview().offset(8)
            make.top.equalToSuperview()
        }

        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: VC.titleLabelFontSize, weight: .regular)
        titleLabel.textColor = .mgLabel
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview()
            make.top.equalTo(tagView.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }

    override func prepareForReuse() {

        super.prepareForReuse()
    }
}

class AddNodeItemTagView: UIView {

    /// 视图布局常量枚举值
    enum VC {
        static let width: CGFloat = 40
        static let height: CGFloat = width * 5 / 4
        static let iconViewWidth: CGFloat = 20
    }

    private lazy var maskLayer: CAShapeLayer = {
        self.layer.mask = $0
        return $0
    }(CAShapeLayer())

    override var bounds: CGRect {
        set {
            super.bounds = newValue
            maskLayer.frame = newValue
            let newPath: CGPath = UIBezierPath.waterdrop(width: bounds.width).cgPath
            if let animation = layer.animation(forKey: "bounds.size")?.copy() as? CABasicAnimation {
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

    var iconView: UIImageView!

    init() {

        super.init(frame: .zero)

        tintColor = .mgLabel

        // 初始化视图

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {

        iconView = UIImageView()
        addSubview(iconView)
        iconView.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.iconViewWidth)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset((VC.iconViewWidth - VC.width) / 2)
        }
    }
}
