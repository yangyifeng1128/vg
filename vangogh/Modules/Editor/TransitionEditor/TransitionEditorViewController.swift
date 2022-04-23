///
/// TransitionEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class TransitionEditorViewController: UIViewController {

    /// 视图布局常量枚举值
    enum ViewLayoutConstants {
        static let topButtonContainerWidth: CGFloat = 64
        static let topButtonContainerPadding: CGFloat = 12
        static let titleLabelFontSize: CGFloat = 16
        static let diagramViewHeight: CGFloat = 136
        static let diagramArrowViewWidth: CGFloat = 40
        static let diagramArrowViewHeight: CGFloat = 64
        static let diagramSceneViewWidth: CGFloat = 48
        static let diagramSceneViewHeight: CGFloat = 64
        static let diagramSceneViewTopOffset: CGFloat = 16
        static let diagramSceneIndexLabelFontSize: CGFloat = 20
        static let diagramSceneTitleLabelWidth: CGFloat = 112
        static let diagramSceneTitleLabelHeight: CGFloat = 32
        static let diagramSceneTitleLabelFontSize: CGFloat = 13
        static let addConditionButtonHeight: CGFloat = 56
        static let addConditionButtonTitleLabelFontSize: CGFloat = 16
        static let conditionsTitleLabelFontSize: CGFloat = 16
        static let conditionsTitleLabelIconWidth: CGFloat = 18
        static let conditionTableViewCellHeight: CGFloat = 96
    }

    private var backButtonContainer: UIView!
    private var backButton: CircleNavigationBarButton!
    private var titleLabel: UILabel!

    private var diagramView: RoundedView! // 示意图视图
    private var arrowView: ArrowView! // 箭头视图
    private var addConditionButton: RoundedButton! // 「添加条件」按钮
    private var conditionsView: UIView! // 条件视图
    private var conditionsTableView: UITableView! // 条件表格视图

    private var gameBundle: MetaGameBundle!
    private var transition: MetaTransition!
    private var startScene: MetaScene!
    private var endScene: MetaScene!
    private var conditions: [MetaCondition]!

    init() {

        super.init(nibName: nil, bundle: nil)
    }

    init(gameBundle: MetaGameBundle, transition: MetaTransition) {

        super.init(nibName: nil, bundle: nil)

        self.gameBundle = gameBundle

        self.transition = transition
        self.conditions = transition.conditions

        self.startScene = gameBundle.findScene(index: transition.from)
        self.endScene = gameBundle.findScene(index: transition.to)
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    //
    //
    // MARK: - 视图生命周期
    //
    //

    override func viewDidLoad() {

        super.viewDidLoad()

        // 初始化子视图

        initSubviews()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)

        arrowView.arrowLayerColor = UIColor.secondaryLabel.cgColor
        arrowView.updateView()
    }

    private func initSubviews() {

        view.backgroundColor = .systemGroupedBackground

        // 初始化导航栏

        initNavigationBar()

        // 初始化示意图视图

        initDiagramView()

        // 初始化「添加条件」按钮

        initAddConditionButton()

        // 初始化条件视图

        initConditionsView()
    }

    private func initNavigationBar() {

        // 初始化返回按钮

        backButtonContainer = UIView()
        backButtonContainer.backgroundColor = .clear
        backButtonContainer.isUserInteractionEnabled = true
        backButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backButtonDidTap)))
        view.addSubview(backButtonContainer)
        backButtonContainer.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(ViewLayoutConstants.topButtonContainerWidth)
            make.left.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        backButton = CircleNavigationBarButton(icon: .arrowBack)
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        backButtonContainer.addSubview(backButton)
        backButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.ViewLayoutConstants.width)
            make.right.bottom.equalToSuperview().offset(-ViewLayoutConstants.topButtonContainerPadding)
        }

        // 初始化标题标签

        titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("EditTransition", comment: "")
        titleLabel.font = .systemFont(ofSize: ViewLayoutConstants.titleLabelFontSize, weight: .regular)
        titleLabel.textColor = .mgLabel
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.centerY.equalTo(backButton)
            make.left.equalTo(backButtonContainer.snp.right).offset(8)
        }
    }

    private func initDiagramView() {

        // 初始化示意图视图

        diagramView = RoundedView()
        diagramView.backgroundColor = .systemGroupedBackground
        view.addSubview(diagramView)
        diagramView.snp.makeConstraints { make -> Void in
            make.height.equalTo(ViewLayoutConstants.diagramViewHeight)
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(backButtonContainer.snp.bottom).offset(24)
        }

        arrowView = ArrowView()
        diagramView.addSubview(arrowView)
        arrowView.snp.makeConstraints { make -> Void in
            make.width.equalTo(ViewLayoutConstants.diagramArrowViewWidth)
            make.height.equalTo(ViewLayoutConstants.diagramArrowViewHeight)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(ViewLayoutConstants.diagramSceneViewTopOffset + ViewLayoutConstants.diagramSceneViewHeight / 2 - ViewLayoutConstants.diagramArrowViewHeight / 2)
        }

        let startSceneView: RoundedImageView = RoundedImageView(cornerRadius: GlobalViewLayoutConstants.defaultViewCornerRadius)
        startSceneView.contentMode = .scaleAspectFill
        startSceneView.image = .sceneBackgroundThumb
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            if let thumbImage = MetaThumbManager.shared.loadSceneThumbImage(sceneUUID: strongSelf.startScene.uuid, gameUUID: strongSelf.gameBundle.uuid) {
                DispatchQueue.main.async {
                    startSceneView.image = thumbImage
                }
            }
        }
        diagramView.addSubview(startSceneView)
        startSceneView.snp.makeConstraints { make -> Void in
            make.width.equalTo(ViewLayoutConstants.diagramSceneViewWidth)
            make.height.equalTo(ViewLayoutConstants.diagramSceneViewHeight)
            make.right.equalTo(arrowView.snp.left).offset(-24)
            make.top.equalToSuperview().offset(ViewLayoutConstants.diagramSceneViewTopOffset)
        }
        let startSceneIndexLabel = UILabel()
        startSceneIndexLabel.text = startScene.index.description
        startSceneIndexLabel.font = .systemFont(ofSize: ViewLayoutConstants.diagramSceneIndexLabelFontSize, weight: .regular)
        startSceneIndexLabel.textColor = .white
        startSceneIndexLabel.textAlignment = .center
        startSceneIndexLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        startSceneIndexLabel.layer.shadowOpacity = 1
        startSceneIndexLabel.layer.shadowRadius = 0
        startSceneIndexLabel.layer.shadowColor = UIColor.black.cgColor
        startSceneView.addSubview(startSceneIndexLabel)
        startSceneIndexLabel.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }
        let startSceneTitleLabel: UILabel = UILabel()
        let startSceneIndexString: String = NSLocalizedString("Scene", comment: "") + " " + startScene.index.description
        var startSceneTitleString: String
        if let title = startScene.title, !title.isEmpty {
            startSceneTitleString = title
        } else {
            startSceneTitleString = startSceneIndexString
        }
        startSceneTitleLabel.text = startSceneTitleString
        startSceneTitleLabel.font = .systemFont(ofSize: ViewLayoutConstants.diagramSceneTitleLabelFontSize, weight: .regular)
        startSceneTitleLabel.textColor = .secondaryLabel
        startSceneTitleLabel.textAlignment = .center
        startSceneTitleLabel.numberOfLines = 2
        startSceneTitleLabel.lineBreakMode = .byTruncatingTail
        diagramView.addSubview(startSceneTitleLabel)
        startSceneTitleLabel.snp.makeConstraints { make -> Void in
            make.width.equalTo(ViewLayoutConstants.diagramSceneTitleLabelWidth)
            make.height.equalTo(ViewLayoutConstants.diagramSceneTitleLabelHeight)
            make.centerX.equalTo(startSceneView)
            make.top.equalTo(startSceneView.snp.bottom).offset(8)
        }

        let endSceneView: RoundedImageView = RoundedImageView(cornerRadius: GlobalViewLayoutConstants.defaultViewCornerRadius)
        endSceneView.contentMode = .scaleAspectFill
        endSceneView.image = .sceneBackgroundThumb
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            if let thumbImage = MetaThumbManager.shared.loadSceneThumbImage(sceneUUID: strongSelf.endScene.uuid, gameUUID: strongSelf.gameBundle.uuid) {
                DispatchQueue.main.async {
                    endSceneView.image = thumbImage
                }
            }
        }
        diagramView.addSubview(endSceneView)
        endSceneView.snp.makeConstraints { make -> Void in
            make.width.equalTo(ViewLayoutConstants.diagramSceneViewWidth)
            make.height.equalTo(ViewLayoutConstants.diagramSceneViewHeight)
            make.top.equalToSuperview().offset(16)
            make.left.equalTo(arrowView.snp.right).offset(24)
        }
        let endSceneIndexLabel = UILabel()
        endSceneIndexLabel.text = endScene.index.description
        endSceneIndexLabel.font = .systemFont(ofSize: ViewLayoutConstants.diagramSceneIndexLabelFontSize, weight: .regular)
        endSceneIndexLabel.textColor = .white
        endSceneIndexLabel.textAlignment = .center
        endSceneIndexLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        endSceneIndexLabel.layer.shadowOpacity = 1
        endSceneIndexLabel.layer.shadowRadius = 0
        endSceneIndexLabel.layer.shadowColor = UIColor.black.cgColor
        endSceneView.addSubview(endSceneIndexLabel)
        endSceneIndexLabel.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }
        let endSceneTitleLabel: UILabel = UILabel()
        let endSceneIndexString: String = NSLocalizedString("Scene", comment: "") + " " + endScene.index.description
        var endSceneTitleString: String
        if let title = endScene.title, !title.isEmpty {
            endSceneTitleString = title
        } else {
            endSceneTitleString = endSceneIndexString
        }
        endSceneTitleLabel.text = endSceneTitleString
        endSceneTitleLabel.font = .systemFont(ofSize: ViewLayoutConstants.diagramSceneTitleLabelFontSize, weight: .regular)
        endSceneTitleLabel.textColor = .secondaryLabel
        endSceneTitleLabel.textAlignment = .center
        endSceneTitleLabel.numberOfLines = 2
        endSceneTitleLabel.lineBreakMode = .byTruncatingTail
        diagramView.addSubview(endSceneTitleLabel)
        endSceneTitleLabel.snp.makeConstraints { make -> Void in
            make.width.equalTo(ViewLayoutConstants.diagramSceneTitleLabelWidth)
            make.height.equalTo(ViewLayoutConstants.diagramSceneTitleLabelHeight)
            make.centerX.equalTo(endSceneView)
            make.top.equalTo(endSceneView.snp.bottom).offset(8)
        }
    }

    private func initAddConditionButton() {

        addConditionButton = RoundedButton(cornerRadius: GlobalViewLayoutConstants.defaultViewCornerRadius)
        addConditionButton.backgroundColor = .secondarySystemGroupedBackground
        addConditionButton.tintColor = .mgLabel
        addConditionButton.setTitle(NSLocalizedString("AddCondition", comment: ""), for: .normal)
        addConditionButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        addConditionButton.titleLabel?.font = .systemFont(ofSize: ViewLayoutConstants.addConditionButtonTitleLabelFontSize, weight: .regular)
        addConditionButton.setTitleColor(.mgLabel, for: .normal)
        addConditionButton.setImage(.addNote, for: .normal)
        addConditionButton.adjustsImageWhenHighlighted = false
        addConditionButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        addConditionButton.imageView?.tintColor = .mgLabel
        addConditionButton.addTarget(self, action: #selector(addConditionButtonDidTap), for: .touchUpInside)
        view.addSubview(addConditionButton)
        addConditionButton.snp.makeConstraints { make -> Void in
            make.height.equalTo(ViewLayoutConstants.addConditionButtonHeight)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }

    private func initConditionsView() {

        // 初始化条件视图

        conditionsView = UIView()
        view.addSubview(conditionsView)
        conditionsView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(diagramView.snp.bottom).offset(32)
            make.bottom.equalTo(addConditionButton.snp.top).offset(-16)
        }

        // 初始化条件标题标签

        let conditionsTitleLabel: UILabel = UILabel()
        conditionsTitleLabel.text = NSLocalizedString("ConfigureConditions", comment: "")
        conditionsTitleLabel.font = .systemFont(ofSize: ViewLayoutConstants.conditionsTitleLabelFontSize, weight: .regular)
        conditionsTitleLabel.textColor = .secondaryLabel
        conditionsTitleLabel.numberOfLines = 2
        conditionsTitleLabel.lineBreakMode = .byTruncatingTail
        conditionsView.addSubview(conditionsTitleLabel)
        conditionsTitleLabel.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }

        // 初始化条件表格视图

        let conditionsTableViewContainer: RoundedView = RoundedView()
        conditionsTableViewContainer.backgroundColor = .secondarySystemGroupedBackground
        conditionsView.addSubview(conditionsTableViewContainer)
        conditionsTableViewContainer.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(conditionsTitleLabel.snp.bottom).offset(24)
            make.bottom.equalToSuperview()
        }

        conditionsTableView = UITableView()
        conditionsTableView.backgroundColor = .clear
        conditionsTableView.separatorStyle = .none
        conditionsTableView.showsVerticalScrollIndicator = false
        conditionsTableView.register(TransitionEditorConditionTableViewCell.self, forCellReuseIdentifier: TransitionEditorConditionTableViewCell.reuseId)
        conditionsTableView.dataSource = self
        conditionsTableView.delegate = self
        conditionsTableViewContainer.addSubview(conditionsTableView)
        conditionsTableView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(16)
        }
    }
}

