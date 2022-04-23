///
/// TargetScenesViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class TargetScenesViewController: UIViewController {

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
        static let targetScenesTitleLabelFontSize: CGFloat = 16
        static let targetSceneTableViewCellHeight: CGFloat = 80
    }

    private var backButtonContainer: UIView!
    private var backButton: CircleNavigationBarButton!
    private var titleLabel: UILabel!

    private var diagramView: RoundedView! // 示意图视图
    private var arrowView: ArrowView! // 箭头视图
    private var targetScenesView: UIView! // 目标场景视图
    private var targetScenesTableView: UITableView! // 目标场景表格视图

    private var gameBundle: MetaGameBundle!
    private var selectedScene: MetaScene!
    private var targetScenes: [MetaScene]!

    init(gameBundle: MetaGameBundle) {

        super.init(nibName: nil, bundle: nil)

        self.gameBundle = gameBundle
        selectedScene = gameBundle.selectedScene()
        loadTargetScenes()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func loadTargetScenes() {

        targetScenes = gameBundle.scenes.filter { targetScene in
            // 过滤当前选中的场景
            if targetScene.index == gameBundle.selectedSceneIndex {
                return false
            }
            // 过滤已保存的穿梭器
            let existedTransitions = gameBundle.selectedTransitions()
            if let transitions = existedTransitions, let _ = transitions.first(where: { $0.to == targetScene.index }) { return false }
            // 返回其余的场景
            return true
        }.reversed() // 倒序
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

        // 初始化目标场景视图

        initTargetScenesView()
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
        titleLabel.text = NSLocalizedString("AddTransition", comment: "")
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
            if let thumbImage = MetaThumbManager.shared.loadSceneThumbImage(sceneUUID: strongSelf.selectedScene.uuid, gameUUID: strongSelf.gameBundle.uuid) {
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
        startSceneIndexLabel.text = selectedScene.index.description
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
        let startSceneIndexString: String = NSLocalizedString("Scene", comment: "") + " " + selectedScene.index.description
        var startSceneTitleString: String
        if let title = selectedScene.title, !title.isEmpty {
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
        endSceneView.backgroundColor = .systemFill
        diagramView.addSubview(endSceneView)
        endSceneView.snp.makeConstraints { make -> Void in
            make.width.equalTo(ViewLayoutConstants.diagramSceneViewWidth)
            make.height.equalTo(ViewLayoutConstants.diagramSceneViewHeight)
            make.top.equalToSuperview().offset(16)
            make.left.equalTo(arrowView.snp.right).offset(24)
        }
        let endSceneIndexLabel: UILabel = UILabel()
        endSceneIndexLabel.text = "?"
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
    }

    private func initTargetScenesView() {

        // 初始化目标场景视图

        targetScenesView = UIView()
        view.addSubview(targetScenesView)
        targetScenesView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(diagramView.snp.bottom).offset(32)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化目标场景标题标签

        let targetScenesTitleLabel: UILabel = UILabel()
        targetScenesTitleLabel.text = NSLocalizedString("SelectTargetScene", comment: "")
        targetScenesTitleLabel.font = .systemFont(ofSize: ViewLayoutConstants.targetScenesTitleLabelFontSize, weight: .regular)
        targetScenesTitleLabel.textColor = .secondaryLabel
        targetScenesTitleLabel.numberOfLines = 2
        targetScenesView.addSubview(targetScenesTitleLabel)
        targetScenesTitleLabel.snp.makeConstraints { make -> Void in
            make.left.right.top.equalToSuperview()
        }

        // 初始化目标场景表格视图

        let targetScenesTableViewContainer: RoundedView = RoundedView()
        targetScenesTableViewContainer.backgroundColor = .secondarySystemGroupedBackground
        targetScenesView.addSubview(targetScenesTableViewContainer)
        targetScenesTableViewContainer.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(targetScenesTitleLabel.snp.bottom).offset(24)
            make.bottom.equalToSuperview()
        }

        targetScenesTableView = UITableView()
        targetScenesTableView.backgroundColor = .clear
        targetScenesTableView.separatorStyle = .none
        targetScenesTableView.showsVerticalScrollIndicator = false
        targetScenesTableView.register(TargetSceneTableViewCell.self, forCellReuseIdentifier: TargetSceneTableViewCell.reuseId)
        targetScenesTableView.dataSource = self
        targetScenesTableView.delegate = self
        targetScenesTableViewContainer.addSubview(targetScenesTableView)
        targetScenesTableView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(8)
        }
    }
}

