///
/// GameEditorSceneBottomView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

protocol GameEditorSceneBottomViewDelegate: AnyObject {
    func closeSceneButtonDidTap()
    func deleteSceneButtonDidTap()
    func editSceneTitleButtonDidTap()
    func sceneTitleLabelDidTap()
    func manageTransitionsButtonDidTap()
    func previewSceneButtonDidTap()
    func editSceneButtonDidTap()
    func transitionWillDelete(_ transition: MetaTransition, completion: @escaping () -> Void)
    func transitionDidSelect(_ transition: MetaTransition)
}

class GameEditorSceneBottomView: BorderedView {

    /// 视图布局常量枚举值
    enum VC {
        static let contentViewHeight: CGFloat = {
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                return 336
            case .pad, .mac, .tv, .carPlay, .unspecified:
                return UIScreen.main.bounds.height * 0.4
            @unknown default:
                return 336
            }
        }()
        static let rightTopButtonWidth: CGFloat = 48
        static let sceneTitleLabelFontSize: CGFloat = 16
        static let manageTransitionsButtonWidth: CGFloat = 160
        static let manageTransitionsButtonHeight: CGFloat = /* 32 */ 16
        static let manageTransitionsButtonMinHeight: CGFloat = 8
        static let manageTransitionsButtonTitleLabelFontSize: CGFloat = 14
        static let bottomButtonHeight: CGFloat = 56
        static let bottomButtonTitleLabelFontSize: CGFloat = 18
        static let previewSceneButtonWidth: CGFloat = UIScreen.main.bounds.width * 0.32
        static let transitionTableViewCellHeight: CGFloat = 72
    }

    weak var delegate: GameEditorSceneBottomViewDelegate?

    private var contentView: UIView!
    private var closeSceneButton: UIButton!
    private var deleteSceneButton: UIButton!
    private var editSceneTitleButton: UIButton!
    private var sceneTitleLabel: UILabel!
    private var previewSceneButton: RoundedButton!
    private var editSceneButton: RoundedButton!
    private var transitionsView: RoundedView!
    private var manageTransitionsButton: UIButton!
    private var transitionsTableView: UITableView!

    private var gameBundle: MetaGameBundle!
    private var selectedScene: MetaScene!
    private var transitions: [MetaTransition]!

    init(gameBundle: MetaGameBundle) {

        super.init(side: .top)

        self.gameBundle = gameBundle
        selectedScene = gameBundle.selectedScene()
        transitions = gameBundle.selectedTransitions()

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {

        contentView = UIView()
        contentView.backgroundColor = .systemBackground
        addSubview(contentView)
        contentView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(GameEditorSceneBottomView.VC.contentViewHeight)
            make.left.top.equalToSuperview()
        }

        closeSceneButton = UIButton()
        closeSceneButton.tintColor = .secondaryLabel
        closeSceneButton.setImage(.close, for: .normal)
        closeSceneButton.imageView?.tintColor = .secondaryLabel
        closeSceneButton.addTarget(self, action: #selector(closeSceneButtonDidTap), for: .touchUpInside)
        contentView.addSubview(closeSceneButton)
        closeSceneButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.rightTopButtonWidth)
            make.right.equalToSuperview().offset(-8)
            make.top.equalToSuperview().offset(8)
        }

        deleteSceneButton = UIButton()
        deleteSceneButton.tintColor = .secondaryLabel
        deleteSceneButton.setImage(.delete, for: .normal)
        deleteSceneButton.imageView?.tintColor = .secondaryLabel
        deleteSceneButton.addTarget(self, action: #selector(deleteSceneButtonDidTap), for: .touchUpInside)
        contentView.addSubview(deleteSceneButton)
        deleteSceneButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.rightTopButtonWidth)
            make.right.equalTo(closeSceneButton.snp.left)
            make.top.equalTo(closeSceneButton)
        }

        editSceneTitleButton = UIButton()
        editSceneTitleButton.isHidden = true
        editSceneTitleButton.tintColor = .secondaryLabel
        editSceneTitleButton.setImage(.editNote, for: .normal)
        editSceneTitleButton.imageView?.tintColor = .secondaryLabel
        editSceneTitleButton.addTarget(self, action: #selector(editSceneTitleButtonDidTap), for: .touchUpInside)
        contentView.addSubview(editSceneTitleButton)
        editSceneTitleButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.rightTopButtonWidth)
            make.right.equalTo(deleteSceneButton.snp.left)
            make.top.equalTo(deleteSceneButton)
        }

        sceneTitleLabel = UILabel()
        sceneTitleLabel.attributedText = prepareSceneTitleLabelAttributedText()
        sceneTitleLabel.font = .systemFont(ofSize: VC.sceneTitleLabelFontSize, weight: .regular)
        sceneTitleLabel.numberOfLines = 2
        sceneTitleLabel.lineBreakMode = .byTruncatingTail
        sceneTitleLabel.isUserInteractionEnabled = true
        sceneTitleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sceneTitleLabelDidTap)))
        contentView.addSubview(sceneTitleLabel)
        sceneTitleLabel.snp.makeConstraints { make -> Void in
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(editSceneTitleButton.snp.left).offset(-8)
            make.top.equalTo(closeSceneButton).offset(14)
        }

        previewSceneButton = RoundedButton(cornerRadius: GVC.defaultViewCornerRadius)
        previewSceneButton.backgroundColor = .accent
        previewSceneButton.tintColor = .white
        previewSceneButton.setTitle(NSLocalizedString("Preview", comment: ""), for: .normal)
        previewSceneButton.setTitleColor(.white, for: .normal)
        previewSceneButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        previewSceneButton.titleLabel?.font = .systemFont(ofSize: VC.bottomButtonTitleLabelFontSize, weight: .regular)
        previewSceneButton.setImage(.emulate, for: .normal)
        previewSceneButton.adjustsImageWhenHighlighted = false
        previewSceneButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        previewSceneButton.imageView?.tintColor = .white
        previewSceneButton.addTarget(self, action: #selector(previewSceneButtonDidTap), for: .touchUpInside)
        contentView.addSubview(previewSceneButton)
        previewSceneButton.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.previewSceneButtonWidth)
            make.height.equalTo(VC.bottomButtonHeight)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        editSceneButton = RoundedButton(cornerRadius: GVC.defaultViewCornerRadius)
        editSceneButton.backgroundColor = .secondarySystemBackground
        editSceneButton.tintColor = .mgLabel
        editSceneButton.setTitle(NSLocalizedString("EditScene", comment: ""), for: .normal)
        editSceneButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        editSceneButton.titleLabel?.font = .systemFont(ofSize: VC.bottomButtonTitleLabelFontSize, weight: .regular)
        editSceneButton.setTitleColor(.mgLabel, for: .normal)
        editSceneButton.setImage(.edit, for: .normal)
        editSceneButton.adjustsImageWhenHighlighted = false
        editSceneButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        editSceneButton.imageView?.tintColor = .mgLabel
        editSceneButton.addTarget(self, action: #selector(editSceneButtonDidTap), for: .touchUpInside)
        contentView.addSubview(editSceneButton)
        editSceneButton.snp.makeConstraints { make -> Void in
            make.height.equalTo(VC.bottomButtonHeight)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(previewSceneButton.snp.left).offset(-12)
            make.bottom.equalTo(previewSceneButton)
        }

        transitionsView = RoundedView()
        transitionsView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(transitionsView)
        transitionsView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(sceneTitleLabel.snp.bottom).offset(16)
            make.bottom.equalTo(previewSceneButton.snp.top).offset(-16)
        }

        manageTransitionsButton = UIButton()
        manageTransitionsButton.tintColor = .secondaryLabel
        manageTransitionsButton.contentHorizontalAlignment = .right
        manageTransitionsButton.setTitle(NSLocalizedString("Manage", comment: ""), for: .normal)
        manageTransitionsButton.titleLabel?.font = .systemFont(ofSize: VC.manageTransitionsButtonTitleLabelFontSize, weight: .regular)
        manageTransitionsButton.setTitleColor(.secondaryLabel, for: .normal)
        manageTransitionsButton.setImage(.openInNew, for: .normal)
        manageTransitionsButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 0)
        manageTransitionsButton.imageView?.contentMode = .scaleAspectFit
        manageTransitionsButton.imageView?.tintColor = .secondaryLabel
        manageTransitionsButton.addTarget(self, action: #selector(manageTransitionsButtonDidTap), for: .touchUpInside)
        transitionsView.addSubview(manageTransitionsButton)
        manageTransitionsButton.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.manageTransitionsButtonWidth)
            make.height.equalTo(VC.manageTransitionsButtonHeight)
            make.right.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview()
        }

        transitionsTableView = UITableView()
        transitionsTableView.backgroundColor = .clear
        transitionsTableView.separatorStyle = .none
        transitionsTableView.showsVerticalScrollIndicator = false
        transitionsTableView.alwaysBounceVertical = false
        transitionsTableView.register(GameEditorTransitionTableViewCell.self, forCellReuseIdentifier: GameEditorTransitionTableViewCell.reuseId)
        transitionsTableView.dataSource = self
        transitionsTableView.delegate = self
        transitionsView.addSubview(transitionsTableView)
        transitionsTableView.snp.makeConstraints { make -> Void in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(VC.manageTransitionsButtonMinHeight)
            make.bottom.equalTo(manageTransitionsButton.snp.top)
        }
    }

    private func prepareSceneTitleLabelAttributedText() -> NSMutableAttributedString {

        let completeTitleString: NSMutableAttributedString = NSMutableAttributedString(string: "")

        // 准备场景索引

        let indexStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.secondaryLabel]
        let indexString: NSAttributedString = NSAttributedString(string: NSLocalizedString("Scene", comment: "") + " " + selectedScene.index.description + "  ", attributes: indexStringAttributes)
        completeTitleString.append(indexString)

        // 准备场景标题

        let titleStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.mgLabel!]
        var titleString: NSAttributedString
        if let title = selectedScene.title, !title.isEmpty {
            titleString = NSAttributedString(string: title, attributes: titleStringAttributes)
        } else {
            titleString = NSAttributedString(string: NSLocalizedString("Untitled", comment: ""), attributes: titleStringAttributes)
        }
        completeTitleString.append(titleString)

        // 准备段落样式

        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        completeTitleString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, completeTitleString.length))

        return completeTitleString
    }
}

