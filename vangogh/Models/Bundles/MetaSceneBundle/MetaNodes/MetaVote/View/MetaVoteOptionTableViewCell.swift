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
    enum VC {
        static let optionViewBackgroundColor: UIColor = .white
        static let optionViewCornerRadius: CGFloat = 16
        static let optionViewBorderLayerLineWidth: CGFloat = 1
        static let optionViewBorderLayerStrokeColor: UIColor = .lightGray
        static let titleLabelFontSize: CGFloat = 16
        static let titleLabelTextColor: UIColor = .darkText
    }

    /// 选项视图
    var optionView: MetaVoteOptionView!
    /// 标题标签
    var titleLabel: UILabel!

    /// 初始化
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = .clear
        selectionStyle = .none

        // 添加「选项视图」

        optionView = MetaVoteOptionView()
        optionView.backgroundColor = VC.optionViewBackgroundColor
        contentView.addSubview(optionView)

        // 添加「标题标签」

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

class MetaVoteOptionView: RoundedView {

    /// 边框图层
    var borderLayer: CAShapeLayer!

    /// 初始化
    init() {

        super.init()

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 重写布局子视图方法
    override func layoutSubviews() {

        // addBorderLayer()
    }

    /// 重写用户界面风格变化处理方法
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)

        // addBorderLayer()
    }

    /// 初始化视图
    private func initViews() {
    }

    /// 添加边框图层
    private func addBorderLayer() {

        if borderLayer != nil {
            borderLayer.removeFromSuperlayer()
            borderLayer = nil
        }

        borderLayer = CAShapeLayer()
        borderLayer.lineWidth = MetaVoteOptionTableViewCell.VC.optionViewBorderLayerLineWidth
        borderLayer.strokeColor = MetaVoteOptionTableViewCell.VC.optionViewBorderLayerStrokeColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.frame = bounds
        borderLayer.path = maskLayer.path

        layer.addSublayer(borderLayer)
    }
}
