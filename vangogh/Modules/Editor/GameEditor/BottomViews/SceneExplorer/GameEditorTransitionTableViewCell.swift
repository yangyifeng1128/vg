///
/// GameEditorTransitionTableViewCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class GameEditorTransitionTableViewCell: UITableViewCell {

    static let reuseId: String = "GameEditorTransitionTableViewCell"

    /// 视图布局常量枚举值
    enum VC {
        static let ifLabelFontSize: CGFloat = 14
        static let deleteButtonWidth: CGFloat = 44
        static let endSceneTitleLabelSmallFontSize: CGFloat = 10
        static let endSceneTitleLabelLargeFontSize: CGFloat = 18
        static let arrowViewWidth: CGFloat = 40
        static let conditionsTitleLabelFontSize: CGFloat = 14
    }

    /// 删除按钮
    var deleteButton: UIButton!
    /// 缩略图视图
    var endSceneThumbImageView: RoundedImageView!
    /// 结束场景标题标签
    var endSceneTitleLabel: AttributedLabel!
    /// 箭头视图
    var arrowView: ArrowView!
    /// 条件标题标签
    var conditionsTitleLabel: AttributedLabel!

    /// 初始化
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 重写用户界面风格变化处理方法
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)

        arrowView.arrowLayerColor = UIColor.accent?.cgColor
        arrowView.updateView()
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = .clear
        selectionStyle = .none

        // 初始化「if 标签」

        let ifLabel: UILabel = UILabel()
        ifLabel.text = NSLocalizedString("If", comment: "")
        ifLabel.font = .systemFont(ofSize: VC.ifLabelFontSize, weight: .regular)
        ifLabel.textColor = .secondaryLabel
        contentView.addSubview(ifLabel)
        ifLabel.snp.makeConstraints { make -> Void in
            make.height.equalToSuperview()
            make.left.equalToSuperview().offset(8)
            make.top.equalToSuperview()
        }

        // 初始化「删除按钮」

        deleteButton = UIButton()
        deleteButton.tintColor = .tertiaryLabel
        deleteButton.setImage(.delete, for: .normal)
        deleteButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 10)
        deleteButton.imageView?.contentMode = .scaleAspectFit
        deleteButton.imageView?.tintColor = .tertiaryLabel
        contentView.addSubview(deleteButton)
        let deleteButtonHeight: CGFloat = GameEditorSceneExplorerView.VC.transitionTableViewCellHeight - 16
        deleteButton.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.deleteButtonWidth)
            make.height.equalTo(deleteButtonHeight)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }

        // 初始化「缩略图视图」

        endSceneThumbImageView = RoundedImageView()
        endSceneThumbImageView.contentMode = .scaleAspectFill
        contentView.addSubview(endSceneThumbImageView)
        let thumbImageViewHeight: CGFloat = GameEditorSceneExplorerView.VC.transitionTableViewCellHeight - 16
        let thumbImageViewWidth: CGFloat = thumbImageViewHeight * GVC.defaultSceneAspectRatio
        endSceneThumbImageView.snp.makeConstraints { make -> Void in
            make.width.equalTo(thumbImageViewWidth)
            make.height.equalTo(thumbImageViewHeight)
            make.centerY.equalToSuperview()
            make.right.equalTo(deleteButton.snp.left)
        }

        // 初始化「结束场景标题标签」

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

        // 初始化「箭头视图」

        arrowView = ArrowView(direction: .right, arrowLayerColor: UIColor.accent?.cgColor)
        contentView.addSubview(arrowView)
        arrowView.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.arrowViewWidth)
            make.height.equalToSuperview()
            make.right.equalTo(endSceneThumbImageView.snp.left).offset(-8)
            make.top.equalToSuperview()
        }

        // 初始化「条件视图」

        let conditionsView: RoundedView = RoundedView()
        conditionsView.backgroundColor = .tertiarySystemBackground
        contentView.addSubview(conditionsView)
        let conditionsViewHeight: CGFloat = GameEditorSceneExplorerView.VC.transitionTableViewCellHeight - 16
        conditionsView.snp.makeConstraints { make -> Void in
            make.height.equalTo(conditionsViewHeight)
            make.centerY.equalToSuperview()
            make.left.equalTo(ifLabel.snp.right).offset(4)
            make.right.equalTo(arrowView.snp.left).offset(-8)
        }

        // 初始化「条件标题标签」

        conditionsTitleLabel = AttributedLabel()
        conditionsTitleLabel.insets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        conditionsTitleLabel.font = .systemFont(ofSize: VC.conditionsTitleLabelFontSize, weight: .regular)
        conditionsTitleLabel.textColor = .mgLabel
        conditionsTitleLabel.numberOfLines = 2
        conditionsTitleLabel.lineBreakMode = .byCharWrapping
        conditionsView.addSubview(conditionsTitleLabel)
        conditionsTitleLabel.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }
    }

    /// 准备重用单元格
    override func prepareForReuse() {

        super.prepareForReuse()

        endSceneThumbImageView.image = nil
    }
}