extension GameEditorSceneBottomView: UITableViewDataSource {

    /// 设置单元格数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if transitions.isEmpty {

            manageTransitionsButton.snp.updateConstraints { make -> Void in
                make.height.equalTo(VC.manageTransitionsButtonMinHeight)
            }
            manageTransitionsButton.isHidden = true

            transitionsTableView.showNoDataInfo(title: NSLocalizedString("NoTransitionsAvailable", comment: ""), oops: false)
            transitionsView.isHidden = true

        } else {

            manageTransitionsButton.snp.updateConstraints { make -> Void in
                make.height.equalTo(VC.manageTransitionsButtonHeight)
            }
            // manageTransitionsButton.isHidden = false
            manageTransitionsButton.isHidden = true

            transitionsTableView.hideNoDataInfo()

        }

        return transitions.count
    }

    /// 设置单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = transitionsTableView.dequeueReusableCell(withIdentifier: GameEditorTransitionTableViewCell.reuseId) as? GameEditorTransitionTableViewCell else {
            fatalError("Unexpected cell type")
        }

        guard let startScene = gameBundle.selectedScene() else {
            fatalError("Unexpected start scene")
        }
        guard let endScene = gameBundle.findScene(index: transitions[indexPath.row].to) else {
            fatalError("Unexpected end scene")
        }

        // 准备条件视图

        cell.conditionsTitleLabel.attributedText = prepareConditionsTitleLabelAttributedText(startScene: startScene, conditions: transitions[indexPath.row].conditions)

        // 准备缩略图视图

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let s = self else { return }
            if let thumbImage = MetaThumbManager.shared.loadSceneThumbImage(sceneUUID: endScene.uuid, gameUUID: s.gameBundle.uuid) {
                DispatchQueue.main.async {
                    cell.endSceneThumbImageView.image = thumbImage
                }
            } else {
                DispatchQueue.main.async {
                    cell.endSceneThumbImageView.image = .sceneBackgroundThumb
                }
            }
        }

        // 准备「结束场景」标题标签

        cell.endSceneTitleLabel.attributedText = prepareEndSceneTitleLabelAttributedText(endScene: endScene)
        cell.endSceneTitleLabel.textAlignment = .center
        cell.endSceneTitleLabel.numberOfLines = 3
        cell.endSceneTitleLabel.lineBreakMode = .byTruncatingTail

        // 准备删除按钮

        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(transitionWillDelete), for: .touchUpInside)

        return cell
    }

    private func prepareConditionsTitleLabelAttributedText(startScene: MetaScene, conditions: [MetaCondition]) -> NSMutableAttributedString {

        let completeConditionsTitleString: NSMutableAttributedString = NSMutableAttributedString(string: "")

        for (i, condition) in conditions.enumerated() {

            let conditionTitleString = prepareConditionTitleLabelAttributedText(startScene: startScene, condition: condition)
            completeConditionsTitleString.append(conditionTitleString)

            if i < conditions.count - 1 {
                let orStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.tertiaryLabel]
                let orString = NSAttributedString(string: " " + NSLocalizedString("Or", comment: "") + " ", attributes: orStringAttributes)
                completeConditionsTitleString.append(orString)
            }
        }

        return completeConditionsTitleString
    }

    private func prepareConditionTitleLabelAttributedText(startScene: MetaScene, condition: MetaCondition) -> NSMutableAttributedString {

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

    private func prepareEndSceneTitleLabelAttributedText(endScene: MetaScene) -> NSMutableAttributedString {

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

        return completeTitleString
    }
}

