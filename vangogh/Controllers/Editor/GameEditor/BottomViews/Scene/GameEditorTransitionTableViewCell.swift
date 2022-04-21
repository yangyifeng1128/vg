///
/// GameEditorTransitionTableViewCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class GameEditorTransitionTableViewCell: UITableViewCell {

    static let reuseId: String = "GameEditorTransitionTableViewCell"

    // 视图布局常量枚举值

    enum ViewLayoutConstants {
        static let ifLabelFontSize: CGFloat = 14
        static let deleteButtonWidth: CGFloat = 44
        static let endSceneTitleLabelSmallFontSize: CGFloat = 10
        static let endSceneTitleLabelLargeFontSize: CGFloat = 18
        static let arrowViewWidth: CGFloat = 40
        static let conditionsTitleLabelFontSize: CGFloat = 14
    }

    private var ifLabel: UILabel! // IF 标签
    var deleteButton: UIButton! // 删除按钮
    var endSceneThumbImageView: RoundedImageView! // 缩略图视图
    var endSceneTitleLabel: AttributedLabel! // 「结束场景」标题标签
    private var arrowView: ArrowView! // 箭头视图
    private var conditionsView: RoundedView! // 条件视图
    var conditionsTitleLabel: AttributedLabel! // 条件标题标签

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

        // 添加 IF 视图

        ifLabel = UILabel()
        ifLabel.text = NSLocalizedString("If", comment: "")
        ifLabel.font = .systemFont(ofSize: ViewLayoutConstants.ifLabelFontSize, weight: .regular)
        ifLabel.textColor = .secondaryLabel
        contentView.addSubview(ifLabel)
        ifLabel.snp.makeConstraints { make -> Void in
            make.height.equalToSuperview()
            make.left.equalToSuperview().offset(8)
            make.top.equalToSuperview()
        }

        // 添加删除按钮

        deleteButton = UIButton()
        deleteButton.tintColor = .tertiaryLabel
        deleteButton.setImage(.delete, for: .normal)
        deleteButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 10)
        deleteButton.imageView?.contentMode = .scaleAspectFit
        deleteButton.imageView?.tintColor = .tertiaryLabel
        contentView.addSubview(deleteButton)
        let deleteButtonHeight: CGFloat = GameEditorSceneBottomView.ViewLayoutConstants.transitionTableViewCellHeight - 16
        deleteButton.snp.makeConstraints { make -> Void in
            make.width.equalTo(ViewLayoutConstants.deleteButtonWidth)
            make.height.equalTo(deleteButtonHeight)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }

        // 添加缩略图视图

        endSceneThumbImageView = RoundedImageView(cornerRadius: GlobalViewLayoutConstants.defaultViewCornerRadius)
        endSceneThumbImageView.contentMode = .scaleAspectFill
        contentView.addSubview(endSceneThumbImageView)
        let thumbImageViewHeight: CGFloat = GameEditorSceneBottomView.ViewLayoutConstants.transitionTableViewCellHeight - 16
        let thumbImageViewWidth: CGFloat = thumbImageViewHeight * GlobalViewLayoutConstants.defaultSceneAspectRatio
        endSceneThumbImageView.snp.makeConstraints { make -> Void in
            make.width.equalTo(thumbImageViewWidth)
            make.height.equalTo(thumbImageViewHeight)
            make.centerY.equalToSuperview()
            make.right.equalTo(deleteButton.snp.left)
        }

        endSceneTitleLabel = AttributedLabel()
        endSceneTitleLabel.insets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        endSceneTitleLabel.textColor = .white
        endSceneTitleLabel.textAlignment = .center
        endSceneTitleLabel.numberOfLines = 3
        endSceneTitleLabel.lineBreakMode = .byTruncatingTail
        endSceneTitleLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        endSceneTitleLabel.layer.shadowOpacity = 1
        endSceneTitleLabel.layer.shadowRadius = 0
        endSceneTitleLabel.layer.shadowColor = UIColor.black.cgColor
        endSceneThumbImageView.addSubview(endSceneTitleLabel)
        endSceneTitleLabel.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        // 添加箭头视图

        arrowView = ArrowView(direction: .right, arrowLayerColor: UIColor.accent?.cgColor)
        contentView.addSubview(arrowView)
        arrowView.snp.makeConstraints { make -> Void in
            make.width.equalTo(ViewLayoutConstants.arrowViewWidth)
            make.height.equalToSuperview()
            make.right.equalTo(endSceneThumbImageView.snp.left).offset(-8)
            make.top.equalToSuperview()
        }

        // 添加条件视图

        conditionsView = RoundedView()
        conditionsView.backgroundColor = .tertiarySystemBackground
        contentView.addSubview(conditionsView)
        let conditionsViewHeight: CGFloat = GameEditorSceneBottomView.ViewLayoutConstants.transitionTableViewCellHeight - 16
        conditionsView.snp.makeConstraints { make -> Void in
            make.height.equalTo(conditionsViewHeight)
            make.centerY.equalToSuperview()
            make.left.equalTo(ifLabel.snp.right).offset(4)
            make.right.equalTo(arrowView.snp.left).offset(-8)
        }

        conditionsTitleLabel = AttributedLabel()
        conditionsTitleLabel.insets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        conditionsTitleLabel.font = .systemFont(ofSize: ViewLayoutConstants.conditionsTitleLabelFontSize, weight: .regular)
        conditionsTitleLabel.textColor = .mgLabel
        conditionsTitleLabel.numberOfLines = 2
        conditionsTitleLabel.lineBreakMode = .byCharWrapping
        conditionsView.addSubview(conditionsTitleLabel)
        conditionsTitleLabel.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }
    }

    override func prepareForReuse() {

        super.prepareForReuse()

        endSceneThumbImageView.image = nil
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)

        arrowView.arrowLayerColor = UIColor.accent?.cgColor
        arrowView.updateView()
    }
}
