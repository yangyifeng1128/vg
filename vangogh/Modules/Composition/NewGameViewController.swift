///
/// NewGameViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import CoreData
import Kingfisher
import OSLog
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

    private var backButtonContainer: UIView!
    private var backButton: CircleNavigationBarButton!
    private var titleLabel: UILabel!

    private var newBlankGameButton: RoundedButton!
    private var templatesView: UIView!
    private var templatesCollectionView: UICollectionView!
    private var templateCollectionViewCellWidth: CGFloat!
    private var templateCollectionViewCellHeight: CGFloat!

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

        // 初始化视图

        initViews()
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // 隐藏导航栏

        navigationController?.navigationBar.isHidden = true

        // 从本地加载模版列表

        loadTemplates()
    }

    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        // 同步模版

        syncTemplates() { [weak self] in

            guard let s = self else { return }

            s.loadTemplates() {
                s.templatesCollectionView.reloadData()
            }
        }
    }

    private func initViews() {

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
            make.width.height.equalTo(VC.topButtonContainerWidth)
            make.left.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        backButton = CircleNavigationBarButton(icon: .arrowBack)
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        backButtonContainer.addSubview(backButton)
        backButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.VC.width)
            make.right.bottom.equalToSuperview().offset(-VC.topButtonContainerPadding)
        }

        // 初始化标题标签

        titleLabel = UILabel()
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
    }

    private func initNewBlankGameButton() {

        newBlankGameButton = RoundedButton(cornerRadius: GVC.defaultViewCornerRadius)
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
        templatesTitleLabel.font = .systemFont(ofSize: VC.templatesTitleLabelFontSize, weight: .regular)
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

            let thumbURL = URL(string: "\(GUC.templateThumbsBaseURLString)/\(template.thumbFileName)")!
            cell.thumbImageView.kf.setImage(with: thumbURL)
        }

        return cell
    }
}

extension NewGameViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let template = templates[indexPath.item] as? MetaTemplate {

            // 添加作品

            addGame { [weak self] game in

                guard let s = self else { return }

                // 打开作品编辑器

                s.openGameEditor(game: game)
                Logger.composition.info("created a new game with template: \(template.title)")
            }
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

        let cellSpacing = VC.templateCollectionViewCellSpacing

        templateCollectionViewCellWidth = ((collectionView.bounds.width - CGFloat(numberOfCellsPerRow + 1) * cellSpacing) / CGFloat(numberOfCellsPerRow)).rounded(.down)
        templateCollectionViewCellHeight = (templateCollectionViewCellWidth / GVC.defaultSceneAspectRatio).rounded(.down)

        return CGSize(width: templateCollectionViewCellWidth, height: templateCollectionViewCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let inset = VC.templateCollectionViewCellSpacing
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        let lineSpacing = VC.templateCollectionViewCellSpacing
        return lineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return VC.templateCollectionViewCellSpacing
    }
}

extension NewGameViewController {

    //
    //
    // MARK: - 界面操作
    //
    //

    /// 点击「返回按钮」
    @objc private func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }

    @objc private func newBlankGameButtonDidTap() {

        print("[NewGame] did tap newBlankGameButton")

        // 添加作品

        addGame { [weak self] game in

            guard let s = self else { return }

            // 打开作品编辑器

            s.openGameEditor(game: game)
            Logger.composition.info("created a new blank game")
        }
    }

    @objc private func pullToRefreshTemplates() {

        // 同步模版

        syncTemplates() { [weak self] in

            guard let s = self else { return }

            // 加载模版

            s.loadTemplates() {
                s.templatesCollectionView.reloadData()
                s.templatesCollectionView.refreshControl?.endRefreshing()
            }
        }
    }

    private func openGameEditor(game: MetaGame) {

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

    private func addGame(completion handler: ((MetaGame) -> Void)? = nil) {

        let game: MetaGame = MetaGame(context: CoreDataManager.shared.persistentContainer.viewContext)
        game.uuid = UUID().uuidString.lowercased()
        game.ctime = Int64(Date().timeIntervalSince1970)
        game.mtime = game.ctime
        var counter: Int = UserDefaults.standard.integer(forKey: GKC.localGamesCounter)
        counter = counter + 1
        UserDefaults.standard.setValue(counter, forKey: GKC.localGamesCounter)
        game.title = NSLocalizedString("Draft", comment: "") + " " + counter.description
        game.status = 1
        games.append(game)
        CoreDataManager.shared.saveContext()

        MetaGameBundleManager.shared.save(MetaGameBundle(uuid: game.uuid))

        if let handler = handler {
            DispatchQueue.main.async {
                handler(game)
            }
        }
    }

    private func syncTemplates(completion handler: (() -> Void)? = nil) {

        let templatesURL = URL(string: "\(GUC.templatesURLString)?page=1&sort_by=ctime&sort_order=ascending")!

        URLSession.shared.dataTask(with: templatesURL) { data, _, error in

            guard let data = data else { return }

            do {
                let decoder = JSONDecoder()
                decoder.userInfo[CodingUserInfoKey.context!] = CoreDataManager.shared.persistentContainer.viewContext
                let templatesData = try decoder.decode([MetaTemplate].self, from: data)
                Logger.composition.info("synchronizing \(templatesData.count) templates: ok")
                CoreDataManager.shared.saveContext()
                if let handler = handler {
                    DispatchQueue.main.async {
                        handler()
                    }
                }
            } catch {
                Logger.composition.error("synchronizing templates error: \(error.localizedDescription)")
            }

        }.resume()
    }

    private func loadTemplates(completion handler: (() -> Void)? = nil) {

        let request: NSFetchRequest<MetaTemplate> = MetaTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "status == 1")
        request.sortDescriptors = [NSSortDescriptor(key: "ctime", ascending: false)]

        do {
            templates = try CoreDataManager.shared.persistentContainer.viewContext.fetch(request)
            Logger.composition.info("loading meta templates: ok")
        } catch {
            Logger.composition.error("loading meta templates error: \(error.localizedDescription)")
        }

        if let handler = handler {
            DispatchQueue.main.async {
                handler()
            }
        }
    }
}
