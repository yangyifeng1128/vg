///
/// NewGameViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import CoreData
import PINRemoteImage
import SnapKit
import UIKit

class NewGameViewController: UIViewController {

    // 视图布局常量枚举值

    enum ViewLayoutConstants {
        static let topButtonContainerWidth: CGFloat = 64
        static let topButtonContainerPadding: CGFloat = 12
        static let titleLabelFontSize: CGFloat = 16
        static let newBlankGameButtonTitleLabelFontSize: CGFloat = 20
        static let templatesTitleLabelFontSize: CGFloat = 16
        static let templateCollectionViewCellSpacing: CGFloat = 8
    }

    private var backButtonContainer: UIView!
    private var backButton: CircleNavigationBarButton!
    private var titleLabel: UILabel!

    private var newBlankGameButton: RoundedButton!
    private var templatesView: UIView!
    private var templatesCollectionView: UICollectionView!
    private var templateCollectionViewCellWidth: CGFloat!
    private var templateCollectionViewCellHeight: CGFloat!

    private var persistentContainer: NSPersistentContainer = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate!.persistentContainer
    }() // 持久化容器
    private var games: [NSManagedObject]! // 作品列表
    private var templates: [NSManagedObject] = [NSManagedObject]() // 模版列表

    init(games: [NSManagedObject]) {

        super.init(nibName: nil, bundle: nil)

        self.games = games
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

        // 从服务器同步模版

        syncTemplates()
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // 隐藏导航栏

        navigationController?.navigationBar.isHidden = true

        // 从本地加载模版列表

        loadTemplates()
    }

    private func initSubviews() {

        view.backgroundColor = .systemGroupedBackground

        // 初始化导航栏

        initNavigationBar()

        // 初始化「新建空白作品」按钮

        initNewBlankGameButton()

        // 初始化模版视图

        initTemplatesView()
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
        titleLabel.text = NSLocalizedString("StartComposing", comment: "")
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

    private func initNewBlankGameButton() {

        newBlankGameButton = RoundedButton(cornerRadius: GlobalViewLayoutConstants.defaultViewCornerRadius)
        newBlankGameButton.backgroundColor = .secondarySystemGroupedBackground
        newBlankGameButton.contentHorizontalAlignment = .center
        newBlankGameButton.contentVerticalAlignment = .center
        newBlankGameButton.setTitle(NSLocalizedString("NewBlankGame", comment: ""), for: .normal)
        newBlankGameButton.setTitleColor(.mgLabel, for: .normal)
        newBlankGameButton.titleLabel?.font = .systemFont(ofSize: ViewLayoutConstants.newBlankGameButtonTitleLabelFontSize, weight: .regular)
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
    }

    private func initTemplatesView() {

        // 初始化模版视图

        templatesView = UIView()
        view.addSubview(templatesView)
        templatesView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(8)
            make.top.equalTo(newBlankGameButton.snp.bottom).offset(48)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化模版标题标签

        let templatesTitleLabel: UILabel = UILabel()
        templatesTitleLabel.text = NSLocalizedString("SelectTemplate", comment: "")
        templatesTitleLabel.font = .systemFont(ofSize: ViewLayoutConstants.templatesTitleLabelFontSize, weight: .regular)
        templatesTitleLabel.textColor = .secondaryLabel
        templatesTitleLabel.textAlignment = .center
        templatesView.addSubview(templatesTitleLabel)
        templatesTitleLabel.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(8)
            make.top.equalToSuperview()
        }

        // 初始化模版集合视图

        templatesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        templatesCollectionView.backgroundColor = .clear
        templatesCollectionView.showsVerticalScrollIndicator = false
        templatesCollectionView.dataSource = self
        templatesCollectionView.delegate = self
        templatesCollectionView.register(TemplateCollectionViewCell.self, forCellWithReuseIdentifier: TemplateCollectionViewCell.reuseId)

        // 为模版集合视图添加刷新控制器

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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if templates.isEmpty {
            templatesCollectionView.showNoDataInfo(title: NSLocalizedString("NoTemplatesAvailable", comment: ""))
        } else {
            templatesCollectionView.hideNoDataInfo()
        }

        return templates.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TemplateCollectionViewCell.reuseId, for: indexPath) as? TemplateCollectionViewCell else {
            fatalError("Unexpected cell type")
        }

        if let template = templates[indexPath.item] as? MetaTemplate {

            // 准备标题标签

            cell.titleLabel.text = template.title

            // 准备缩略图视图

            cell.thumbImageView.pin_updateWithProgress = true
            let thumbURL = URL(string: "\(GlobalURLConstants.templateThumbsBaseURLString)/\(template.thumbFileName)")!
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

extension NewGameViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let template = templates[indexPath.item] as? MetaTemplate {

            print("[NewGame] did use template: \(template.bundleFileName)")

            let newGame: MetaGame = insertGame()
            editGame(game: newGame)
        }
    }
}