extension GameEditorTransitionTableViewCell {

    /// 准备「条件标题标签」文本
    func prepareConditionsTitleLabelAttributedText(startScene: MetaScene, conditions: [MetaCondition]) {

        let completeConditionsTitleString: NSMutableAttributedString = NSMutableAttributedString(string: "")

        for (i, condition) in conditions.enumerated() {

            let conditionTitleString = prepareConditionAttributedText(startScene: startScene, condition: condition)
            completeConditionsTitleString.append(conditionTitleString)

            if i < conditions.count - 1 {
                let orStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.tertiaryLabel]
                let orString = NSAttributedString(string: " " + NSLocalizedString("Or", comment: "") + " ", attributes: orStringAttributes)
                completeConditionsTitleString.append(orString)
            }
        }

        conditionsTitleLabel.attributedText = completeConditionsTitleString
    }

    /// 准备条件文本
    private func prepareConditionAttributedText(startScene: MetaScene, condition: MetaCondition) -> NSMutableAttributedString {

        let completeConditionTitleString: NSMutableAttributedString = NSMutableAttributedString(string: "")

        // 准备「点」

        let dotStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.mgLabel!, .font: UIFont.systemFont(ofSize: GameEditorTransitionTableViewCell.VC.conditionsTitleLabelFontSize, weight: .semibold)]
        let dotString: NSAttributedString = NSAttributedString(string: NSLocalizedString("Dot", comment: ""), attributes: dotStringAttributes)

        // 准备「开始场景」

        let startSceneTitleStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.mgLabel!]
        let startSceneTitleString: NSAttributedString = NSAttributedString(string: NSLocalizedString("Scene", comment: "") + " " + startScene.index.description, attributes: startSceneTitleStringAttributes)
        completeConditionTitleString.append(startSceneTitleString)
        completeConditionTitleString.append(dotString)

        // FIXME：重新处理「MetaTransition - MetaCondition」

        // 准备「组件」

//        if let conditionDescriptor = MetaConditionDescriptorManager.shared.load(nodeType: condition.nodeType, nodeBehaviorType: condition.nodeBehaviorType) {

        // 准备组件标题

        let nodeTitleStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.accent!]
        let nodeTitle: String = "node type"
//        if condition.nodeIndex == 0 {
//            nodeTitle = conditionDescriptor.nodeTypeAlias
//        } else {
//            nodeTitle = conditionDescriptor.nodeTypeAlias + " " + condition.nodeIndex.description
//        }
        let nodeTitleString: NSAttributedString = NSAttributedString(string: nodeTitle, attributes: nodeTitleStringAttributes)
        completeConditionTitleString.append(nodeTitleString)
        completeConditionTitleString.append(dotString)

        // 准备组件行为标题

        let nodeBehaviorTitleStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.mgLabel!]
        let nodeBehaviorTitleString: NSAttributedString = NSAttributedString(string: /* conditionDescriptor.nodeBehaviorTypeAlias */ "action key", attributes: nodeBehaviorTitleStringAttributes)
        completeConditionTitleString.append(nodeBehaviorTitleString)

        // 准备参数

//        let parametersTitleStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.secondaryLabel]
//        var parametersTitle: String = ""
//        if let parameters = condition.parameters {
//            parametersTitle.append(" " + parameters)
//            let parametersTitleString: NSAttributedString = NSAttributedString(string: parametersTitle, attributes: parametersTitleStringAttributes)
//            completeConditionTitleString.append(parametersTitleString)
//        }
//        }

        return completeConditionTitleString
    }

    /// 准备「结束场景标题标签」文本
    func prepareEndSceneTitleLabelAttributedText(endScene: MetaScene) {

        let completeTitleString: NSMutableAttributedString = NSMutableAttributedString(string: "")

        // 准备场景索引

        let indexStringAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: GameEditorTransitionTableViewCell.VC.endSceneTitleLabelLargeFontSize, weight: .regular)]
        let indexString: NSAttributedString = NSAttributedString(string: endScene.index.description, attributes: indexStringAttributes)
        completeTitleString.append(indexString)

        // 准备场景标题

        let titleStringAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: GameEditorTransitionTableViewCell.VC.endSceneTitleLabelSmallFontSize, weight: .regular)]
        var titleString: NSAttributedString
        if let title = endScene.title, !title.isEmpty {
            titleString = NSAttributedString(string: "\n" + title, attributes: titleStringAttributes)
            completeTitleString.append(titleString)
        }

        // 准备段落样式

        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        completeTitleString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, completeTitleString.length))

        // 设置文本

        endSceneTitleLabel.attributedText = completeTitleString
        endSceneTitleLabel.textAlignment = .center
        endSceneTitleLabel.numberOfLines = 3
        endSceneTitleLabel.lineBreakMode = .byTruncatingTail
    }
}
