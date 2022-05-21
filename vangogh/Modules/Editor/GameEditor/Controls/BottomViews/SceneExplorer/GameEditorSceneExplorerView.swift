///
/// GameEditorSceneExplorerView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class GameEditorSceneExplorerView: BorderedView {

    /// 视图布局常量枚举值
    enum VC {
        static let contentViewHeight: CGFloat = {
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                return 336
            case .pad, .mac, .tv, .carPlay, .unspecified:
                return UIScreen.main.bounds.height * 0.4
            @unknown default:
                return 336
            }
        }()
        static let rightTopButtonWidth: CGFloat = 48
        static let sceneTitleLabelFontSize: CGFloat = 16
        static let manageTransitionsButtonWidth: CGFloat = 160
        static let manageTransitionsButtonHeight: CGFloat = /* 32 */ 16
        static let manageTransitionsButtonMinHeight: CGFloat = 8
        static let manageTransitionsButtonTitleLabelFontSize: CGFloat = 14
        static let bottomButtonHeight: CGFloat = 56
        static let bottomButtonTitleLabelFontSize: CGFloat = 18
        static let previewSceneButtonWidth: CGFloat = UIScreen.main.bounds.width * 0.32
        static let transitionTableViewCellHeight: CGFloat = 72
    }

    /// 数据源
    weak var dataSource: GameEditorSceneExplorerViewDataSource? {
        didSet { reloadData() }
    }
    /// 代理
    weak var delegate: GameEditorSceneExplorerViewDelegate?

    /// 场景标题标签
    var sceneTitleLabel: UILabel!
    /// 穿梭器视图
    var transitionsView: RoundedView!
    /// 管理穿梭器按钮
    var manageTransitionsButton: UIButton!
    /// 穿梭器表格视图
    var transitionsTableView: UITableView!

    /// 初始化
    init() {

        super.init(side: .top)

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        // 初始化「内容视图」

        let contentView: UIView = UIView()
        contentView.backgroundColor = .systemBackground
        addSubview(contentView)
        contentView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(GameEditorSceneExplorerView.VC.contentViewHeight)
            make.left.top.equalToSuperview()
        }

        // 初始化「关闭场景按钮」

        let closeSceneButton: UIButton = UIButton()
        closeSceneButton.tintColor = .secondaryLabel
        closeSceneButton.setImage(.close, for: .normal)
        closeSceneButton.imageView?.tintColor = .secondaryLabel
        closeSceneButton.addTarget(self, action: #selector(closeSceneButtonDidTap), for: .touchUpInside)
        contentView.addSubview(closeSceneButton)
        closeSceneButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.rightTopButtonWidth)
            make.right.equalToSuperview().offset(-8)
            make.top.equalToSuperview().offset(8)
        }

        // 初始化「删除场景按钮」

        let deleteSceneButton: UIButton = UIButton()
        deleteSceneButton.tintColor = .secondaryLabel
        deleteSceneButton.setImage(.delete, for: .normal)
        deleteSceneButton.imageView?.tintColor = .secondaryLabel
        deleteSceneButton.addTarget(self, action: #selector(deleteSceneButtonDidTap), for: .touchUpInside)
        contentView.addSubview(deleteSceneButton)
        deleteSceneButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.rightTopButtonWidth)
            make.right.equalTo(closeSceneButton.snp.left)
            make.top.equalTo(closeSceneButton)
        }

        // 初始化「场景标题标签」

        sceneTitleLabel = UILabel()
        sceneTitleLabel.attributedText = prepareSceneTitleLabelAttributedText()
        sceneTitleLabel.font = .systemFont(ofSize: VC.sceneTitleLabelFontSize, weight: .regular)
        sceneTitleLabel.numberOfLines = 2
        sceneTitleLabel.lineBreakMode = .byTruncatingTail
        sceneTitleLabel.isUserInteractionEnabled = true
        sceneTitleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sceneTitleLabelDidTap)))
        contentView.addSubview(sceneTitleLabel)
        sceneTitleLabel.snp.makeConstraints { make -> Void in
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(deleteSceneButton.snp.left).offset(-8)
            make.top.equalTo(closeSceneButton).offset(14)
        }

        // 初始化「运行场景按钮」

        let previewSceneButton: RoundedButton = RoundedButton()
        previewSceneButton.backgroundColor = .accent
        previewSceneButton.tintColor = .mgHoneydew
        previewSceneButton.setTitle(NSLocalizedString("Preview", comment: ""), for: .normal)
        previewSceneButton.setTitleColor(.mgHoneydew, for: .normal)
        previewSceneButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        previewSceneButton.titleLabel?.font = .systemFont(ofSize: VC.bottomButtonTitleLabelFontSize, weight: .regular)
        previewSceneButton.setImage(.emulate, for: .normal)
        previewSceneButton.adjustsImageWhenHighlighted = false
        previewSceneButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        previewSceneButton.imageView?.tintColor = .mgHoneydew
        previewSceneButton.addTarget(self, action: #selector(previewSceneButtonDidTap), for: .touchUpInside)
        contentView.addSubview(previewSceneButton)
        previewSceneButton.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.previewSceneButtonWidth)
            make.height.equalTo(VC.bottomButtonHeight)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化「编辑场景按钮」

        let editSceneButton: RoundedButton = RoundedButton()
        editSceneButton.backgroundColor = .secondarySystemBackground
        editSceneButton.tintColor = .mgLabel
        editSceneButton.setTitle(NSLocalizedString("EditScene", comment: ""), for: .normal)
        editSceneButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        editSceneButton.titleLabel?.font = .systemFont(ofSize: VC.bottomButtonTitleLabelFontSize, weight: .regular)
        editSceneButton.setTitleColor(.mgLabel, for: .normal)
        editSceneButton.setImage(.edit, for: .normal)
        editSceneButton.adjustsImageWhenHighlighted = false
        editSceneButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        editSceneButton.imageView?.tintColor = .mgLabel
        editSceneButton.addTarget(self, action: #selector(editSceneButtonDidTap), for: .touchUpInside)
        contentView.addSubview(editSceneButton)
        editSceneButton.snp.makeConstraints { make -> Void in
            make.height.equalTo(VC.bottomButtonHeight)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(previewSceneButton.snp.left).offset(-12)
            make.bottom.equalTo(previewSceneButton)
        }

        // 初始化「穿梭器视图」

        transitionsView = RoundedView()
        transitionsView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(transitionsView)
        transitionsView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(sceneTitleLabel.snp.bottom).offset(16)
            make.bottom.equalTo(previewSceneButton.snp.top).offset(-16)
        }

        // 初始化「管理穿梭器按钮」

        manageTransitionsButton = UIButton()
        manageTransitionsButton.tintColor = .secondaryLabel
        manageTransitionsButton.contentHorizontalAlignment = .right
        manageTransitionsButton.setTitle(NSLocalizedString("Manage", comment: ""), for: .normal)
        manageTransitionsButton.titleLabel?.font = .systemFont(ofSize: VC.manageTransitionsButtonTitleLabelFontSize, weight: .regular)
        manageTransitionsButton.setTitleColor(.secondaryLabel, for: .normal)
        manageTransitionsButton.setImage(.openInNew, for: .normal)
        manageTransitionsButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 0)
        manageTransitionsButton.imageView?.contentMode = .scaleAspectFit
        manageTransitionsButton.imageView?.tintColor = .secondaryLabel
        manageTransitionsButton.addTarget(self, action: #selector(manageTransitionsButtonDidTap), for: .touchUpInside)
        transitionsView.addSubview(manageTransitionsButton)
        manageTransitionsButton.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.manageTransitionsButtonWidth)
            make.height.equalTo(VC.manageTransitionsButtonHeight)
            make.right.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview()
        }

        // 初始化「穿梭器表格视图」

        transitionsTableView = UITableView()
        transitionsTableView.backgroundColor = .clear
        transitionsTableView.separatorStyle = .none
        transitionsTableView.showsVerticalScrollIndicator = false
        transitionsTableView.alwaysBounceVertical = false
        transitionsTableView.register(GameEditorTransitionTableViewCell.self, forCellReuseIdentifier: GameEditorTransitionTableViewCell.reuseId)
        transitionsTableView.dataSource = self
        transitionsTableView.delegate = self
        transitionsView.addSubview(transitionsTableView)
        transitionsTableView.snp.makeConstraints { make -> Void in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(VC.manageTransitionsButtonMinHeight)
            make.bottom.equalTo(manageTransitionsButton.snp.top)
        }
    }
}

extension GameEditorSceneExplorerView: UITableViewDataSource {

    /// 设置单元格数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return prepareTransitionsCount()
    }

    /// 设置单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let dataSource = dataSource else { fatalError("Unexpected data source") }
        return dataSource.transitionTableViewCell(tableView: transitionsTableView, at: indexPath)
    }
}

extension GameEditorSceneExplorerView: UITableViewDelegate {

    /// 设置单元格高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return VC.transitionTableViewCellHeight
    }

    /// 选中单元格
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        delegate?.transitionTableViewCellDidSelect(transitionsTableView, indexPath: indexPath)
    }
}
