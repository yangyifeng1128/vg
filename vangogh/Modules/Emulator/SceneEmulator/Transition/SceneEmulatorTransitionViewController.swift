///
/// SceneEmulatorTransitionViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class SceneEmulatorTransitionViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let defaultButtonHeight: CGFloat = 56
        static let titleLabelFontSize: CGFloat = 22
        static let nextScenesTitleLabelFontSize: CGFloat = 16
        static let nextSceneCollectionViewCellSpacing: CGFloat = 8
    }

    /// 默认按钮
    var defaultButton: RoundedButton!
    /// 后续场景集合视图
    var nextScenesCollectionView: UICollectionView!

    /// 作品资源包
    var gameBundle: MetaGameBundle!
    /// 后续场景列表
    var nextScenes: [MetaScene] = [MetaScene]()

    /// 初始化
    init(gameBundle: MetaGameBundle) {

        super.init(nibName: nil, bundle: nil)

        self.gameBundle = gameBundle
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

        // 加载目标场景列表

        loadNextScenes() { [weak self] in
            guard let s = self else { return }
            s.nextScenesCollectionView.reloadData()
        }
    }

    /// 初始化视图
    private func initViews() {

        // 初始化「默认按钮」

        defaultButton = RoundedButton()
        defaultButton.backgroundColor = .secondarySystemGroupedBackground
        defaultButton.tintColor = .mgLabel
        defaultButton.contentHorizontalAlignment = .center
        defaultButton.contentVerticalAlignment = .center
        defaultButton.setTitle(NSLocalizedString("StartComposing", comment: ""), for: .normal)
        defaultButton.setTitleColor(.mgLabel, for: .normal)
        defaultButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
//        defaultButton.titleLabel?.font = .systemFont(ofSize: VC.composeButtonTitleLabelFontSize, weight: .regular)
        defaultButton.setImage(.open, for: .normal)
        defaultButton.adjustsImageWhenHighlighted = false
        defaultButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        defaultButton.imageView?.tintColor = .mgLabel
        defaultButton.addTarget(self, action: #selector(defaultButtonDidTap), for: .touchUpInside)
        view.addSubview(defaultButton)
        defaultButton.snp.makeConstraints { make -> Void in
            make.height.equalTo(VC.defaultButtonHeight)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化「标题标签」

        let titleLabel: UILabel = UILabel()
        titleLabel.text = NSLocalizedString("About", comment: "")
        titleLabel.font = .systemFont(ofSize: VC.titleLabelFontSize, weight: .regular)
        titleLabel.textColor = .mgLabel
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
        }

        // 初始化「后续场景集合视图」

        nextScenesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        nextScenesCollectionView.backgroundColor = .clear
        nextScenesCollectionView.showsVerticalScrollIndicator = false
        nextScenesCollectionView.register(NextSceneCollectionViewCell.self, forCellWithReuseIdentifier: NextSceneCollectionViewCell.reuseId)
        nextScenesCollectionView.dataSource = self
        nextScenesCollectionView.delegate = self
        view.addSubview(nextScenesCollectionView)
        nextScenesCollectionView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.bottom.equalTo(defaultButton.snp.top).offset(-16)
        }
    }
}

extension SceneEmulatorTransitionViewController: UICollectionViewDataSource {

    /// 设置单元格数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return prepareNextScenesCount()
    }

    /// 设置单元格
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        return prepareNextSceneCollectionViewCell(indexPath: indexPath)
    }
}

extension SceneEmulatorTransitionViewController: UICollectionViewDelegate {

    /// 选中单元格
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        selectNextSceneCollectionViewCell(indexPath: indexPath)
    }
}

extension SceneEmulatorTransitionViewController: UICollectionViewDelegateFlowLayout {

    /// 设置单元格尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return prepareNextSceneCollectionViewCellSize(indexPath: indexPath)
    }

    /// 设置内边距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let inset = VC.nextSceneCollectionViewCellSpacing
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }

    /// 设置最小行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return VC.nextSceneCollectionViewCellSpacing
    }

    /// 设置最小单元格间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return VC.nextSceneCollectionViewCellSpacing
    }
}