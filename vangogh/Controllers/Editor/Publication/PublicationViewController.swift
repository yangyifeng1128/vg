///
/// PublicationViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import CoreData
import SnapKit
import UIKit

class PublicationViewController: UIViewController {

    // 视图布局常量枚举值

    enum ViewLayoutConstants {
        static let topButtonContainerWidth: CGFloat = 64
        static let topButtonContainerPadding: CGFloat = 12
        static let titleLabelFontSize: CGFloat = 16
        static let publishButtonTitleLabelFontSize: CGFloat = 20
        static let archivesTitleLabelFontSize: CGFloat = 16
        static let archiveCollectionViewCellSpacing: CGFloat = 8
    }

    private var backButtonContainer: UIView!
    private var backButton: CircleNavigationBarButton!
    private var titleLabel: UILabel!
    private var gameSettingsButtonContainer: UIView!
    private var gameSettingsButton: CircleNavigationBarButton!

    private var publishButton: RoundedButton!
    private var archivesView: UIView!
    private var archivesCollectionView: UICollectionView!
    private var archiveCollectionViewCellWidth: CGFloat!
    private var archiveCollectionViewCellHeight: CGFloat!

    private var persistentContainer: NSPersistentContainer = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate!.persistentContainer
    }() // 持久化容器
    private var game: MetaGame! // 作品
    private var archives: [NSManagedObject] = [NSManagedObject]() // 档案列表

    init(game: MetaGame) {

        super.init(nibName: nil, bundle: nil)

        self.game = game
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

        // 从服务器同步档案

        syncArchives()
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // 隐藏导航栏

        navigationController?.navigationBar.isHidden = true

        // 从本地加载档案列表

        loadArchives()
    }

    private func initSubviews() {

        view.backgroundColor = .systemGroupedBackground

        // 初始化导航栏

        initNavigationBar()

        // 初始化发布按钮

        initPublishButton()

        // 初始化档案视图

        initArchivesView()
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
        titleLabel.text = NSLocalizedString("Publish", comment: "")
        titleLabel.font = .systemFont(ofSize: ViewLayoutConstants.titleLabelFontSize, weight: .regular)
        titleLabel.textColor = .mgLabel
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.centerY.equalTo(backButton)
            make.left.equalTo(backButtonContainer.snp.right).offset(8)
        }

        // 初始化作品设置按钮

        gameSettingsButtonContainer = UIView()
        gameSettingsButtonContainer.backgroundColor = .clear
        gameSettingsButtonContainer.isUserInteractionEnabled = true
        gameSettingsButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gameSettingsButtonDidTap)))
        view.addSubview(gameSettingsButtonContainer)
        let gameSettingsButtonContainerLeft: CGFloat = view.bounds.width - ViewLayoutConstants.topButtonContainerWidth
        gameSettingsButtonContainer.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(ViewLayoutConstants.topButtonContainerWidth)
            make.left.equalToSuperview().offset(gameSettingsButtonContainerLeft)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        gameSettingsButton = CircleNavigationBarButton(icon: .gameSettings)
        gameSettingsButton.addTarget(self, action: #selector(gameSettingsButtonDidTap), for: .touchUpInside)
        gameSettingsButtonContainer.addSubview(gameSettingsButton)
        gameSettingsButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.ViewLayoutConstants.width)
            make.left.equalToSuperview().offset(ViewLayoutConstants.topButtonContainerPadding)
            make.bottom.equalToSuperview().offset(-ViewLayoutConstants.topButtonContainerPadding)
        }
    }

    private func initPublishButton() {

        publishButton = RoundedButton(cornerRadius: GlobalViewLayoutConstants.defaultViewCornerRadius)
        publishButton.backgroundColor = .secondarySystemGroupedBackground
        publishButton.contentHorizontalAlignment = .center
        publishButton.contentVerticalAlignment = .center
        publishButton.setTitle(NSLocalizedString("PublishInitialVersion", comment: ""), for: .normal)
        publishButton.setTitleColor(.mgLabel, for: .normal)
        publishButton.titleLabel?.font = .systemFont(ofSize: ViewLayoutConstants.publishButtonTitleLabelFontSize, weight: .regular)
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

    private func initArchivesView() {

        archivesView = UIView()
        view.addSubview(archivesView)
        archivesView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(8)
            make.top.equalTo(publishButton.snp.bottom).offset(48)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化档案标题标签

        let archivesTitleLabel: UILabel = UILabel()
        archivesTitleLabel.text = NSLocalizedString("ArchiveHistory", comment: "")
        archivesTitleLabel.font = .systemFont(ofSize: ViewLayoutConstants.archivesTitleLabelFontSize, weight: .regular)
        archivesTitleLabel.textColor = .secondaryLabel
        archivesView.addSubview(archivesTitleLabel)
        archivesTitleLabel.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(8)
            make.top.equalToSuperview()
        }

        // 初始化档案集合视图

        archivesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        archivesCollectionView.backgroundColor = .clear
        archivesCollectionView.showsVerticalScrollIndicator = false
        archivesCollectionView.dataSource = self
        archivesCollectionView.delegate = self
        archivesCollectionView.register(ArchiveCollectionViewCell.self, forCellWithReuseIdentifier: ArchiveCollectionViewCell.reuseId)

        // 为档案集合视图添加刷新控制器

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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if archives.isEmpty {
            archivesCollectionView.showNoDataInfo(title: NSLocalizedString("NoArchivesAvailable", comment: ""))
        } else {
            archivesCollectionView.hideNoDataInfo()
        }

        return archives.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArchiveCollectionViewCell.reuseId, for: indexPath) as? ArchiveCollectionViewCell else {
            fatalError("Unexpected cell type")
        }

        if let archive = archives[indexPath.item] as? MetaTemplate {

            // 准备标题标签

            cell.titleLabel.text = archive.title

            // 准备缩略图视图

            cell.thumbImageView.pin_updateWithProgress = true
            let thumbURL = URL(string: "\(GlobalURLConstants.templateThumbsBaseURLString)/\(archive.thumbFileName)")!
            cell.thumbImageView.pin_setImage(from: thumbURL, processorKey: "scaleToFit") { result, _ -> UIImage? in

                guard let image = result.image else { return nil }

                // 根据默认的场景尺寸比例，计算新的图像尺寸

                var newSize: CGSize
                let originalSize = image.size
                if originalSize.width / originalSize.height < GlobalViewLayoutConstants.defaultSceneAspectRatio {
                    newSize = CGSize(width: originalSize.width, height: (originalSize.width / GlobalViewLayoutConstants.defaultSceneAspectRatio).rounded(.down))
                } else {
                    newSize = CGSize(width: (originalSize.height * GlobalViewLayoutConstants.defaultSceneAspectRatio).rounded(.down), height: originalSize.height)
                }

                // 根据新的图像尺寸，裁剪原图像

                UIGraphicsBeginImageContext(newSize)
                let drawRect = CGRect(x: (newSize.width - originalSize.width) / 2, y: (newSize.height - originalSize.height) / 2, width: originalSize.width, height: originalSize.height)
                image.draw(in: drawRect)
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

                return newImage
            }
        }

        return cell
    }
}

