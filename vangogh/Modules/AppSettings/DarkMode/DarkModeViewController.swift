///
/// DarkModeViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import OSLog
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

    /// 返回按钮容器
    private var backButtonContainer: UIView!
    /// 返回按钮
    private var backButton: CircleNavigationBarButton!

    /// 风格视图
    private var stylesView: RoundedView!
    /// 风格表格视图
    private var stylesTableView: UITableView!

    /// 风格列表
    private var styles: [UserInterfaceStyle]!

    /// 初始化
    init() {

        super.init(nibName: nil, bundle: nil)

        styles = UserInterfaceStyleManager.shared.get()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 视图加载完成
    override func viewDidLoad() {

        super.viewDidLoad()

        // 初始化视图

        initViews()
    }

    /// 初始化视图
    private func initViews() {

        view.backgroundColor = .systemGroupedBackground

        // 初始化「导航栏」

        initNavigationBar()

        // 初始化「设置视图」

        initSettingsView()
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

    /// 初始化「设置视图」
    private func initSettingsView() {

        // 初始化「设置视图」

        let settingsView: UIView = UIView()
        view.addSubview(settingsView)
        settingsView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(backButtonContainer.snp.bottom).offset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化「跟随系统视图」

        let followSystemView: RoundedView = RoundedView()
        followSystemView.backgroundColor = .secondarySystemGroupedBackground
        settingsView.addSubview(followSystemView)
        followSystemView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(VC.followSystemViewHeight)
            make.left.top.equalToSuperview()
        }

        // 初始化「跟随系统开关」

        let followSystemSwitchView: UISwitch = UISwitch()
        followSystemSwitchView.onTintColor = .accent
        followSystemSwitchView.setOn(!UserDefaults.standard.bool(forKey: GKC.ignoresSystemUserInterfaceStyle), animated: true)
        followSystemSwitchView.addTarget(self, action: #selector(followSystemUserInterfaceStyleSwitchViewDidChange), for: .valueChanged)
        followSystemView.addSubview(followSystemSwitchView)
        followSystemSwitchView.snp.makeConstraints { make -> Void in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }

        // 初始化「跟随系统标题标签」

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

        // 初始化「跟随系统信息标签」

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

        // 初始化「风格视图」

        stylesView = RoundedView()
        stylesView.isHidden = !UserDefaults.standard.bool(forKey: GKC.ignoresSystemUserInterfaceStyle)
        stylesView.backgroundColor = .secondarySystemGroupedBackground
        settingsView.addSubview(stylesView)
        stylesView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(followSystemView.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
        }

        // 初始化「选择风格标题标签」

        let selectModeTitleLabel: UILabel = UILabel()
        selectModeTitleLabel.text = NSLocalizedString("SelectManually", comment: "")
        selectModeTitleLabel.font = .systemFont(ofSize: VC.selectModeTitleLabelFontSize, weight: .regular)
        selectModeTitleLabel.textColor = .secondaryLabel
        stylesView.addSubview(selectModeTitleLabel)
        selectModeTitleLabel.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(24)
        }

        // 初始化「风格表格视图」

        stylesTableView = UITableView()
        stylesTableView.backgroundColor = .clear
        stylesTableView.separatorStyle = .none
        stylesTableView.showsVerticalScrollIndicator = false
        stylesTableView.alwaysBounceVertical = false
        stylesTableView.register(UserInterfaceStyleTableViewCell.self, forCellReuseIdentifier: UserInterfaceStyleTableViewCell.reuseId)
        stylesTableView.dataSource = self
        stylesTableView.delegate = self
        stylesView.addSubview(stylesTableView)
        stylesTableView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(selectModeTitleLabel.snp.bottom).offset(8)
        }
    }
}

extension DarkModeViewController: UITableViewDataSource {

    /// 设置单元格数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return styles.count
    }

    /// 设置单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellMode: UserInterfaceStyle = styles[indexPath.row]

        guard let cell = stylesTableView.dequeueReusableCell(withIdentifier: UserInterfaceStyleTableViewCell.reuseId) as? UserInterfaceStyleTableViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备「标题标签」

        cell.titleLabel.text = NSLocalizedString(cellMode.title, comment: "")

        let isInLightMode: Bool = UserDefaults.standard.bool(forKey: GKC.isInLightMode)
        if cellMode.type == .darkMode {
            cell.checkmarkView.isHidden = isInLightMode
        } else if cellMode.type == .lightMode {
            cell.checkmarkView.isHidden = !isInLightMode
        }

        return cell
    }
}

extension DarkModeViewController: UITableViewDelegate {

    /// 设置单元格高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return VC.settingTableViewCellHeight
    }

    /// 选中单元格
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // 选择用户界面风格

        selectUserInterfaceStyle(type: styles[indexPath.row].type)
    }
}

extension DarkModeViewController {

    /// 点击「返回按钮」
    @objc private func backButtonDidTap() {

        print("[DarkMode] did tap backButton")

        navigationController?.popViewController(animated: true)
    }

    @objc private func followSystemUserInterfaceStyleSwitchViewDidChange(_ sender: UISwitch) {

        print("[DarkMode] followed system user interface style: \(sender.isOn)")

        let followsSystemUserInterfaceStyle: Bool = sender.isOn

        UserDefaults.standard.setValue(!followsSystemUserInterfaceStyle, forKey: GKC.ignoresSystemUserInterfaceStyle)
        stylesView.isHidden = followsSystemUserInterfaceStyle

        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        if followsSystemUserInterfaceStyle { // 跟随系统
            window.overrideUserInterfaceStyle = .unspecified
        } else { // 不跟随系统
            selectUserInterfaceStyle(type: .darkMode) // 默认选择深色模式
        }
    }

    /// 选择用户界面风格
    private func selectUserInterfaceStyle(type: UserInterfaceStyle.UserInterfaceStyleType) {

        print("[DarkMode] selected user interface style: \(type)")

        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        if type == .darkMode {
            UserDefaults.standard.setValue(false, forKey: GKC.isInLightMode)
            window.overrideUserInterfaceStyle = .dark
        } else if type == .lightMode {
            UserDefaults.standard.setValue(true, forKey: GKC.isInLightMode)
            window.overrideUserInterfaceStyle = .light
        }

        stylesTableView.reloadData() // 修改深色模式以后，重新加载表格视图
    }
}
