///
/// TransitionEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class TransitionEditorViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
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

    /// 箭头视图
    var arrowView: ArrowView!
    /// 条件表格视图
    var conditionsTableView: UITableView!

    /// 作品资源包
    var gameBundle: MetaGameBundle!
    /// 穿梭器
    var transition: MetaTransition!
    /// 开始场景
    var startScene: MetaScene!
    /// 结束场景
    var endScene: MetaScene!
    /// 条件列表
    var conditions: [MetaCondition]!

    /// 初始化
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

    /// 视图加载完成
    override func viewDidLoad() {

        super.viewDidLoad()

        initViews()
    }

    /// 重写用户界面风格变化处理方法
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)

        arrowView.arrowLayerColor = UIColor.secondaryLabel.cgColor
        arrowView.updateView()
    }

    /// 初始化视图
    private func initViews() {

        view.backgroundColor = .systemGroupedBackground

        // 初始化「返回按钮容器」

        let backButtonContainer: UIView = UIView()
        backButtonContainer.backgroundColor = .clear
        backButtonContainer.isUserInteractionEnabled = true
        backButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backButtonDidTap)))
        view.addSubview(backButtonContainer)
        backButtonContainer.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.topButtonContainerWidth)
            make.left.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        // 初始化「返回按钮」

        let backButton: CircleNavigationBarButton = CircleNavigationBarButton(icon: .arrowBack)
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        backButtonContainer.addSubview(backButton)
        backButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.VC.width)
            make.right.bottom.equalToSuperview().offset(-VC.topButtonContainerPadding)
        }

        // 初始化「标题标签」

        let titleLabel: UILabel = UILabel()
        titleLabel.text = NSLocalizedString("EditTransition", comment: "")
        titleLabel.font = .systemFont(ofSize: VC.titleLabelFontSize, weight: .regular)
        titleLabel.textColor = .mgLabel
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.centerY.equalTo(backButton)
            make.left.equalTo(backButtonContainer.snp.right).offset(8)
        }

        // 初始化「示意图视图」

        let diagramView: RoundedView = RoundedView()
        diagramView.backgroundColor = .systemGroupedBackground
        view.addSubview(diagramView)
        diagramView.snp.makeConstraints { make -> Void in
            make.height.equalTo(VC.diagramViewHeight)
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(backButtonContainer.snp.bottom).offset(24)
        }

        // 初始化「箭头视图」

        arrowView = ArrowView()
        diagramView.addSubview(arrowView)
        arrowView.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.diagramArrowViewWidth)
            make.height.equalTo(VC.diagramArrowViewHeight)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(VC.diagramSceneViewTopOffset + VC.diagramSceneViewHeight / 2 - VC.diagramArrowViewHeight / 2)
        }

        // 初始化「开始场景视图」

        let startSceneView: RoundedImageView = RoundedImageView(cornerRadius: GVC.defaultViewCornerRadius)
        startSceneView.contentMode = .scaleAspectFill
        startSceneView.image = .sceneBackgroundThumb
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let s = self else { return }
            if let thumbImage = MetaThumbManager.shared.loadSceneThumbImage(sceneUUID: s.startScene.uuid, gameUUID: s.gameBundle.uuid) {
                DispatchQueue.main.async {
                    startSceneView.image = thumbImage
                }
            }
        }
        diagramView.addSubview(startSceneView)
        startSceneView.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.diagramSceneViewWidth)
            make.height.equalTo(VC.diagramSceneViewHeight)
            make.right.equalTo(arrowView.snp.left).offset(-24)
            make.top.equalToSuperview().offset(VC.diagramSceneViewTopOffset)
        }

        // 初始化「开始场景索引标签」

        let startSceneIndexLabel = UILabel()
        startSceneIndexLabel.text = startScene.index.description
        startSceneIndexLabel.font = .systemFont(ofSize: VC.diagramSceneIndexLabelFontSize, weight: .regular)
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

        // 初始化「开始场景标题标签」

        let startSceneTitleLabel: UILabel = UILabel()
        let startSceneIndexString: String = NSLocalizedString("Scene", comment: "") + " " + startScene.index.description
        var startSceneTitleString: String
        if let title = startScene.title, !title.isEmpty {
            startSceneTitleString = title
        } else {
            startSceneTitleString = startSceneIndexString
        }
        startSceneTitleLabel.text = startSceneTitleString
        startSceneTitleLabel.font = .systemFont(ofSize: VC.diagramSceneTitleLabelFontSize, weight: .regular)
        startSceneTitleLabel.textColor = .secondaryLabel
        startSceneTitleLabel.textAlignment = .center
        startSceneTitleLabel.numberOfLines = 2
        startSceneTitleLabel.lineBreakMode = .byTruncatingTail
        diagramView.addSubview(startSceneTitleLabel)
        startSceneTitleLabel.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.diagramSceneTitleLabelWidth)
            make.height.equalTo(VC.diagramSceneTitleLabelHeight)
            make.centerX.equalTo(startSceneView)
            make.top.equalTo(startSceneView.snp.bottom).offset(8)
        }

        // 初始化「结束场景视图」

        let endSceneView: RoundedImageView = RoundedImageView(cornerRadius: GVC.defaultViewCornerRadius)
        endSceneView.contentMode = .scaleAspectFill
        endSceneView.image = .sceneBackgroundThumb
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let s = self else { return }
            if let thumbImage = MetaThumbManager.shared.loadSceneThumbImage(sceneUUID: s.endScene.uuid, gameUUID: s.gameBundle.uuid) {
                DispatchQueue.main.async {
                    endSceneView.image = thumbImage
                }
            }
        }
        diagramView.addSubview(endSceneView)
        endSceneView.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.diagramSceneViewWidth)
            make.height.equalTo(VC.diagramSceneViewHeight)
            make.top.equalToSuperview().offset(16)
            make.left.equalTo(arrowView.snp.right).offset(24)
        }

        // 初始化「结束场景索引标签」

        let endSceneIndexLabel = UILabel()
        endSceneIndexLabel.text = endScene.index.description
        endSceneIndexLabel.font = .systemFont(ofSize: VC.diagramSceneIndexLabelFontSize, weight: .regular)
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

        // 初始化「结束场景标题标签」

        let endSceneTitleLabel: UILabel = UILabel()
        let endSceneIndexString: String = NSLocalizedString("Scene", comment: "") + " " + endScene.index.description
        var endSceneTitleString: String
        if let title = endScene.title, !title.isEmpty {
            endSceneTitleString = title
        } else {
            endSceneTitleString = endSceneIndexString
        }
        endSceneTitleLabel.text = endSceneTitleString
        endSceneTitleLabel.font = .systemFont(ofSize: VC.diagramSceneTitleLabelFontSize, weight: .regular)
        endSceneTitleLabel.textColor = .secondaryLabel
        endSceneTitleLabel.textAlignment = .center
        endSceneTitleLabel.numberOfLines = 2
        endSceneTitleLabel.lineBreakMode = .byTruncatingTail
        diagramView.addSubview(endSceneTitleLabel)
        endSceneTitleLabel.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.diagramSceneTitleLabelWidth)
            make.height.equalTo(VC.diagramSceneTitleLabelHeight)
            make.centerX.equalTo(endSceneView)
            make.top.equalTo(endSceneView.snp.bottom).offset(8)
        }

        // 初始化「添加条件按钮」

        let addConditionButton: RoundedButton = RoundedButton(cornerRadius: GVC.defaultViewCornerRadius)
        addConditionButton.backgroundColor = .secondarySystemGroupedBackground
        addConditionButton.tintColor = .mgLabel
        addConditionButton.setTitle(NSLocalizedString("AddCondition", comment: ""), for: .normal)
        addConditionButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        addConditionButton.titleLabel?.font = .systemFont(ofSize: VC.addConditionButtonTitleLabelFontSize, weight: .regular)
        addConditionButton.setTitleColor(.mgLabel, for: .normal)
        addConditionButton.setImage(.addNote, for: .normal)
        addConditionButton.adjustsImageWhenHighlighted = false
        addConditionButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        addConditionButton.imageView?.tintColor = .mgLabel
        addConditionButton.addTarget(self, action: #selector(addConditionButtonDidTap), for: .touchUpInside)
        view.addSubview(addConditionButton)
        addConditionButton.snp.makeConstraints { make -> Void in
            make.height.equalTo(VC.addConditionButtonHeight)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化「条件视图」

        let conditionsView: UIView = UIView()
        view.addSubview(conditionsView)
        conditionsView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(diagramView.snp.bottom).offset(32)
            make.bottom.equalTo(addConditionButton.snp.top).offset(-16)
        }

        // 初始化「条件标题标签」

        let conditionsTitleLabel: UILabel = UILabel()
        conditionsTitleLabel.text = NSLocalizedString("ConfigureConditions", comment: "")
        conditionsTitleLabel.font = .systemFont(ofSize: VC.conditionsTitleLabelFontSize, weight: .regular)
        conditionsTitleLabel.textColor = .secondaryLabel
        conditionsTitleLabel.numberOfLines = 2
        conditionsTitleLabel.lineBreakMode = .byTruncatingTail
        conditionsView.addSubview(conditionsTitleLabel)
        conditionsTitleLabel.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }

        // 初始化「条件表格视图容器」

        let conditionsTableViewContainer: RoundedView = RoundedView()
        conditionsTableViewContainer.backgroundColor = .secondarySystemGroupedBackground
        conditionsView.addSubview(conditionsTableViewContainer)
        conditionsTableViewContainer.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(conditionsTitleLabel.snp.bottom).offset(24)
            make.bottom.equalToSuperview()
        }

        // 初始化「条件表格视图」

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

    /// 设置单元格数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return prepareConditionsCount()
    }

    /// 设置单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return prepareConditionTableViewCell(indexPath: indexPath)
    }
}

extension TransitionEditorViewController: UITableViewDelegate {

    /// 设置单元格高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return VC.conditionTableViewCellHeight
    }

    /// 设置估算单元格高度
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        return VC.conditionTableViewCellHeight
    }

    /// 选中单元格
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectConditionTableViewCell(indexPath: indexPath)
    }
}