extension GameEditorSceneBottomView: UITableViewDelegate {

    /// 设置单元格高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return VC.transitionTableViewCellHeight
    }

    /// 选中单元格
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        delegate?.transitionDidSelect(transitions[indexPath.row])
    }
}

extension GameEditorSceneBottomView {

    @objc private func closeSceneButtonDidTap() {

        delegate?.closeSceneButtonDidTap()
    }

    @objc private func deleteSceneButtonDidTap() {

        delegate?.deleteSceneButtonDidTap()
    }

    @objc private func editSceneTitleButtonDidTap() {

        delegate?.editSceneTitleButtonDidTap()
    }

    @objc private func sceneTitleLabelDidTap() {

        delegate?.sceneTitleLabelDidTap()
    }

    @objc private func manageTransitionsButtonDidTap() {

        delegate?.manageTransitionsButtonDidTap()
    }

    @objc private func previewSceneButtonDidTap() {

        delegate?.previewSceneButtonDidTap()
    }

    @objc private func editSceneButtonDidTap() {

        delegate?.editSceneButtonDidTap()
    }

    @objc private func transitionWillDelete(sender: UIButton) {

        let index = sender.tag
        let transition = transitions[index]

        delegate?.transitionWillDelete(transition, completion: { [weak self] in

            guard let s = self else { return }

            // 重新加载穿梭器

            s.transitions = s.gameBundle.selectedTransitions()
            s.transitionsTableView.reloadData()
        })
    }
}