extension TargetScenesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if targetScenes.isEmpty {
            targetScenesTableView.showNoDataInfo(title: NSLocalizedString("NoTargetScenesAvailable", comment: ""))
        } else {
            targetScenesTableView.hideNoDataInfo()
        }

        return targetScenes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = targetScenesTableView.dequeueReusableCell(withIdentifier: TargetSceneTableViewCell.reuseId) as? TargetSceneTableViewCell else {
            fatalError("Unexpected cell type")
        }

        let targetScene: MetaScene = targetScenes[indexPath.row]

        // 准备缩略图视图

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            if let thumbImage = MetaThumbManager.shared.loadSceneThumbImage(sceneUUID: targetScene.uuid, gameUUID: strongSelf.gameBundle.uuid) {
                DispatchQueue.main.async {
                    cell.thumbImageView.image = thumbImage
                }
            } else {
                DispatchQueue.main.async {
                    cell.thumbImageView.image = .sceneBackgroundThumb
                }
            }
        }

        // 准备索引标签

        cell.indexLabel.text = targetScene.index.description

        // 准备标题标签

        cell.titleLabel.attributedText = prepareTargetSceneTitleLabelAttributedText(scene: targetScene)
        cell.titleLabel.numberOfLines = 2
        cell.titleLabel.lineBreakMode = .byTruncatingTail

        return cell
    }

    private func prepareTargetSceneTitleLabelAttributedText(scene: MetaScene) -> NSMutableAttributedString {

        let completeTitleString: NSMutableAttributedString = NSMutableAttributedString(string: "")

        // 准备场景标题

        var titleString: NSAttributedString
        if let title = scene.title, !title.isEmpty {
            let titleStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.mgLabel!]
            titleString = NSAttributedString(string: title, attributes: titleStringAttributes)
        } else {
            let titleStringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.secondaryLabel]
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

extension TargetScenesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return ViewLayoutConstants.targetSceneTableViewCellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // 选择目标场景

        selectTargetScene(targetSceneIndex: targetScenes[indexPath.row].index)
    }
}

extension TargetScenesViewController {

    @objc private func backButtonDidTap() {

        print("[TargetScenes] did tap backButton")

        navigationController?.popViewController(animated: true)
    }

    private func selectTargetScene(targetSceneIndex: Int) {

        print("[TargetScenes] did select target scene \(targetSceneIndex)")

        // 新建穿梭器
        // FIXME：重新处理「MetaTransition - MetaCondition」

        var conditions = [MetaCondition]()
        let defaultCondition = MetaCondition(sensor: MetaSensor(gameUUID: gameBundle.uuid, sceneUUID: nil, nodeUUID: nil, key: .timeControl), operatorKey: .equalTo, value: "end")
        conditions.append(defaultCondition)
//        let testCondition = MetaCondition(nodeIndex: 0, nodeType: 1, nodeBehaviorType: 12, parameters: "2次")
//        conditions.append(testCondition)
//        let test2Condition = MetaCondition(nodeIndex: 1, nodeType: 2, nodeBehaviorType: 21)
//        conditions.append(test2Condition)
//        let test3Condition = MetaCondition(nodeIndex: 2, nodeType: 3, nodeBehaviorType: 31, parameters: "(B)")
//        conditions.append(test3Condition)
//        let test4Condition = MetaCondition(nodeIndex: 3, nodeType: 4, nodeBehaviorType: 41, parameters: "3次")
//        conditions.append(test4Condition)
//        let test5Condition = MetaCondition(nodeIndex: 4, nodeType: 5, nodeBehaviorType: 51, parameters: "(熊猫)")
//        conditions.append(test5Condition)

        if let transition = gameBundle.addTransition(from: gameBundle.selectedSceneIndex, to: targetSceneIndex, conditions: conditions) {

            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let strongSelf = self else { return }
                MetaGameBundleManager.shared.save(strongSelf.gameBundle) // 保存新建的穿梭器
            }

            GameboardViewExternalChangeManager.shared.set(key: .addTransition, value: transition) // 保存「作品板视图外部变更记录字典」
        }

        // 返回父视图

        navigationController?.popViewController(animated: true)
    }
}
