///
/// MetaVoteOptionTableViewCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class MetaVoteOptionTableViewCell: UITableViewCell {

    static let reuseId: String = "MetaVoteOptionTableViewCell"

    /// 视图布局常量枚举值
    enum ViewLayoutConstants {
        static let optionViewBackgroundColor: UIColor = .white
        static let optionViewCornerRadius: CGFloat = 16
        static let optionViewBorderLayerLineWidth: CGFloat = 1
        static let optionViewBorderLayerStrokeColor: UIColor = .lightGray
        static let titleLabelFontSize: CGFloat = 16
        static let titleLabelTextColor: UIColor = .darkText
    }

    var optionView: MetaVoteOptionView!
    var titleLabel: UILabel! // 标题标签

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

        // 添加选项视图

        optionView = MetaVoteOptionView()
        optionView.backgroundColor = ViewLayoutConstants.optionViewBackgroundColor
        contentView.addSubview(optionView)

        // 添加标题标签

        titleLabel = UILabel()
        titleLabel.textColor = ViewLayoutConstants.titleLabelTextColor
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        optionView.addSubview(titleLabel)
    }

    override func prepareForReuse() {

        super.prepareForReuse()
    }
}

class MetaVoteOptionView: RoundedView {

    var borderLayer: CAShapeLayer!

    init() {

        super.init()

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {

        // addBorderLayer()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)

        // addBorderLayer()
    }

    private func initSubviews() {
    }

    private func addBorderLayer() {

        if borderLayer != nil {
            borderLayer.removeFromSuperlayer()
            borderLayer = nil
        }

        borderLayer = CAShapeLayer()
        borderLayer.lineWidth = MetaVoteOptionTableViewCell.ViewLayoutConstants.optionViewBorderLayerLineWidth
        borderLayer.strokeColor = MetaVoteOptionTableViewCell.ViewLayoutConstants.optionViewBorderLayerStrokeColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.frame = bounds
        borderLayer.path = maskLayer.path

        layer.addSublayer(borderLayer)
    }
}
