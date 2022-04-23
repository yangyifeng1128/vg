///
/// GameSettingsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AwaitToast
import CoreData
import SnapKit
import UIKit

class GameSettingsViewController: UIViewController {

    /// 视图布局常量枚举值
    enum ViewLayoutConstants {
        static let topButtonContainerWidth: CGFloat = 64
        static let topButtonContainerPadding: CGFloat = 12
        static let titleLabelFontSize: CGFloat = 16
        static let settingTableViewCellHeight: CGFloat = 80
    }

    private var backButtonContainer: UIView!
    private var backButton: CircleNavigationBarButton!
    private var titleLabel: UILabel!

    private var settingsView: UIView! // 作品设置视图
    private var settingsTableView: UITableView! // 作品设置表格视图

    private var persistentContainer: NSPersistentContainer = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate!.persistentContainer
    }() // 持久化容器
    private var game: MetaGame! // 作品

    private var settings: [GameSetting]!

    init(game: MetaGame) {

        super.init(nibName: nil, bundle: nil)

        self.game = game

        settings = GameSettingManager.shared.get()
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

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // 隐藏导航栏

        navigationController?.navigationBar.isHidden = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)
    }

    private func initSubviews() {

        view.backgroundColor = .systemGroupedBackground

        // 初始化导航栏

        initNavigationBar()

        // 初始化作品设置视图

        initSettingsView()
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
        titleLabel.text = NSLocalizedString("GameSettings", comment: "")
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

    private func initSettingsView() {

        // 初始化作品设置视图

        settingsView = UIView()
        view.addSubview(settingsView)
        settingsView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(backButtonContainer.snp.bottom).offset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化作品设置表格视图

        let settingsTableViewContainer: RoundedView = RoundedView()
        settingsTableViewContainer.backgroundColor = .secondarySystemGroupedBackground
        settingsView.addSubview(settingsTableViewContainer)
        settingsTableViewContainer.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        settingsTableView = UITableView()
        settingsTableView.backgroundColor = .clear
        settingsTableView.separatorStyle = .none
        settingsTableView.showsVerticalScrollIndicator = false
        settingsTableView.alwaysBounceVertical = false
        settingsTableView.register(GameSettingTableViewCell.self, forCellReuseIdentifier: GameSettingTableViewCell.reuseId)
        settingsTableView.register(GameSettingTableThumbImageViewCell.self, forCellReuseIdentifier: GameSettingTableThumbImageViewCell.reuseId)
        settingsTableView.dataSource = self
        settingsTableView.delegate = self
        settingsTableViewContainer.addSubview(settingsTableView)
        settingsTableView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(8)
        }
    }
}

extension GameSettingsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return settings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let setting: GameSetting = settings[indexPath.row]

        if setting.type == .gameThumbImage {

            guard let cell = settingsTableView.dequeueReusableCell(withIdentifier: GameSettingTableThumbImageViewCell.reuseId) as? GameSettingTableThumbImageViewCell else {
                fatalError("Unexpected cell type")
            }

            cell.titleLabel.text = setting.title

            if let thumbImage = MetaThumbManager.shared.loadGameThumbImage(gameUUID: game.uuid) {
                DispatchQueue.main.async {
                    cell.thumbImageView.image = thumbImage
                }
            } else {
                cell.thumbImageView.image = .gameBackgroundThumb
            }

            return cell

        } else {

            guard let cell = settingsTableView.dequeueReusableCell(withIdentifier: GameSettingTableViewCell.reuseId) as? GameSettingTableViewCell else {
                fatalError("Unexpected cell type")
            }

            cell.titleLabel.text = setting.title

            switch setting.type {
            case .gameTitle:
                var infoString: String?
                if !game.title.isEmpty {
                    infoString = game.title
                } else {
                    infoString = NSLocalizedString("Untitled", comment: "")
                }
                cell.infoLabel.text = infoString
                break
            default:
                break
            }

            return cell
        }
    }
}

extension GameSettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return ViewLayoutConstants.settingTableViewCellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let setting = settings[indexPath.row]

        switch setting.type {
        case .gameThumbImage:

            editGameThumbImage()
            break

        case .gameTitle:

            guard let cell = tableView.cellForRow(at: indexPath) as? GameSettingTableViewCell else { return }
            editGameTitle(sourceView: cell.infoLabel)
            break
        }
    }
}

extension GameSettingsViewController {

    //
    //
    // MARK: - 界面操作
    //
    //

    @objc private func backButtonDidTap() {

        print("[GameSettings] did tap backButton")

        navigationController?.popViewController(animated: true)
    }

    private func editGameThumbImage() {

        print("[GameSettings] will edit game thumb image")
    }

    private func editGameTitle(sourceView: UIView) {

        // 弹出编辑作品标题提示框

        let alert = UIAlertController(title: NSLocalizedString("EditGameTitle", comment: ""), message: nil, preferredStyle: .alert)

        alert.addTextField { [weak self] textField in

            guard let strongSelf = self else { return }

            textField.font = .systemFont(ofSize: GlobalViewLayoutConstants.alertTextFieldFontSize, weight: .regular)
            textField.text = strongSelf.game.title
            textField.returnKeyType = .done
            textField.delegate = self
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { [weak self] _ in

            guard let strongSelf = self else { return }

            guard let title = alert.textFields?.first?.text, !title.isEmpty else {
                let toast = Toast.default(text: NSLocalizedString("EmptyTitleNotAllowed", comment: ""))
                toast.show()
                return
            }

            // 保存作品标题

            strongSelf.game.title = title
            strongSelf.saveContext()
            strongSelf.settingsTableView.reloadData()
            GameboardViewExternalChangeManager.shared.set(key: .updateGameTitle, value: nil) // 保存「作品板视图外部变更记录字典」
        })

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
        })

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView.bounds
        } // 兼容 iPad 应用

        present(alert, animated: true, completion: nil)
    }

    //
    //
    // MARK: - 数据操作
    //
    //

    private func saveContext() {

        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
                print("[GameSettings] save meta game: ok")
            } catch {
                print("[GameSettings] save meta game error: \(error)")
            }
        }
    }
}

extension GameSettingsViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard let text = textField.text else { return true }

        if range.length + range.location > text.count { return false }
        let newLength = text.count + string.count - range.length

        return newLength <= 255
    }
}
