///
/// TargetScenesViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class TargetScenesViewController: UIViewController {

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
        static let targetScenesTitleLabelFontSize: CGFloat = 16
        static let targetSceneTableViewCellHeight: CGFloat = 80
    }

    /// 箭头视图
    var arrowView: ArrowView!
    /// 目标场景视图
    var targetScenesView: UIView!
    /// 目标场景表格视图
    var targetScenesTableView: UITableView!

    /// 作品资源包
    var gameBundle: MetaGameBundle!
    /// 当前选中的场景
    var selectedScene: MetaScene!
    /// 目标场景列表
    var targetScenes: [MetaScene] = [MetaScene]()

    /// 初始化
    init(gameBundle: MetaGameBundle) {

        super.init(nibName: nil, bundle: nil)

        self.gameBundle = gameBundle
        selectedScene = gameBundle.selectedScene()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 视图加载完成
    override func viewDidLoad() {

        super.viewDidLoad()

        initViews()
    }

    /// 视图即将显示
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // 隐藏导航栏

        navigationController?.navigationBar.isHidden = true

        // 加载目标场景列表

        loadTargetScenes() { [weak self] in
            guard let s = self else { return }
            s.targetScenesTableView.reloadData()
        }
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
        titleLabel.text = NSLocalizedString("AddTransition", comment: "")
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
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let s = self else { return }
            if let thumbImage = MetaThumbManager.shared.loadSceneThumbImage(sceneUUID: s.selectedScene.uuid, gameUUID: s.gameBundle.uuid) {
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
        startSceneIndexLabel.text = selectedScene.index.description
        startSceneIndexLabel.font = .systemFont(ofSize: VC.diagramSceneIndexLabelFontSize, weight: .regular)
        startSceneIndexLabel.textColor = .mgHoneydew
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
        endSceneView.backgroundColor = .systemFill
        diagramView.addSubview(endSceneView)
        endSceneView.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.diagramSceneViewWidth)
            make.height.equalTo(VC.diagramSceneViewHeight)
            make.top.equalToSuperview().offset(16)
            make.left.equalTo(arrowView.snp.right).offset(24)
        }

        // 初始化「结束场景索引标签」

        let endSceneIndexLabel: UILabel = UILabel()
        endSceneIndexLabel.text = "?"
        endSceneIndexLabel.font = .systemFont(ofSize: VC.diagramSceneIndexLabelFontSize, weight: .regular)
        endSceneIndexLabel.textColor = .mgHoneydew
        endSceneIndexLabel.textAlignment = .center
        endSceneIndexLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        endSceneIndexLabel.layer.shadowOpacity = 1
        endSceneIndexLabel.layer.shadowRadius = 0
        endSceneIndexLabel.layer.shadowColor = UIColor.black.cgColor
        endSceneView.addSubview(endSceneIndexLabel)
        endSceneIndexLabel.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        // 初始化「目标场景视图」

        targetScenesView = UIView()
        view.addSubview(targetScenesView)
        targetScenesView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(diagramView.snp.bottom).offset(32)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化「目标场景标题标签」

        let targetScenesTitleLabel: UILabel = UILabel()
        targetScenesTitleLabel.text = NSLocalizedString("SelectTargetScene", comment: "")
        targetScenesTitleLabel.font = .systemFont(ofSize: VC.targetScenesTitleLabelFontSize, weight: .regular)
        targetScenesTitleLabel.textColor = .secondaryLabel
        targetScenesTitleLabel.numberOfLines = 2
        targetScenesView.addSubview(targetScenesTitleLabel)
        targetScenesTitleLabel.snp.makeConstraints { make -> Void in
            make.left.right.top.equalToSuperview()
        }

        // 初始化「目标场景表格视图容器」

        let targetScenesTableViewContainer: RoundedView = RoundedView()
        targetScenesTableViewContainer.backgroundColor = .secondarySystemGroupedBackground
        targetScenesView.addSubview(targetScenesTableViewContainer)
        targetScenesTableViewContainer.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(targetScenesTitleLabel.snp.bottom).offset(24)
            make.bottom.equalToSuperview()
        }

        // 初始化「目标场景表格视图」

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

    /// 设置单元格数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return prepareTargetScenesCount()
    }

    /// 设置单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return prepareTargetSceneTableViewCell(indexPath: indexPath)
    }
}

extension TargetScenesViewController: UITableViewDelegate {

    /// 设置单元格高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return VC.targetSceneTableViewCellHeight
    }

    /// 选中单元格
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectTargetSceneTableViewCell(indexPath: indexPath)
    }
}
