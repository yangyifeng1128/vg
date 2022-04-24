///
/// SceneSettingsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AwaitToast
import SnapKit
import UIKit

class SceneSettingsViewController: UIViewController {

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

    private var sceneBundle: MetaSceneBundle!
    private var gameBundle: MetaGameBundle!

    private var settings: [SceneSetting]!

    init(sceneBundle: MetaSceneBundle, gameBundle: MetaGameBundle) {

        super.init(nibName: nil, bundle: nil)

        self.sceneBundle = sceneBundle
        self.gameBundle = gameBundle

        settings = SceneSettingManager.shared.get()
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

        // 单独强制设置状态栏风格

        navigationController?.navigationBar.barStyle = (overrideUserInterfaceStyle == .dark) ? .black : .default
    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        // 简化处理：无论是否修改过场景设置，此处均重新初始化「场景编辑器」视图控制器

        resetParentViewControllers()
    }

    private func resetParentViewControllers() {

        let newSceneEditorVC = SceneEditorViewController(sceneBundle: sceneBundle, gameBundle: gameBundle)
        navigationController?.viewControllers[0] = newSceneEditorVC
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)
    }

    private func initViews() {

        view.backgroundColor = .systemGroupedBackground

        // 初始化导航栏

        initNavigationBar()

        // 初始化场景设置视图

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
        titleLabel.text = NSLocalizedString("SceneSettings", comment: "")
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

        // 初始化场景设置视图

        settingsView = UIView()
        view.addSubview(settingsView)
        settingsView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(backButtonContainer.snp.bottom).offset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化场景设置表格视图

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
        settingsTableView.register(SceneSettingTableViewCell.self, forCellReuseIdentifier: SceneSettingTableViewCell.reuseId)
        settingsTableView.register(SceneSettingTableThumbImageViewCell.self, forCellReuseIdentifier: SceneSettingTableThumbImageViewCell.reuseId)
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

extension SceneSettingsViewController: UITableViewDataSource {

    /// 设置单元格数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return settings.count
    }

    /// 设置单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let setting: SceneSetting = settings[indexPath.row]

        if setting.type == .sceneThumbImage {

            guard let cell = settingsTableView.dequeueReusableCell(withIdentifier: SceneSettingTableThumbImageViewCell.reuseId) as? SceneSettingTableThumbImageViewCell else {
                fatalError("Unexpected cell type")
            }

            cell.titleLabel.text = setting.title

            if let thumbImage = MetaThumbManager.shared.loadSceneThumbImage(sceneUUID: sceneBundle.sceneUUID, gameUUID: sceneBundle.gameUUID) {
                DispatchQueue.main.async {
                    cell.thumbImageView.image = thumbImage
                }
            } else {
                cell.thumbImageView.image = .sceneBackgroundThumb
            }

            return cell

        } else {

            guard let cell = settingsTableView.dequeueReusableCell(withIdentifier: SceneSettingTableViewCell.reuseId) as? SceneSettingTableViewCell else {
                fatalError("Unexpected cell type")
            }

            cell.titleLabel.text = setting.title

            switch setting.type {
            case .sceneTitle:
                var infoString: String?
                if let sceneTitle = gameBundle.selectedScene()?.title, !sceneTitle.isEmpty {
                    infoString = sceneTitle
                } else {
                    infoString = NSLocalizedString("Untitled", comment: "")
                }
                cell.infoLabel.text = infoString
                break
            case .aspectRatio:
                cell.infoLabel.text = sceneBundle.aspectRatioType.rawValue
                break
            default:
                break
            }

            return cell
        }
    }
}

extension SceneSettingsViewController: UITableViewDelegate {

    /// 设置单元格高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return VC.settingTableViewCellHeight
    }

    /// 选中单元格
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let setting = settings[indexPath.row]

        switch setting.type {
        case .sceneThumbImage:

            editSceneThumbImage()
            break

        case .sceneTitle:

            guard let cell = tableView.cellForRow(at: indexPath) as? SceneSettingTableViewCell else { return }
            editSceneTitle(sourceView: cell.infoLabel)
            break

        case .aspectRatio:

            guard let cell = tableView.cellForRow(at: indexPath) as? SceneSettingTableViewCell else { return }
            editAspectRatio(sourceView: cell.infoLabel)
            break
        }
    }
}

extension SceneSettingsViewController {

    /// 点击「返回按钮」
    @objc private func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }

    private func editSceneThumbImage() {

        print("[SceneSettings] will edit scene thumb image")
    }

    private func editSceneTitle(sourceView: UIView) {

        // 弹出编辑场景标题提示框

        let alert = UIAlertController(title: NSLocalizedString("EditSceneTitle", comment: ""), message: nil, preferredStyle: .alert)

        alert.addTextField { [weak self] textField in

            guard let strongSelf = self else { return }

            textField.font = .systemFont(ofSize: GVC.alertTextFieldFontSize, weight: .regular)
            textField.text = strongSelf.gameBundle.selectedScene()?.title
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

                // 保存「当前选中场景」的标题

                guard let scene = strongSelf.gameBundle.selectedScene() else { return }
                scene.title = title
                strongSelf.gameBundle.updateScene(scene)
                DispatchQueue.global(qos: .background).async {
                    MetaGameBundleManager.shared.save(strongSelf.gameBundle)
                }
                strongSelf.settingsTableView.reloadData()
                GameboardViewExternalChangeManager.shared.set(key: .updateSceneTitle, value: scene.uuid) // 保存「作品板视图外部变更记录字典」
            })

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            })

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView.bounds
        } // 兼容 iPad 应用

        present(alert, animated: true, completion: nil)
    }

    private func editAspectRatio(sourceView: UIView) {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for aspectRatioType in MetaSceneAspectRatioType.allCases {
            alert.addAction(UIAlertAction(title: aspectRatioType.rawValue, style: .default) { [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.sceneBundle.aspectRatioType = aspectRatioType
                    DispatchQueue.global(qos: .background).async {
                        MetaSceneBundleManager.shared.save(strongSelf.sceneBundle)
                    }
                    strongSelf.settingsTableView.reloadData()
                })
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            })

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView.bounds
        } // 兼容 iPad 应用

        present(alert, animated: true, completion: nil)
    }
}

extension SceneSettingsViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard let text = textField.text else { return true }

        if range.length + range.location > text.count { return false }
        let newLength = text.count + string.count - range.length

        return newLength <= 255
    }
}
