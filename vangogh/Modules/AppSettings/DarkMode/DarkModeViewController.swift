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
        static let selectStyleTitleLabelFontSize: CGFloat = 14
        static let settingTableViewCellHeight: CGFloat = 64
    }

    /// 风格视图
    var stylesView: RoundedView!
    /// 风格表格视图
    var stylesTableView: UITableView!

    /// 风格列表
    var styles: [UserInterfaceStyle]!

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

        initViews()
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

        let followSystemSwitch: UISwitch = UISwitch()
        followSystemSwitch.onTintColor = .accent
        followSystemSwitch.setOn(!UserDefaults.standard.bool(forKey: GKC.ignoresSystemUserInterfaceStyle), animated: true)
        followSystemSwitch.addTarget(self, action: #selector(followSystemSwitchDidChange), for: .valueChanged)
        followSystemView.addSubview(followSystemSwitch)
        followSystemSwitch.snp.makeConstraints { make -> Void in
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
            make.right.equalTo(followSystemSwitch.snp.left).offset(-24)
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

        let selectStyleTitleLabel: UILabel = UILabel()
        selectStyleTitleLabel.text = NSLocalizedString("SelectManually", comment: "")
        selectStyleTitleLabel.font = .systemFont(ofSize: VC.selectStyleTitleLabelFontSize, weight: .regular)
        selectStyleTitleLabel.textColor = .secondaryLabel
        stylesView.addSubview(selectStyleTitleLabel)
        selectStyleTitleLabel.snp.makeConstraints { make -> Void in
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
            make.top.equalTo(selectStyleTitleLabel.snp.bottom).offset(8)
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

        return prepareStylesTableViewCell(indexPath: indexPath)
    }
}

extension DarkModeViewController: UITableViewDelegate {

    /// 设置单元格高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return VC.settingTableViewCellHeight
    }

    /// 选中单元格
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectUserInterfaceStyle(type: styles[indexPath.row].type)
    }
}

extension DarkModeViewController {

    /// 准备「风格表格视图」单元格
    func prepareStylesTableViewCell(indexPath: IndexPath) -> UITableViewCell {

        let style: UserInterfaceStyle = styles[indexPath.row]

        guard let cell = stylesTableView.dequeueReusableCell(withIdentifier: UserInterfaceStyleTableViewCell.reuseId) as? UserInterfaceStyleTableViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备「标题标签」

        cell.titleLabel.text = NSLocalizedString(style.title, comment: "")

        // 准备「勾选视图」

        let isInLightMode: Bool = UserDefaults.standard.bool(forKey: GKC.isInLightMode)
        if style.type == .darkMode {
            cell.checkmarkView.isHidden = isInLightMode
        } else if style.type == .lightMode {
            cell.checkmarkView.isHidden = !isInLightMode
        }

        return cell
    }
}
