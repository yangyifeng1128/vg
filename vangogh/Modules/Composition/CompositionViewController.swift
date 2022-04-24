///
/// CompositionViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AwaitToast
import CoreData
import OSLog
import SnapKit
import UIKit

class CompositionViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let topButtonContainerWidth: CGFloat = 64
        static let topButtonContainerPadding: CGFloat = 12
        static let composeButtonTitleLabelFontSize: CGFloat = 20
        static let draftsTitleLabelFontSize: CGFloat = 16
        static let draftTableViewCellHeight: CGFloat = 96
    }

    private var settingsButton: CircleNavigationBarButton! // 设置按钮
    private var composeButton: RoundedButton! // 创作按钮
    private var draftsView: UIView! // 草稿视图
    private var draftsTitleLabel: UILabel! // 草稿标题标签
    private var draftsTableView: UITableView! // 草稿表格视图

    private var games: [NSManagedObject] = [NSManagedObject]() // 作品列表

    var gameSavedMessage: String? // 「作品已保存」消息

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

        // 从本地加载作品列表

        loadGames()

        // 显示作品列表

        showGames()
    }

    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        // 显示消息

        showMessage()

        // 签署协议

        signAgreements()
    }

    private func showMessage() {

        if let message = gameSavedMessage {
            let toast: Toast = Toast.default(text: message)
            toast.show()
            gameSavedMessage = nil
        }
    }

    private func signAgreements() {

        let agreementsSigned: Bool = UserDefaults.standard.bool(forKey: "agreementsSigned")
        if !agreementsSigned {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.showAgreements()
            }
        }
    }

    //
    //
    // MARK: - 初始化子视图
    //
    //

    private func initViews() {

        view.backgroundColor = .systemGroupedBackground

        // 初始化导航栏

        initNavigationBar()

        // 初始化创作按钮

        initComposeButton()

        // 初始化草稿视图

        initDraftsView()
    }

    private func initNavigationBar() {

        // 初始化设置按钮

        let settingsButtonContainer: UIView = UIView()
        settingsButtonContainer.backgroundColor = .clear
        settingsButtonContainer.isUserInteractionEnabled = true
        settingsButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(settingsButtonDidTap)))
        view.addSubview(settingsButtonContainer)
        let settingsButtonContainerLeft: CGFloat = view.bounds.width - VC.topButtonContainerWidth
        settingsButtonContainer.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.topButtonContainerWidth)
            make.left.equalToSuperview().offset(settingsButtonContainerLeft)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        settingsButton = CircleNavigationBarButton(icon: .settings)
        settingsButton.addTarget(self, action: #selector(settingsButtonDidTap), for: .touchUpInside)
        settingsButtonContainer.addSubview(settingsButton)
        settingsButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.VC.width)
            make.left.equalToSuperview().offset(VC.topButtonContainerPadding)
            make.bottom.equalToSuperview().offset(-VC.topButtonContainerPadding)
        }
    }

    private func initComposeButton() {

        composeButton = RoundedButton(cornerRadius: GVC.defaultViewCornerRadius)
        composeButton.backgroundColor = .secondarySystemGroupedBackground
        composeButton.tintColor = .mgLabel
        composeButton.contentHorizontalAlignment = .center
        composeButton.contentVerticalAlignment = .center
        composeButton.setTitle(NSLocalizedString("StartComposing", comment: ""), for: .normal)
        composeButton.setTitleColor(.mgLabel, for: .normal)
        composeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        composeButton.titleLabel?.font = .systemFont(ofSize: VC.composeButtonTitleLabelFontSize, weight: .regular)
        composeButton.setImage(.open, for: .normal)
        composeButton.adjustsImageWhenHighlighted = false
        composeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        composeButton.imageView?.tintColor = .mgLabel
        composeButton.addTarget(self, action: #selector(composeButtonDidTap), for: .touchUpInside)
        view.addSubview(composeButton)
        var composeButtonHeight: CGFloat
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            composeButtonHeight = 120
            break
        case .pad, .mac, .tv, .carPlay, .unspecified:
            composeButtonHeight = 160
            break
        @unknown default:
            composeButtonHeight = 120
            break
        }
        composeButton.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(composeButtonHeight)
            make.centerY.equalToSuperview()
        }
    }

    private func initDraftsView() {

        draftsView = UIView()
        view.addSubview(draftsView)
        draftsView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(composeButton.snp.bottom).offset(32)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        draftsTitleLabel = UILabel()
        draftsTitleLabel.text = NSLocalizedString("Drafts", comment: "")
        draftsTitleLabel.font = .systemFont(ofSize: VC.draftsTitleLabelFontSize, weight: .regular)
        draftsTitleLabel.textColor = .secondaryLabel
        draftsView.addSubview(draftsTitleLabel)
        draftsTitleLabel.snp.makeConstraints { make -> Void in
            make.left.top.equalToSuperview()
        }

        draftsTableView = UITableView()
        draftsTableView.backgroundColor = .clear
        draftsTableView.separatorStyle = .none
        draftsTableView.showsVerticalScrollIndicator = false
        draftsTableView.alwaysBounceVertical = false
        draftsTableView.register(DraftTableViewCell.self, forCellReuseIdentifier: DraftTableViewCell.reuseId)
        draftsTableView.dataSource = self
        draftsTableView.delegate = self
        draftsView.addSubview(draftsTableView)
        draftsTableView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(draftsTitleLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
        }
    }
}

