///
/// AppSettingsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class AppSettingsViewController: UIViewController {

    // 视图布局常量枚举值

    enum ViewLayoutConstants {
        static let topButtonContainerWidth: CGFloat = 64
        static let topButtonContainerPadding: CGFloat = 12
        static let titleLabelFontSize: CGFloat = 16
        static let copyrightLabelHeight: CGFloat = 96
        static let copyrightLabelFontSize: CGFloat = 14
        static let settingTableViewCellHeight: CGFloat = 80
    }

    private var backButtonContainer: UIView!
    private var backButton: CircleNavigationBarButton!
    private var titleLabel: UILabel!

    private var settingsView: UIView!
    private var settingsTableView: UITableView!
    private var copyrightLabel: UILabel!

    private var settings: [AppSetting]!

    init() {

        super.init(nibName: nil, bundle: nil)

        settings = AppSettingManager.shared.get()
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)
    }

    private func initSubviews() {

        view.backgroundColor = .systemGroupedBackground

        // 初始化导航栏

        initNavigationBar()

        // 初始化应用设置视图

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
        titleLabel.text = NSLocalizedString("AppSettings", comment: "")
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

        // 初始化设置视图

        settingsView = UIView()
        view.addSubview(settingsView)
        settingsView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(backButtonContainer.snp.bottom).offset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化版权标签

        copyrightLabel = UILabel()
        let appName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
        copyrightLabel.text = appName + " \(NSLocalizedString("Version", comment: "")) " + GlobalValueConstants.appVersion
        copyrightLabel.font = .systemFont(ofSize: ViewLayoutConstants.copyrightLabelFontSize, weight: .regular)
        copyrightLabel.textColor = .tertiaryLabel
        copyrightLabel.textAlignment = .center
        settingsView.addSubview(copyrightLabel)
        copyrightLabel.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(ViewLayoutConstants.copyrightLabelHeight)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        // 初始化设置表格视图

        let settingsTableViewContainer: RoundedView = RoundedView()
        settingsTableViewContainer.backgroundColor = .secondarySystemGroupedBackground
        settingsView.addSubview(settingsTableViewContainer)
        settingsTableViewContainer.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(copyrightLabel.snp.top)
        }

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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return settings.count
    }

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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return ViewLayoutConstants.settingTableViewCellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let setting = settings[indexPath.row]

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

extension AppSettingsViewController {

    @objc private func backButtonDidTap() {

        print("[AppSettings] did tap backButton")

        navigationController?.popViewController(animated: true)
    }
}
