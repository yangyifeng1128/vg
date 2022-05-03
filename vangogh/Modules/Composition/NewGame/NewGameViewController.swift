///
/// NewGameViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Kingfisher
import SnapKit
import UIKit

class NewGameViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let topButtonContainerWidth: CGFloat = 64
        static let topButtonContainerPadding: CGFloat = 12
        static let titleLabelFontSize: CGFloat = 16
        static let newBlankGameButtonTitleLabelFontSize: CGFloat = 20
        static let templatesTitleLabelFontSize: CGFloat = 16
        static let templateCollectionViewCellSpacing: CGFloat = 8
    }

    /// 模版集合视图
    var templatesCollectionView: UICollectionView!

    /// 作品列表
    var games: [MetaGame]!
    /// 模版列表
    var templates: [MetaTemplate] = [MetaTemplate]()

    /// 初始化
    init(games: [MetaGame]) {

        super.init(nibName: nil, bundle: nil)

        self.games = games
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

        // 加载模版列表

        loadTemplates() { [weak self] in
            guard let s = self else { return }
            s.templatesCollectionView.reloadData()
        }
    }

    /// 视图显示完成
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        // 同步模版列表

        syncTemplates() { [weak self] in
            guard let s = self else { return }
            s.loadTemplates() {
                DispatchQueue.main.async {
                    s.templatesCollectionView.reloadData()
                }
            }
        }
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
        titleLabel.text = NSLocalizedString("StartComposing", comment: "")
        titleLabel.font = .systemFont(ofSize: VC.titleLabelFontSize, weight: .regular)
        titleLabel.textColor = .mgLabel
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.centerY.equalTo(backButton)
            make.left.equalTo(backButtonContainer.snp.right).offset(8)
        }

        // 初始化「新建空白作品按钮」

        let newBlankGameButton: RoundedButton = RoundedButton(cornerRadius: GVC.defaultViewCornerRadius)
        newBlankGameButton.backgroundColor = .secondarySystemGroupedBackground
        newBlankGameButton.contentHorizontalAlignment = .center
        newBlankGameButton.contentVerticalAlignment = .center
        newBlankGameButton.setTitle(NSLocalizedString("NewBlankGame", comment: ""), for: .normal)
        newBlankGameButton.setTitleColor(.mgLabel, for: .normal)
        newBlankGameButton.titleLabel?.font = .systemFont(ofSize: VC.newBlankGameButtonTitleLabelFontSize, weight: .regular)
        newBlankGameButton.addTarget(self, action: #selector(newBlankGameButtonDidTap), for: .touchUpInside)
        view.addSubview(newBlankGameButton)
        var newBlankGameButtonHeight: CGFloat
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            newBlankGameButtonHeight = 120
            break
        case .pad, .mac, .tv, .carPlay, .unspecified:
            newBlankGameButtonHeight = 160
            break
        @unknown default:
            newBlankGameButtonHeight = 120
            break
        }
        newBlankGameButton.snp.makeConstraints { make -> Void in
            make.height.equalTo(newBlankGameButtonHeight)
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(backButtonContainer.snp.bottom).offset(24)
        }

        // 初始化「模版视图」

        let templatesView: UIView = UIView()
        view.addSubview(templatesView)
        templatesView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(8)
            make.top.equalTo(newBlankGameButton.snp.bottom).offset(48)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化「模版标题标签」

        let templatesTitleLabel: UILabel = UILabel()
        templatesTitleLabel.text = NSLocalizedString("SelectTemplate", comment: "")
        templatesTitleLabel.font = .systemFont(ofSize: VC.templatesTitleLabelFontSize, weight: .regular)
        templatesTitleLabel.textColor = .secondaryLabel
        templatesTitleLabel.textAlignment = .center
        templatesView.addSubview(templatesTitleLabel)
        templatesTitleLabel.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(8)
            make.top.equalToSuperview()
        }

        // 初始化「模版集合视图」

        templatesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        templatesCollectionView.backgroundColor = .clear
        templatesCollectionView.showsVerticalScrollIndicator = false
        templatesCollectionView.register(TemplateCollectionViewCell.self, forCellWithReuseIdentifier: TemplateCollectionViewCell.reuseId)
        templatesCollectionView.dataSource = self
        templatesCollectionView.delegate = self

        // 为「模版集合视图」添加「刷新控制器」

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefreshTemplates), for: .valueChanged)
        templatesCollectionView.refreshControl = refreshControl
        templatesCollectionView.alwaysBounceVertical = true

        templatesView.addSubview(templatesCollectionView)
        templatesCollectionView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(templatesTitleLabel.snp.bottom).offset(24)
            make.bottom.equalToSuperview()
        }
    }
}

extension NewGameViewController: UICollectionViewDataSource {

    /// 设置单元格数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return prepareTemplatesCount()
    }

    /// 设置单元格
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        return prepareTemplateCollectionViewCell(indexPath: indexPath)
    }
}

extension NewGameViewController: UICollectionViewDelegate {

    /// 选中单元格
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        selectTemplateTableViewCell(indexPath: indexPath)
    }
}

extension NewGameViewController: UICollectionViewDelegateFlowLayout {

    /// 设置单元格尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return prepareTemplateCollectionViewCellSize(indexPath: indexPath)
    }

    /// 设置内边距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let inset = VC.templateCollectionViewCellSpacing
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }

    /// 设置最小行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return VC.templateCollectionViewCellSpacing
    }

    /// 设置最小单元格间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return VC.templateCollectionViewCellSpacing
    }
}