extension CompositionViewController: UITableViewDataSource {

    /// 设置单元格数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return games.count
    }

    /// 设置单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let game = games[indexPath.row] as? MetaGame else {
            fatalError("Unexpected cell index")
        }
        guard let cell = draftsTableView.dequeueReusableCell(withIdentifier: DraftTableViewCell.reuseId) as? DraftTableViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备「更多」按钮

        cell.moreButton.tag = indexPath.row
        cell.moreButton.addTarget(self, action: #selector(moreButtonDidTap), for: .touchUpInside)

        // 准备标题标签

        cell.titleLabel.text = game.title

        // 准备「最近修改时间」标签

        let mtimeFormatter = DateFormatter()
        mtimeFormatter.dateStyle = .medium
        mtimeFormatter.timeStyle = .short
        cell.mtimeLabel.text = mtimeFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(game.mtime)))

        // 准备缩略图视图

        cell.thumbImageView.image = .sceneBackgroundThumb

        return cell
    }
}

extension CompositionViewController: UITableViewDelegate {

    /// 设置单元格高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return VC.draftTableViewCellHeight
    }

    /// 选中单元格
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // 获取当前选中的作品

        guard let game = games[indexPath.row] as? MetaGame else { return }

        // 保存最近修改时间

        game.mtime = Int64(Date().timeIntervalSince1970)
        CoreDataManager.shared.saveContext()

        // 跳转至子视图

        editGame(game: game)
    }
}

extension CompositionViewController {

    //
    //
    // MARK: - 界面操作
    //
    //

    @objc private func settingsButtonDidTap() {

        print("[Composition] did tap settingsButton")

        showAppSettings()
    }

    @objc private func composeButtonDidTap() {

        print("[Composition] did tap composeButton")

        newGame()
    }

    @objc private func moreButtonDidTap(sender: UIButton) {

        print("[Composition] did tap moreButton")

        showMoreAboutGame(sender: sender)
    }

    private func showAgreements() {

        let agreementsVC: AgreementsViewController = AgreementsViewController()
        let agreementsNav: UINavigationController = UINavigationController(rootViewController: agreementsVC)
        agreementsNav.modalPresentationStyle = .overFullScreen
        agreementsNav.modalTransitionStyle = .crossDissolve

        present(agreementsNav, animated: true, completion: nil)
    }

