///
/// AppSettingsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class AppSettingsViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let topButtonContainerWidth: CGFloat = 64
        static let topButtonContainerPadding: CGFloat = 12
        static let titleLabelFontSize: CGFloat = 16
        static let copyrightLabelHeight: CGFloat = 96
        static let copyrightLabelFontSize: CGFloat = 14
        static let settingTableViewCellHeight: CGFloat = 80
    }

    /// 返回按钮容器
    private var backButtonContainer: UIView!
    /// 返回按钮
    private var backButton: CircleNavigationBarButton!

    /// 版权标签
    private var copyrightLabel: UILabel!
    /// 设置表格视图
    private var settingsTableView: UITableView!

    /// 设置列表
    private var settings: [AppSetting]!

    /// 初始化
    init() {

        super.init(nibName: nil, bundle: nil)

        settings = AppSettingManager.shared.get()
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
        titleLabel.text = NSLocalizedString("AppSettings", comment: "")
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

        // 初始化「版权标签」

        copyrightLabel = UILabel()
        let appName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
        copyrightLabel.text = appName + " \(NSLocalizedString("Version", comment: "")) " + GVC.appVersion
        copyrightLabel.font = .systemFont(ofSize: VC.copyrightLabelFontSize, weight: .regular)
        copyrightLabel.textColor = .tertiaryLabel
        copyrightLabel.textAlignment = .center
        settingsView.addSubview(copyrightLabel)
        copyrightLabel.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(VC.copyrightLabelHeight)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        // 初始化「设置表格视图容器」

        let settingsTableViewContainer: RoundedView = RoundedView()
        settingsTableViewContainer.backgroundColor = .secondarySystemGroupedBackground
        settingsView.addSubview(settingsTableViewContainer)
        settingsTableViewContainer.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(copyrightLabel.snp.top)
        }

        // 初始化「设置表格视图」

        settingsTableView = UITableView()
        settingsTableView.backgroundColor = .clear
        settingsTableView.separatorStyle = .none
        settingsTableView.showsVerticalScrollIndicator = false
        settingsTableView.alwaysBounceVertical = false
        settingsTableView.register(AppSettingTableViewCell.self, forCellReuseIdentifier: AppSettingTableViewCell.reuseId)
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

extension AppSettingsViewController: UITableViewDataSource {

    /// 设置单元格数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return settings.count
    }

    /// 设置单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = settingsTableView.dequeueReusableCell(withIdentifier: AppSettingTableViewCell.reuseId) as? AppSettingTableViewCell else {
            fatalError("Unexpected cell type")
        }

        let setting: AppSetting = settings[indexPath.row]

        // 准备标题标签

        cell.titleLabel.text = setting.title

        return cell
    }
}

extension AppSettingsViewController: UITableViewDelegate {

    /// 设置单元格高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return VC.settingTableViewCellHeight
    }

    /// 选中单元格
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // 选择应用程序设置

        selectAppSetting(settings[indexPath.row])
    }
}

extension AppSettingsViewController {

    /// 点击「返回按钮」
    @objc private func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }

    /// 选择应用程序设置
    func selectAppSetting(_ setting: AppSetting) {

        var vc: UIViewController

        switch setting.type {
        case .generalSettings:
            vc = GeneralSettingsViewController()
            break
        case .feedback:
            vc = FeedbackViewController()
            break
        case .termsOfService:
            vc = TermsOfServiceViewController()
            break
        case .privacyPolicy:
            vc = PrivacyPolicyViewController()
            break
        case .about:
            vc = AboutViewController()
            break
        }

        vc.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(vc, animated: true)
    }
}
