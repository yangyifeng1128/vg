///
/// SceneEmulatorTransitionViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class SceneEmulatorTransitionViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let topButtonContainerWidth: CGFloat = 64
        static let topButtonContainerPadding: CGFloat = 12
        static let titleLabelFontSize: CGFloat = 20
        static let nextScenesTitleLabelFontSize: CGFloat = 16
        static let nextSceneDescriptorCollectionViewCellSpacing: CGFloat = 24
    }

    /// 关闭按钮容器
    var closeButtonContainer: UIView!
    /// 关闭按钮
    var closeButton: CircleNavigationBarButton!

    /// 标题标签
    var titleLabel: UILabel!
    /// 后续场景描述符集合视图
    var nextSceneDescriptorsCollectionView: UICollectionView!

    /// 场景资源包
    var sceneBundle: MetaSceneBundle!
    /// 作品资源包
    var gameBundle: MetaGameBundle!
    /// 后续场景描述符列表
    var nextSceneDescriptors: [NextSceneDescriptor] = [NextSceneDescriptor]()

    /// 后续计时器
    var upNextTimer: Timer?
    /// 后续时间
    var upNextTimeSeconds: Int = 5

    /// 初始化
    init(sceneBundle: MetaSceneBundle, gameBundle: MetaGameBundle) {

        super.init(nibName: nil, bundle: nil)

        self.sceneBundle = sceneBundle
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

        // 加载后续场景描述符列表

        loadNextSceneDescriptors() { [weak self] in
            guard let s = self else { return }
            s.nextSceneDescriptorsCollectionView.reloadData()
        }

        // 开启后续计时器

        startUpNextTimer()
    }

    /// 视图即将消失
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        // 停止后续计时器

        stopUpNextTimer()
    }

    /// 隐藏状态栏
    override var prefersStatusBarHidden: Bool {

        return true
    }

    /// 初始化视图
    private func initViews() {

        view.backgroundColor = SceneEmulatorPlayerView.VC.backgroundColor

        // 初始化「关闭按钮容器」

        closeButtonContainer = UIView()
        closeButtonContainer.backgroundColor = .clear
        closeButtonContainer.isUserInteractionEnabled = true
        closeButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeButtonDidTap)))
        view.addSubview(closeButtonContainer)
        closeButtonContainer.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.topButtonContainerWidth)
            make.left.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        // 初始化「关闭按钮」

        closeButton = CircleNavigationBarButton(icon: .close, backgroundColor: GVC.defaultSceneControlBackgroundColor, tintColor: .white)
        closeButton.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
        closeButtonContainer.addSubview(closeButton)
        closeButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.VC.width)
            make.right.bottom.equalToSuperview().offset(-VC.topButtonContainerPadding)
        }

        // 初始化「标题标签」

        titleLabel = UILabel()
        titleLabel.text = prepareTitleLabelText()
        titleLabel.font = .systemFont(ofSize: VC.titleLabelFontSize, weight: .regular)
        titleLabel.textColor = .mgLabel
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(160)
        }

        // 初始化「后续场景描述符集合视图」

        nextSceneDescriptorsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        nextSceneDescriptorsCollectionView.backgroundColor = .clear
        nextSceneDescriptorsCollectionView.showsVerticalScrollIndicator = false
        nextSceneDescriptorsCollectionView.register(NextSceneDescriptorCollectionViewCell.self, forCellWithReuseIdentifier: NextSceneDescriptorCollectionViewCell.reuseId)
        nextSceneDescriptorsCollectionView.dataSource = self
        nextSceneDescriptorsCollectionView.delegate = self
        view.addSubview(nextSceneDescriptorsCollectionView)
        nextSceneDescriptorsCollectionView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(120)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
}

extension SceneEmulatorTransitionViewController: UICollectionViewDataSource {

    /// 设置单元格数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return prepareNextSceneDescriptorsCount()
    }

    /// 设置单元格
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        return prepareNextSceneDescriptorCollectionViewCell(indexPath: indexPath)
    }
}

extension SceneEmulatorTransitionViewController: UICollectionViewDelegate {

    /// 选中单元格
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        selectNextSceneDescriptorCollectionViewCell(indexPath: indexPath)
    }

    /// 滚动视图
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        switchToManualTransition()
    }
}

extension SceneEmulatorTransitionViewController: UICollectionViewDelegateFlowLayout {

    /// 设置单元格尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return prepareNextSceneDescriptorCollectionViewCellSize(indexPath: indexPath)
    }

    /// 设置内边距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let inset = VC.nextSceneDescriptorCollectionViewCellSpacing
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }

    /// 设置最小行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return VC.nextSceneDescriptorCollectionViewCellSpacing
    }

    /// 设置最小单元格间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return VC.nextSceneDescriptorCollectionViewCellSpacing
    }
}
