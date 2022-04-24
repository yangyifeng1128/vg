///
/// MetaMultipleChoiceOptionTableViewCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class MetaMultipleChoiceOptionTableViewCell: UITableViewCell {

    static let reuseId: String = "MetaMultipleChoiceOptionTableViewCell"

    /// 视图布局常量枚举值
    enum VC {
        static let optionViewBackgroundColor: UIColor = .white
        static let optionViewCornerRadius: CGFloat = 16
        static let optionViewBorderLayerLineWidth: CGFloat = 1
        static let optionViewBorderLayerStrokeColor: UIColor = .lightGray
        static let titleLabelFontSize: CGFloat = 16
        static let titleLabelTextColor: UIColor = .darkText
    }

    var optionView: MetaMultipleChoiceOptionView!
    var titleLabel: UILabel! // 标题标签

    /// 初始化
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // 初始化视图

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = .clear
        selectionStyle = .none

        // 添加选项视图

        optionView = MetaMultipleChoiceOptionView()
        optionView.backgroundColor = VC.optionViewBackgroundColor
        contentView.addSubview(optionView)

        // 添加标题标签

        titleLabel = UILabel()
        titleLabel.textColor = VC.titleLabelTextColor
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        optionView.addSubview(titleLabel)
    }

    /// 准备重用单元格
    override func prepareForReuse() {

        super.prepareForReuse()
    }
}

class MetaMultipleChoiceOptionView: RoundedView {

    var borderLayer: CAShapeLayer!

    /// 初始化
    init() {

        super.init()

        // 初始化视图

        initViews()
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

    /// 初始化视图
    private func initViews() {
    }

    private func addBorderLayer() {

        if borderLayer != nil {
            borderLayer.removeFromSuperlayer()
            borderLayer = nil
        }

        borderLayer = CAShapeLayer()
        borderLayer.lineWidth = MetaMultipleChoiceOptionTableViewCell.VC.optionViewBorderLayerLineWidth
        borderLayer.strokeColor = MetaMultipleChoiceOptionTableViewCell.VC.optionViewBorderLayerStrokeColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.frame = bounds
        borderLayer.path = maskLayer.path

        layer.addSublayer(borderLayer)
    }
}