extension TransitionEditorViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if conditions.isEmpty {
            conditionsTableView.showNoDataInfo(title: NSLocalizedString("NoConditionsAvailable", comment: ""))
        } else {
            conditionsTableView.hideNoDataInfo()
        }

        return conditions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = conditionsTableView.dequeueReusableCell(withIdentifier: TransitionEditorConditionTableViewCell.reuseId) as? TransitionEditorConditionTableViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备 OR 标签

        cell.orLabel.isHidden = indexPath.row == conditions.count - 1 ? true : false

        // 准备删除按钮

        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(conditionWillDelete), for: .touchUpInside)

        // 准备标题标签

        cell.titleLabel.attributedText = prepareConditionTitleLabelAttributedText(startScene: startScene, condition: conditions[indexPath.row])

        return cell
    }

    private func prepareConditionTitleLabelAttributedText(startScene: MetaScene, condition: MetaCondition) -> NSMutableAttributedString {

        let completeConditionTitleString: NSMutableAttributedString = NSMutableAttributedString(string: "")

        // 准备「点」

        let dotStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.mgLabel!, .font: UIFont.systemFont(ofSize: TransitionEditorConditionTableViewCell.ViewLayoutConstants.titleLabelFontSize, weight: .semibold)]
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
//            if condition.nodeIndex == 0 {
//                nodeTitle = conditionDescriptor.nodeTypeAlias
//            } else {
//                nodeTitle = conditionDescriptor.nodeTypeAlias + " " + condition.nodeIndex.description
//            }
        let nodeTitleString: NSAttributedString = NSAttributedString(string: nodeTitle, attributes: nodeTitleStringAttributes)
        completeConditionTitleString.append(nodeTitleString)
        completeConditionTitleString.append(dotString)

        // 准备组件行为标题

        let nodeBehaviorTitleStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.mgLabel!]
        let nodeBehaviorTitleString: NSAttributedString = NSAttributedString(string: /* conditionDescriptor.nodeBehaviorTypeAlias */ "action type", attributes: nodeBehaviorTitleStringAttributes)
        completeConditionTitleString.append(nodeBehaviorTitleString)

        // 准备参数