extension NewGameViewController: UICollectionViewDelegateFlowLayout {

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

        let cellSpacing = ViewLayoutConstants.templateCollectionViewCellSpacing

        templateCollectionViewCellWidth = ((collectionView.bounds.width - CGFloat(numberOfCellsPerRow + 1) * cellSpacing) / CGFloat(numberOfCellsPerRow)).rounded(.down)
        templateCollectionViewCellHeight = (templateCollectionViewCellWidth / GlobalViewLayoutConstants.defaultSceneAspectRatio).rounded(.down)

        return CGSize(width: templateCollectionViewCellWidth, height: templateCollectionViewCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let inset = ViewLayoutConstants.templateCollectionViewCellSpacing
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        let lineSpacing = ViewLayoutConstants.templateCollectionViewCellSpacing
        return lineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return ViewLayoutConstants.templateCollectionViewCellSpacing
    }
}

extension NewGameViewController {

    //
    //
    // MARK: - 界面操作
    //
    //

    @objc private func backButtonDidTap() {

        print("[NewGame] did tap backButton")

        navigationController?.popViewController(animated: true)
    }

    @objc private func newBlankGameButtonDidTap() {

        print("[NewGame] did tap newBlankGameButton")

        let newGame: MetaGame = insertGame()
        editGame(game: newGame)
    }

    @objc private func pullToRefreshTemplates() {

        syncTemplates()
        templatesCollectionView.refreshControl?.endRefreshing()
    }

    private func editGame(game: MetaGame) {

        guard let gameBundle = MetaGameBundleManager.shared.load(uuid: game.uuid) else { return }

        let gameEditorVC: GameEditorViewController = GameEditorViewController(game: game, gameBundle: gameBundle, parentType: .new)
        gameEditorVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(gameEditorVC, animated: true)
    }

    //
    //
    // MARK: - 数据操作
    //
    //

    private func insertGame() -> MetaGame {

        let game = MetaGame(context: persistentContainer.viewContext)
        game.uuid = UUID().uuidString.lowercased()
        game.ctime = Int64(Date().timeIntervalSince1970)
        game.mtime = game.ctime
        var counter: Int = UserDefaults.standard.integer(forKey: "LocalGamesCounter")
        counter = counter + 1
        UserDefaults.standard.setValue(counter, forKey: "LocalGamesCounter")
        game.title = NSLocalizedString("Draft", comment: "") + " " + counter.description
        game.status = 1
        games.append(game)
        saveContext()

        MetaGameBundleManager.shared.save(MetaGameBundle(uuid: game.uuid))

        return game
    }

    private func syncTemplates() {

        let templatesURL = URL(string: "\(GlobalURLConstants.templatesURLString)?page=1&sort_by=ctime&sort_order=ascending")!

        URLSession.shared.dataTask(with: templatesURL) { [weak self] data, _, error in
            guard let strongSelf = self, let data = data else { return }
            do {
                let decoder = JSONDecoder()
                decoder.userInfo[CodingUserInfoKey.context!] = strongSelf.persistentContainer.viewContext
                let templatesData = try decoder.decode([MetaTemplate].self, from: data)
                print("[NewGame] synchronize \(templatesData.count) meta templates: ok")
                strongSelf.saveContext()
                DispatchQueue.main.async {
                    strongSelf.loadTemplates()
                }
            } catch {
                print("[NewGame] synchronize meta templates error: \(error)")
            }
        }.resume()
    }

    private func loadTemplates() {

        let request: NSFetchRequest<MetaTemplate> = MetaTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "status == 1")
        request.sortDescriptors = [NSSortDescriptor(key: "ctime", ascending: false)]

        do {
            templates = try persistentContainer.viewContext.fetch(request)
            templatesCollectionView.reloadData()
            print("[NewGame] load meta templates: ok")
        } catch {
            print("[NewGame] load meta templates error: \(error)")
        }
    }

    private func saveContext() {

        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
                print("[NewGame] save meta games: ok")
            } catch {
                print("[NewGame] save meta games error: \(error)")
            }
        }
    }
}
