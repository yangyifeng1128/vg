///
/// PublicationViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import CoreData
import Kingfisher
import OSLog
import SnapKit
import UIKit

class PublicationViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let topButtonContainerWidth: CGFloat = 64
        static let topButtonContainerPadding: CGFloat = 12
        static let titleLabelFontSize: CGFloat = 16
        static let publishButtonTitleLabelFontSize: CGFloat = 20
        static let archivesTitleLabelFontSize: CGFloat = 16
        static let archiveCollectionViewCellSpacing: CGFloat = 8
    }

    private var backButtonContainer: UIView!
    private var backButton: CircleNavigationBarButton!
    private var gameSettingsButtonContainer: UIView!
    private var gameSettingsButton: CircleNavigationBarButton!

    private var publishButton: RoundedButton!
    private var archivesCollectionView: UICollectionView!
    private var archiveCollectionViewCellWidth: CGFloat!
    private var archiveCollectionViewCellHeight: CGFloat!

    /// 作品
    private var game: MetaGame!
    /// 档案列表
    private var archives: [MetaTemplate] = [MetaTemplate]()

    /// 初始化
    init(game: MetaGame) {

        super.init(nibName: nil, bundle: nil)

        self.game = game
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 视图加载完成
    override func viewDidLoad() {

        super.viewDidLoad()

        initViews()

        // 从服务器同步档案

        syncArchives()
    }

    /// 视图即将显示
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // 隐藏导航栏

        navigationController?.navigationBar.isHidden = true

        // 加载档案列表

        loadArchives()
    }

    /// 初始化视图
    private func initViews() {

        view.backgroundColor = .systemGroupedBackground

        // 初始化「导航栏」

        initNavigationBar()

        // 初始化「发布按钮」

        initPublishButton()

        // 初始化「档案视图」

        initArchivesView()
    }

    /// 初始化「导航栏」
    private func initNavigationBar() {

        // 初始化「返回按钮容器」

        backButtonContainer = UIView()
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

        backButton = CircleNavigationBarButton(icon: .arrowBack)
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        backButtonContainer.addSubview(backButton)
        backButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.VC.width)
            make.right.bottom.equalToSuperview().offset(-VC.topButtonContainerPadding)
        }

        // 初始化「标题标签」

        let titleLabel: UILabel = UILabel()
        titleLabel.text = NSLocalizedString("Publish", comment: "")
        titleLabel.font = .systemFont(ofSize: VC.titleLabelFontSize, weight: .regular)
        titleLabel.textColor = .mgLabel
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.centerY.equalTo(backButton)
            make.left.equalTo(backButtonContainer.snp.right).offset(8)
        }

        // 初始化「作品设置按钮容器」

        gameSettingsButtonContainer = UIView()
        gameSettingsButtonContainer.backgroundColor = .clear
        gameSettingsButtonContainer.isUserInteractionEnabled = true
        gameSettingsButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gameSettingsButtonDidTap)))
        view.addSubview(gameSettingsButtonContainer)
        let gameSettingsButtonContainerLeft: CGFloat = view.bounds.width - VC.topButtonContainerWidth
        gameSettingsButtonContainer.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.topButtonContainerWidth)
            make.left.equalToSuperview().offset(gameSettingsButtonContainerLeft)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        // 初始化「作品设置按钮」

        gameSettingsButton = CircleNavigationBarButton(icon: .gameSettings)
        gameSettingsButton.addTarget(self, action: #selector(gameSettingsButtonDidTap), for: .touchUpInside)
        gameSettingsButtonContainer.addSubview(gameSettingsButton)
        gameSettingsButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.VC.width)
            make.left.equalToSuperview().offset(VC.topButtonContainerPadding)
            make.bottom.equalToSuperview().offset(-VC.topButtonContainerPadding)
        }
    }

    /// 初始化「发布按钮」
    private func initPublishButton() {

        publishButton = RoundedButton(cornerRadius: GVC.defaultViewCornerRadius)
        publishButton.backgroundColor = .secondarySystemGroupedBackground
        publishButton.contentHorizontalAlignment = .center
        publishButton.contentVerticalAlignment = .center
        publishButton.setTitle(NSLocalizedString("PublishInitialVersion", comment: ""), for: .normal)
        publishButton.setTitleColor(.mgLabel, for: .normal)
        publishButton.titleLabel?.font = .systemFont(ofSize: VC.publishButtonTitleLabelFontSize, weight: .regular)
        publishButton.addTarget(self, action: #selector(publishButtonDidTap), for: .touchUpInside)
        view.addSubview(publishButton)
        var publishButtonHeight: CGFloat
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            publishButtonHeight = 120
            break
        case .pad, .mac, .tv, .carPlay, .unspecified:
            publishButtonHeight = 160
            break
        @unknown default:
            publishButtonHeight = 120
            break
        }
        publishButton.snp.makeConstraints { make -> Void in
            make.height.equalTo(publishButtonHeight)
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(backButtonContainer.snp.bottom).offset(24)
        }
    }

    /// 初始化「档案视图」
    private func initArchivesView() {

        // 初始化「档案视图」

        let archivesView: UIView = UIView()
        view.addSubview(archivesView)
        archivesView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(8)
            make.top.equalTo(publishButton.snp.bottom).offset(48)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化「档案标题标签」

        let archivesTitleLabel: UILabel = UILabel()
        archivesTitleLabel.text = NSLocalizedString("ArchiveHistory", comment: "")
        archivesTitleLabel.font = .systemFont(ofSize: VC.archivesTitleLabelFontSize, weight: .regular)
        archivesTitleLabel.textColor = .secondaryLabel
        archivesView.addSubview(archivesTitleLabel)
        archivesTitleLabel.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(8)
            make.top.equalToSuperview()
        }

        // 初始化「档案集合视图」

        archivesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        archivesCollectionView.backgroundColor = .clear
        archivesCollectionView.showsVerticalScrollIndicator = false
        archivesCollectionView.dataSource = self
        archivesCollectionView.delegate = self
        archivesCollectionView.register(ArchiveCollectionViewCell.self, forCellWithReuseIdentifier: ArchiveCollectionViewCell.reuseId)

        // 为「档案集合视图」添加「刷新控制器」

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefreshArchives), for: .valueChanged)
        archivesCollectionView.refreshControl = refreshControl
        archivesCollectionView.alwaysBounceVertical = true

        archivesView.addSubview(archivesCollectionView)
        archivesCollectionView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(archivesTitleLabel.snp.bottom).offset(24)
            make.bottom.equalToSuperview()
        }
    }
}