//            let parametersTitleStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.secondaryLabel]
//            var parametersTitle: String = ""
//            if let parameters = condition.parameters {
//                parametersTitle.append(" " + parameters)
//                let parametersTitleString: NSAttributedString = NSAttributedString(string: parametersTitle, attributes: parametersTitleStringAttributes)
//                completeConditionTitleString.append(parametersTitleString)
//            }
//        }

        return completeConditionTitleString
    }
}

extension TransitionEditorViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return ViewLayoutConstants.conditionTableViewCellHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        return ViewLayoutConstants.conditionTableViewCellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension TransitionEditorViewController {

    @objc private func backButtonDidTap() {

        print("[TransitionEditor] did tap backButton")

        navigationController?.popViewController(animated: true)
    }

    @objc private func addConditionButtonDidTap() {

        print("[TransitionEditor] did tap addConditionButton")
    }

    @objc private func conditionWillDelete(sender: UIButton) {

        let index = sender.tag
        let condition = conditions[index]

        // 弹出删除条件提示框

        let alert = UIAlertController(title: NSLocalizedString("DeleteCondition", comment: ""), message: NSLocalizedString("DeleteConditionInfo", comment: ""), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { [weak self] _ in

            guard let strongSelf = self else { return }

            // 保存「删除条件」信息

            strongSelf.gameBundle.deleteCondition(transition: strongSelf.transition, condition: condition)
            DispatchQueue.global(qos: .background).async {
                MetaGameBundleManager.shared.save(strongSelf.gameBundle)
            }

            // 重新加载条件

            strongSelf.conditions = strongSelf.transition.conditions
            strongSelf.conditionsTableView.reloadData()
        })

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
        })

        present(alert, animated: true, completion: nil)
    }
}
