///
/// DarkModeViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class DarkModeViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let topButtonContainerWidth: CGFloat = 64
        static let topButtonContainerPadding: CGFloat = 12
        static let titleLabelFontSize: CGFloat = 16
        static let followSystemViewHeight: CGFloat = 112
        static let followSystemTitleLabelFontSize: CGFloat = 16
        static let followSystemInfoLabelFontSize: CGFloat = 14
        static let selectModeTitleLabelFontSize: CGFloat = 14
        static let settingTableViewCellHeight: CGFloat = 64
    }

    private var backButtonContainer: UIView!
    private var backButton: CircleNavigationBarButton!
    private var titleLabel: UILabel!

    private var settingsView: UIView!
    private var followSystemView: UIView!
    private var settingsTableViewContainer: RoundedView!
    private var settingsTableView: UITableView!

    private var modes: [UserInterfaceStyle]!
    init() {

        super.init(nibName: nil, bundle: nil)

        modes = UserInterfaceStyleManager.shared.get()
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
        titleLabel.text = NSLocalizedString("DarkMode", comment: "")
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

        // 初始化跟随系统视图

        initFollowSystemView()

        // 初始化设置表格视图

        initSettingsTableView()
    }

    private func initFollowSystemView() {

        followSystemView = RoundedView()
        followSystemView.backgroundColor = .secondarySystemGroupedBackground
        settingsView.addSubview(followSystemView)
        followSystemView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(VC.followSystemViewHeight)
            make.left.top.equalToSuperview()
        }

        let followSystemSwitchView: UISwitch = UISwitch()
        followSystemSwitchView.onTintColor = .accent
        followSystemSwitchView.setOn(!UserDefaults.standard.bool(forKey: "ignoresSystemUserInterfaceStyle"), animated: true)
        followSystemSwitchView.addTarget(self, action: #selector(followSystemUserInterfaceStyleSwitchViewDidChange), for: .valueChanged)
        followSystemView.addSubview(followSystemSwitchView)
        followSystemSwitchView.snp.makeConstraints { make -> Void in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }

        let followSystemTitleLabel: UILabel = UILabel()
        followSystemTitleLabel.text = NSLocalizedString("FollowSystem", comment: "")
        followSystemTitleLabel.font = .systemFont(ofSize: VC.followSystemTitleLabelFontSize, weight: .regular)
        followSystemTitleLabel.textColor = .mgLabel
        followSystemView.addSubview(followSystemTitleLabel)
        followSystemTitleLabel.snp.makeConstraints { make -> Void in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(followSystemSwitchView.snp.left).offset(-24)
        }

        let followSystemInfoLabel: UILabel = UILabel()
        followSystemInfoLabel.text = NSLocalizedString("FollowSystemInfo", comment: "")
        followSystemInfoLabel.font = .systemFont(ofSize: VC.followSystemInfoLabelFontSize, weight: .regular)
        followSystemInfoLabel.textColor = .secondaryLabel
        followSystemInfoLabel.numberOfLines = 3
        followSystemView.addSubview(followSystemInfoLabel)
        followSystemInfoLabel.snp.makeConstraints { make -> Void in
            make.top.equalTo(followSystemTitleLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-12)
            make.left.right.equalTo(followSystemTitleLabel)
        }
    }

    private func initSettingsTableView() {

        settingsTableViewContainer = RoundedView()
        settingsTableViewContainer.isHidden = !UserDefaults.standard.bool(forKey: "ignoresSystemUserInterfaceStyle")
        settingsTableViewContainer.backgroundColor = .secondarySystemGroupedBackground
        settingsView.addSubview(settingsTableViewContainer)
        settingsTableViewContainer.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(followSystemView.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
        }

        let selectModeTitleLabel: UILabel = UILabel()
        selectModeTitleLabel.text = NSLocalizedString("SelectManually", comment: "")
        selectModeTitleLabel.font = .systemFont(ofSize: VC.selectModeTitleLabelFontSize, weight: .regular)
        selectModeTitleLabel.textColor = .secondaryLabel
        settingsTableViewContainer.addSubview(selectModeTitleLabel)
        selectModeTitleLabel.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(24)
        }

        settingsTableView = UITableView()
        settingsTableView.backgroundColor = .clear
        settingsTableView.separatorStyle = .none
        settingsTableView.showsVerticalScrollIndicator = false
        settingsTableView.alwaysBounceVertical = false
        settingsTableView.register(DarkModeTableViewCell.self, forCellReuseIdentifier: DarkModeTableViewCell.reuseId)
        settingsTableView.dataSource = self
        settingsTableView.delegate = self
        settingsTableViewContainer.addSubview(settingsTableView)
        settingsTableView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(selectModeTitleLabel.snp.bottom).offset(8)
        }
    }
}

extension DarkModeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return modes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellMode: UserInterfaceStyle = modes[indexPath.row]

        guard let cell = settingsTableView.dequeueReusableCell(withIdentifier: DarkModeTableViewCell.reuseId) as? DarkModeTableViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备标题标签

        cell.titleLabel.text = NSLocalizedString(cellMode.title, comment: "")

        let isInLightMode: Bool = UserDefaults.standard.bool(forKey: "isInLightMode")
        if cellMode.type == .darkMode {
            cell.checkmarkView.isHidden = isInLightMode
        } else if cellMode.type == .lightMode {
            cell.checkmarkView.isHidden = !isInLightMode
        }

        return cell
    }
}

extension DarkModeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return VC.settingTableViewCellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectUserInterfaceStyle(type: modes[indexPath.row].type) // 手动选择模式
    }
}

extension DarkModeViewController {

    @objc private func backButtonDidTap() {

        print("[DarkMode] did tap backButton")

        navigationController?.popViewController(animated: true)
    }

    @objc private func followSystemUserInterfaceStyleSwitchViewDidChange(_ sender: UISwitch) {

        print("[DarkMode] followed system user interface style: \(sender.isOn)")

        let followsSystemUserInterfaceStyle: Bool = sender.isOn

        UserDefaults.standard.setValue(!followsSystemUserInterfaceStyle, forKey: "ignoresSystemUserInterfaceStyle")
        settingsTableViewContainer.isHidden = followsSystemUserInterfaceStyle

        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        if followsSystemUserInterfaceStyle { // 跟随系统
            window.overrideUserInterfaceStyle = .unspecified
        } else { // 不跟随系统
            selectUserInterfaceStyle(type: .darkMode) // 默认选择深色模式
        }
    }

    private func selectUserInterfaceStyle(type: UserInterfaceStyle.UserInterfaceStyleType) {

        print("[DarkMode] selected user interface style: \(type)")

        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        if type == .darkMode {
            UserDefaults.standard.setValue(false, forKey: "isInLightMode")
            window.overrideUserInterfaceStyle = .dark
        } else if type == .lightMode {
            UserDefaults.standard.setValue(true, forKey: "isInLightMode")
            window.overrideUserInterfaceStyle = .light
        }

        settingsTableView.reloadData() // 修改深色模式以后，重新加载表格视图
    }
}