    private func showAppSettings() {

        let settingsVC: AppSettingsViewController = AppSettingsViewController()
        settingsVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(settingsVC, animated: true)
    }

    private func newGame() {

        let newGameVC: NewGameViewController = NewGameViewController(games: games)
        newGameVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(newGameVC, animated: true)
    }

    private func editGame(game: MetaGame) {

        guard let gameBundle = MetaGameBundleManager.shared.load(uuid: game.uuid) else { return }

        let gameEditorVC: GameEditorViewController = GameEditorViewController(game: game, gameBundle: gameBundle, parentType: .draft)
        gameEditorVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(gameEditorVC, animated: true)
    }

    private func showMoreAboutGame(sender: UIButton) {

        let index = sender.tag
        guard let game = games[index] as? MetaGame else { return }

        // 弹出提示框

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // 编辑草稿标题

        alert.addAction(UIAlertAction(title: NSLocalizedString("EditTitle", comment: ""), style: .default) { [weak self] _ in

                guard let strongSelf = self else { return }

                // 弹出编辑草稿标题提示框

                let editDraftTitleAlert = UIAlertController(title: NSLocalizedString("EditGameTitle", comment: ""), message: nil, preferredStyle: .alert)
                editDraftTitleAlert.addTextField { textField in
                    textField.text = game.title
                    textField.font = .systemFont(ofSize: GVC.alertTextFieldFontSize, weight: .regular)
                    textField.returnKeyType = .done
                    textField.delegate = self
                }

                editDraftTitleAlert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { _ in
                        guard let title = editDraftTitleAlert.textFields?.first?.text, !title.isEmpty else {
                            let toast = Toast.default(text: NSLocalizedString("EmptyTitleNotAllowed", comment: ""))
                            toast.show()
                            return
                        }
                        game.title = title
                        CoreDataManager.shared.saveContext()
                        strongSelf.draftsTableView.reloadData()
                    })

                editDraftTitleAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
                    })

                strongSelf.present(editDraftTitleAlert, animated: true, completion: nil)
            })

        // 删除草稿

        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .default) { [weak self] _ in

                guard let strongSelf = self else { return }

                // 弹出删除草稿提示框

                let deleteDraftAlert = UIAlertController(title: NSLocalizedString("DeleteGame", comment: ""), message: NSLocalizedString("DeleteGameInfo", comment: ""), preferredStyle: .alert)

                deleteDraftAlert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { _ in
                        strongSelf.deleteGame(index: index)
                        strongSelf.draftsTableView.reloadData()
                        strongSelf.showGames()
                    })

                deleteDraftAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
                    })

                strongSelf.present(deleteDraftAlert, animated: true, completion: nil)
            })

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            })

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        } // 兼容 iPad 应用

        present(alert, animated: true, completion: nil)
    }

    //
    //
    // MARK: - 数据操作
    //
    //

    /// 加载作品
    private func loadGames() {

        let request: NSFetchRequest<MetaGame> = MetaGame.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "mtime", ascending: false)]

        do {
            games = try CoreDataManager.shared.persistentContainer.viewContext.fetch(request)
            draftsTableView.reloadData()
            Logger.composition.info("loading meta games: ok")
        } catch {
            Logger.composition.info("loading meta games error: \(error.localizedDescription)")
        }
    }

    private func showGames() {

        if !games.isEmpty {

            draftsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            draftsView.isHidden = false

        } else {

            draftsView.isHidden = true
        }
    }

    private func deleteGame(index: Int) {

        guard let game = games[index] as? MetaGame else { return }

        MetaGameBundleManager.shared.delete(uuid: game.uuid)

        games.remove(at: index)
        draftsTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        CoreDataManager.shared.persistentContainer.viewContext.delete(game)
        CoreDataManager.shared.saveContext()

        Logger.composition.info("delete meta game at index \(index): ok")
    }
}

extension CompositionViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        if range.length + range.location > text.count { return false }
        let newLength = text.count + string.count - range.length
        return newLength <= 255
    }
}