extension PublicationViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let archive = archives[indexPath.item] as? MetaTemplate {

            print("[Publication] did use archive: \(archive.bundleFileName)")
        }
    }
}

extension PublicationViewController: UICollectionViewDelegateFlowLayout {

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

        let cellSpacing = ViewLayoutConstants.archiveCollectionViewCellSpacing

        archiveCollectionViewCellWidth = ((collectionView.bounds.width - CGFloat(numberOfCellsPerRow + 1) * cellSpacing) / CGFloat(numberOfCellsPerRow)).rounded(.down)
        archiveCollectionViewCellHeight = (archiveCollectionViewCellWidth / GlobalViewLayoutConstants.defaultSceneAspectRatio).rounded(.down)

        return CGSize(width: archiveCollectionViewCellWidth, height: archiveCollectionViewCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let inset = ViewLayoutConstants.archiveCollectionViewCellSpacing
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        let lineSpacing = ViewLayoutConstants.archiveCollectionViewCellSpacing
        return lineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return ViewLayoutConstants.archiveCollectionViewCellSpacing
    }
}


extension PublicationViewController {

    //
    //
    // MARK: - 界面操作
    //
    //

    @objc private func backButtonDidTap() {

        print("[Publication] did tap backButton")

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

    //
    //
    // MARK: - 数据操作
    //
    //

    private func syncArchives() {

        let archivesURL = URL(string: "\(GlobalURLConstants.templatesURLString)?page=1&sort_by=ctime&sort_order=ascending")!

        URLSession.shared.dataTask(with: archivesURL) { [weak self] data, _, error in
            guard let strongSelf = self, let data = data else { return }
            do {
                let decoder = JSONDecoder()
                decoder.userInfo[CodingUserInfoKey.context!] = strongSelf.persistentContainer.viewContext
                let archivesData = try decoder.decode([MetaTemplate].self, from: data)
                print("[Publication] synchronize \(archivesData.count) meta archives: ok")
                strongSelf.saveContext()
                DispatchQueue.main.async {
                    strongSelf.loadArchives()
                }
            } catch {
                print("[Publication] synchronize meta archives error: \(error)")
            }
        }.resume()
    }

    private func loadArchives() {

        let request: NSFetchRequest<MetaTemplate> = MetaTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "status == 1")
        request.sortDescriptors = [NSSortDescriptor(key: "ctime", ascending: false)]

        do {
            archives = try persistentContainer.viewContext.fetch(request)
            archivesCollectionView.reloadData()
            print("[Publication] load meta archives: ok")
        } catch {
            print("[Publication] load meta archives error: \(error)")
        }
    }

    private func saveContext() {

        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
                print("[Publication] save meta archives: ok")
            } catch {
                print("[Publication] save meta archives error: \(error)")
            }
        }
    }
}