extension PublicationViewController: UICollectionViewDataSource {

    /// 设置单元格数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if archives.isEmpty {
            archivesCollectionView.showNoDataInfo(title: NSLocalizedString("NoArchivesAvailable", comment: ""))
        } else {
            archivesCollectionView.hideNoDataInfo()
        }

        return archives.count
    }

    /// 设置单元格
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let archive: MetaTemplate = archives[indexPath.item]

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArchiveCollectionViewCell.reuseId, for: indexPath) as? ArchiveCollectionViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备「标题标签」

        cell.titleLabel.text = archive.title

        // 准备「缩略图视图」

        let thumbURL = URL(string: "\(GUC.templateThumbsBaseURLString)/\(archive.thumbFileName)")!
        cell.thumbImageView.kf.setImage(with: thumbURL)

        return cell
    }
}

extension PublicationViewController: UICollectionViewDelegate {

    /// 选中单元格
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let archive: MetaTemplate = archives[indexPath.item]

        print("[Publication] did use archive: \(archive.bundleFileName)")
    }
}

extension PublicationViewController: UICollectionViewDelegateFlowLayout {

    /// 设置单元格尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var numberOfCellsPerRow: Int
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            numberOfCellsPerRow = 3
            break
        case .pad, .mac, .tv, .carPlay, .unspecified:
            numberOfCellsPerRow = 5
            break
        @unknown default:
            numberOfCellsPerRow = 3
            break
        }

        let cellSpacing = VC.archiveCollectionViewCellSpacing

        archiveCollectionViewCellWidth = ((collectionView.bounds.width - CGFloat(numberOfCellsPerRow + 1) * cellSpacing) / CGFloat(numberOfCellsPerRow)).rounded(.down)
        archiveCollectionViewCellHeight = (archiveCollectionViewCellWidth / GVC.defaultSceneAspectRatio).rounded(.down)

        return CGSize(width: archiveCollectionViewCellWidth, height: archiveCollectionViewCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let inset = VC.archiveCollectionViewCellSpacing
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        let lineSpacing = VC.archiveCollectionViewCellSpacing
        return lineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return VC.archiveCollectionViewCellSpacing
    }
}


extension PublicationViewController {

    /// 点击「返回按钮」
    @objc private func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }

    @objc private func gameSettingsButtonDidTap() {

        print("[Publication] did tap gameSettingsButton")

        openGameSettings()
    }

    @objc private func publishButtonDidTap() {

        print("[Publication] did tap publishButton")
    }

    @objc private func pullToRefreshArchives() {

        syncArchives()
        archivesCollectionView.refreshControl?.endRefreshing()
    }

    private func openGameSettings() {

        let gameSettingsVC = GameSettingsViewController(game: game)
        gameSettingsVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(gameSettingsVC, animated: true)
    }


    /// 同步档案列表
    func syncArchives(completion handler: (() -> Void)? = nil) {

        let archivesURL = URL(string: "\(GUC.templatesURLString)?page=1&sort_by=ctime&sort_order=ascending")!

        URLSession.shared.dataTask(with: archivesURL) { data, _, error in

            guard let data = data else { return }

            do {
                let decoder = JSONDecoder()
                decoder.userInfo[CodingUserInfoKey.context!] = CoreDataManager.shared.persistentContainer.viewContext
                let archivesData = try decoder.decode([MetaTemplate].self, from: data)
                Logger.gameEditor.info("synchronizing \(archivesData.count) archives: ok")
                CoreDataManager.shared.saveContext()
                if let handler = handler {
                    DispatchQueue.main.async {
                        handler()
                    }
                }
            } catch {
                Logger.gameEditor.info("synchronizing archives error: \(error.localizedDescription)")
            }

        }.resume()
    }

    /// 加载档案列表
    private func loadArchives(completion handler: (() -> Void)? = nil) {

        let request: NSFetchRequest<MetaTemplate> = MetaTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "status == 1")
        request.sortDescriptors = [NSSortDescriptor(key: "ctime", ascending: false)]

        do {
            archives = try CoreDataManager.shared.persistentContainer.viewContext.fetch(request)
            archivesCollectionView.reloadData()
            Logger.gameEditor.info("loading meta archives: ok")
        } catch {
            Logger.gameEditor.info("loading meta archives error: \(error.localizedDescription)")
        }

        if let handler = handler {
            DispatchQueue.main.async {
                handler()
            }
        }
    }
}
