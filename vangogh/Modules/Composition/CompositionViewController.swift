///
/// CompositionViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

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

    /// 草稿视图
    var draftsView: UIView!
    /// 草稿表格视图
    var draftsTableView: UITableView!

    /// 草稿列表
    var drafts: [MetaGame] = [MetaGame]()
    /// 「草稿已保存」消息
    var draftSavedMessage: String?

    /// 视图加载完成
    override func viewDidLoad() {

        super.viewDidLoad()

        // 初始化视图

        initViews()
    }

    /// 视图即将显示
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // 隐藏导航栏

        navigationController?.navigationBar.isHidden = true

        // 加载草稿列表

        loadDrafts { [weak self] in

            guard let s = self else { return }

            // 重新加载「草稿表格视图」

            s.reloadDraftsTableView()
        }
    }

    /// 视图显示完成
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        // 显示消息

        showMessage()

        // 签署协议

        signAgreements()
    }

    /// 初始化视图
    private func initViews() {

        view.backgroundColor = .systemGroupedBackground

        // 初始化「设置按钮容器」

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

        // 初始化「设置按钮」

        let settingsButton: CircleNavigationBarButton = CircleNavigationBarButton(icon: .settings)
        settingsButton.addTarget(self, action: #selector(settingsButtonDidTap), for: .touchUpInside)
        settingsButtonContainer.addSubview(settingsButton)
        settingsButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.VC.width)
            make.left.equalToSuperview().offset(VC.topButtonContainerPadding)
            make.bottom.equalToSuperview().offset(-VC.topButtonContainerPadding)
        }

        // 初始化「创作按钮」

        let composeButton: RoundedButton = RoundedButton(cornerRadius: GVC.defaultViewCornerRadius)
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

        // 初始化「草稿视图」

        draftsView = UIView()
        view.addSubview(draftsView)
        draftsView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(composeButton.snp.bottom).offset(32)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化「草稿标题标签」

        let draftsTitleLabel: UILabel = UILabel()
        draftsTitleLabel.text = NSLocalizedString("Drafts", comment: "")
        draftsTitleLabel.font = .systemFont(ofSize: VC.draftsTitleLabelFontSize, weight: .regular)
        draftsTitleLabel.textColor = .secondaryLabel
        draftsView.addSubview(draftsTitleLabel)
        draftsTitleLabel.snp.makeConstraints { make -> Void in
            make.left.top.equalToSuperview()
        }

        // 初始化「草稿表格视图」

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

        return drafts.count
    }

    /// 设置单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // 准备「草稿表格视图」单元格

        return prepareDraftsTableViewCell(indexPath: indexPath)
    }
}

extension CompositionViewController: UITableViewDelegate {

    /// 设置单元格高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return VC.draftTableViewCellHeight
    }

    /// 选中单元格
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // 选择草稿

        selectDraft(drafts[indexPath.row])
    }
}

extension CompositionViewController {

    /// 准备「草稿表格视图」单元格
    func prepareDraftsTableViewCell(indexPath: IndexPath) -> UITableViewCell {

        let draft: MetaGame = drafts[indexPath.row]

        guard let cell = draftsTableView.dequeueReusableCell(withIdentifier: DraftTableViewCell.reuseId) as? DraftTableViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备「更多按钮」

        cell.moreButton.tag = indexPath.row
        cell.moreButton.addTarget(self, action: #selector(moreButtonDidTap), for: .touchUpInside)

        // 准备「标题标签」

        cell.titleLabel.text = draft.title

        // 准备「最近修改时间标签」

        let mtimeFormatter = DateFormatter()
        mtimeFormatter.dateStyle = .medium
        mtimeFormatter.timeStyle = .short
        cell.mtimeLabel.text = mtimeFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(draft.mtime)))

        // 准备「缩略图视图」

        cell.thumbImageView.image = .sceneBackgroundThumb

        return cell
    }
}
