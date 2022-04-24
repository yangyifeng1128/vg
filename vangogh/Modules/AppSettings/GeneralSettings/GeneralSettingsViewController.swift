///
/// GeneralSettingsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class GeneralSettingsViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let topButtonContainerWidth: CGFloat = 64
        static let topButtonContainerPadding: CGFloat = 12
        static let titleLabelFontSize: CGFloat = 16
        static let settingTableViewCellHeight: CGFloat = 80
    }

    private var backButtonContainer: UIView!
    private var backButton: CircleNavigationBarButton!
    private var titleLabel: UILabel!

    private var settingsView: UIView!
    private var settingsTableView: UITableView!

    private var settings: [GeneralSetting]!

    init() {

        super.init(nibName: nil, bundle: nil)

        settings = GeneralSettingManager.shared.get()
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

        settingsTableView.reloadData() // 修改深色模式以后返回到这里，重新加载表格视图
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)
    }

    private func initViews() {

        view.backgroundColor = .systemGroupedBackground

        // 初始化导航栏

        initNavigationBar()

        // 初始化设置视图

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
        titleLabel.text = NSLocalizedString("GeneralSettings", comment: "")
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

    private func initSettingsView() {

        // 初始化设置视图

        settingsView = UIView()
        view.addSubview(settingsView)
        settingsView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(backButtonContainer.snp.bottom).offset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化设置表格视图

        let settingsTableViewContainer: RoundedView = RoundedView()
        settingsTableViewContainer.backgroundColor = .secondarySystemGroupedBackground
        settingsView.addSubview(settingsTableViewContainer)
        settingsTableViewContainer.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }

        settingsTableView = UITableView()
        settingsTableView.backgroundColor = .clear
        settingsTableView.separatorStyle = .none
        settingsTableView.showsVerticalScrollIndicator = false
        settingsTableView.alwaysBounceVertical = false
        settingsTableView.register(GeneralSettingTableViewCell.self, forCellReuseIdentifier: GeneralSettingTableViewCell.reuseId)
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

extension GeneralSettingsViewController: UITableViewDataSource {

    /// 设置单元格数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return settings.count
    }

    /// 设置单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let setting: GeneralSetting = settings[indexPath.row]

        guard let cell = settingsTableView.dequeueReusableCell(withIdentifier: GeneralSettingTableViewCell.reuseId) as? GeneralSettingTableViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备标题标签

        cell.titleLabel.text = setting.title

        if setting.type == .darkMode {
            if !UserDefaults.standard.bool(forKey: GKC.ignoresSystemUserInterfaceStyle) {
                cell.infoLabel.text = NSLocalizedString("FollowSystem", comment: "")
            } else {
                cell.infoLabel.text = UserDefaults.standard.bool(forKey: GKC.isInLightMode) ? NSLocalizedString("Disabled", comment: "") : NSLocalizedString("Enabled", comment: "")
            }
        }

        return cell
    }
}

extension GeneralSettingsViewController: UITableViewDelegate {

    /// 设置单元格高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return VC.settingTableViewCellHeight
    }

    /// 选中单元格
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let setting = settings[indexPath.row]

        var vc: UIViewController
        switch setting.type {
        case .darkMode:
            vc = DarkModeViewController()
            break
        }

        vc.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(vc, animated: true)
    }
}

extension GeneralSettingsViewController {

    @objc private func backButtonDidTap() {

        print("[GeneralSettings] did tap backButton")

        navigationController?.popViewController(animated: true)
    }
}
