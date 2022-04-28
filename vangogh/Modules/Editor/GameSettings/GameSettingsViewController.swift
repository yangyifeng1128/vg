///
/// GameSettingsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class GameSettingsViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let topButtonContainerWidth: CGFloat = 64
        static let topButtonContainerPadding: CGFloat = 12
        static let titleLabelFontSize: CGFloat = 16
        static let settingTableViewCellHeight: CGFloat = 80
    }

    /// 设置表格视图
    var settingsTableView: UITableView!

    /// 作品
    var game: MetaGame!
    /// 设置列表
    var settings: [GameSetting]!

    /// 初始化
    init(game: MetaGame) {

        super.init(nibName: nil, bundle: nil)

        self.game = game

        settings = GameSettingManager.shared.get()
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
        titleLabel.text = NSLocalizedString("GameSettings", comment: "")
        titleLabel.font = .systemFont(ofSize: VC.titleLabelFontSize, weight: .regular)
        titleLabel.textColor = .mgLabel
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.centerY.equalTo(backButton)
            make.left.equalTo(backButtonContainer.snp.right).offset(8)
        }

        // 初始化「设置视图」

        let settingsView: UIView = UIView()
        view.addSubview(settingsView)
        settingsView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(backButtonContainer.snp.bottom).offset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化「设置表格视图容器」

        let settingsTableViewContainer: RoundedView = RoundedView()
        settingsTableViewContainer.backgroundColor = .secondarySystemGroupedBackground
        settingsView.addSubview(settingsTableViewContainer)
        settingsTableViewContainer.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        // 初始化「设置表格视图」

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

    /// 设置单元格数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return settings.count
    }

    /// 设置单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return prepareSettingsTableViewCell(indexPath: indexPath)
    }
}

extension GameSettingsViewController: UITableViewDelegate {

    /// 设置单元格高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return VC.settingTableViewCellHeight
    }

    /// 选中单元格
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

    /// 准备「设置表格视图」单元格
    func prepareSettingsTableViewCell(indexPath: IndexPath) -> UITableViewCell {

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
