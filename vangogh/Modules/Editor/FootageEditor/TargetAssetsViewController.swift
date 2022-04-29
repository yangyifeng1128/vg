///
/// TargetAssetsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Photos
import SnapKit
import UIKit

class TargetAssetsViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let topButtonContainerWidth: CGFloat = 64
        static let topButtonContainerPadding: CGFloat = 12
        static let titleLabelFontSize: CGFloat = 16
        static let menuControlTitleTextFontSize: CGFloat = 13
        static let targetAssetsCollectionViewInsetX: CGFloat = 4
        static let targetAssetsCollectionViewCellSpacing: CGFloat = 8
    }

    /// 代理
    weak var delegate: TargetAssetsViewControllerDelegate?

    /// 菜单控制器
    var menuControl: UISegmentedControl!
    /// 目标素材集合视图
    var targetAssetsCollectionView: UICollectionView!
    /// 目标素材集合视图单元格尺寸
    var targetAssetsCollectionViewCellSize: CGSize!

    /// 菜单项
    var menuItems: [String] = [NSLocalizedString("Pictures", comment: ""), NSLocalizedString("Videos", comment: "")]
    /// 素材列表
    var assets: PHFetchResult<PHAsset> = PHFetchResult()
    /// 图像管理器
    var imageManager: PHCachingImageManager = PHCachingImageManager()
    /// 先前的预加载矩形区域
    var previousPreheatRect: CGRect = .zero

    /// 初始化
    init() {

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 反初始化
    deinit {

        PHPhotoLibrary.shared().unregisterChangeObserver(self)
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

        // 单独强制设置状态栏风格

        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        navigationController?.navigationBar.barStyle = (window.overrideUserInterfaceStyle == .dark) ? .black : .default

        // 重置缓存素材列表

        resetCachedAssets()

        // 加载素材列表

        loadAssets(menuItemIndex: menuControl.selectedSegmentIndex)

        // 监听相册是否发生变化

        PHPhotoLibrary.shared().register(self)
    }

    /// 视图显示完成
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        // 更新缓存素材列表

        updateCachedAssets()
    }

    /// 视图即将消失
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        // 禁止「场景编辑器视图控制器」在 viewDidAppear 中重新加载播放器
        // 我们会在 TargetAssetsViewControllerDelegate.assetDidPick 中重新加载播放器

        if let parent = navigationController?.viewControllers[0] as? SceneEditorViewController {
            parent.needsReloadPlayer = false
        }
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
        titleLabel.text = NSLocalizedString("AddAsset", comment: "")
        titleLabel.font = .systemFont(ofSize: VC.titleLabelFontSize, weight: .regular)
        titleLabel.textColor = .mgLabel
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.centerY.equalTo(backButton)
            make.left.equalTo(backButtonContainer.snp.right).offset(8)
        }

        // 初始化「菜单控制器」

        menuControl = UISegmentedControl(items: menuItems)
        menuControl.selectedSegmentIndex = 0
        menuControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: VC.menuControlTitleTextFontSize, weight: .regular)], for: .normal)
        menuControl.addTarget(self, action: #selector(menuControlDidChange), for: .valueChanged)
        view.addSubview(menuControl)
        menuControl.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview().dividedBy(2)
            make.centerX.equalToSuperview()
            make.top.equalTo(backButtonContainer.snp.bottom).offset(8)
        }

        // 初始化「素材集合视图」

        prepareTargetAssetsCollectionViewCellSize()

        targetAssetsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        targetAssetsCollectionView.backgroundColor = .clear
        targetAssetsCollectionView.showsVerticalScrollIndicator = false
        targetAssetsCollectionView.dataSource = self
        targetAssetsCollectionView.delegate = self
        targetAssetsCollectionView.register(TargetAssetCollectionViewCell.self, forCellWithReuseIdentifier: TargetAssetCollectionViewCell.reuseId)
        view.addSubview(targetAssetsCollectionView)
        targetAssetsCollectionView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(VC.targetAssetsCollectionViewInsetX)
            make.top.equalTo(menuControl.snp.bottom).offset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        let swipeLeftGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(collectionViewDidSwipeLeft))
        swipeLeftGesture.direction = .left
        targetAssetsCollectionView.addGestureRecognizer(swipeLeftGesture)

        let swipeRightGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(collectionViewDidSwipeRight))
        swipeRightGesture.direction = .right
        targetAssetsCollectionView.addGestureRecognizer(swipeRightGesture)
    }
}

extension TargetAssetsViewController: UICollectionViewDataSource {

    /// 设置单元格数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return prepareTargetAssetsCount()
    }

    /// 设置单元格
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        return prepareTargetAssetsCollectionViewCell(indexPath: indexPath)
    }
}

extension TargetAssetsViewController: UICollectionViewDelegate {

    /// 选中单元格
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) as? TargetAssetCollectionViewCell else { return }
        selectTargetAsset(assets[indexPath.item], cell: cell)
    }
}

extension TargetAssetsViewController: UICollectionViewDelegateFlowLayout {

    /// 设置单元格尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return targetAssetsCollectionViewCellSize
    }

    /// 设置内边距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let inset = VC.targetAssetsCollectionViewCellSpacing
        return UIEdgeInsets(top: 0, left: inset, bottom: inset, right: inset)
    }

    /// 设置最小行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return VC.targetAssetsCollectionViewCellSpacing
    }

    /// 设置最小单元格间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return VC.targetAssetsCollectionViewCellSpacing
    }

    /// 滚动视图
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        updateCachedAssets()
    }
}

extension TargetAssetsViewController {

    /// 准备目标素材数量
    private func prepareTargetAssetsCount() -> Int {

        if assets.count == 0 {
            var noDataInfoTitle: String = NSLocalizedString("NoPicturesAvailable", comment: "")
            switch menuControl.selectedSegmentIndex {
            case 0:
                noDataInfoTitle = NSLocalizedString("NoPicturesAvailable", comment: "")
                break
            case 1:
                noDataInfoTitle = NSLocalizedString("NoVideosAvailable", comment: "")
                break
            default:
                break
            }
            targetAssetsCollectionView.showNoDataInfo(title: noDataInfoTitle)
        } else {
            targetAssetsCollectionView.hideNoDataInfo()
        }

        return assets.count
    }

    /// 准备「目标素材集合视图」单元格
    private func prepareTargetAssetsCollectionViewCell(indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = targetAssetsCollectionView.dequeueReusableCell(withReuseIdentifier: TargetAssetCollectionViewCell.reuseId, for: indexPath) as? TargetAssetCollectionViewCell else {
            fatalError("Unexpected cell type")
        }

        let asset = assets.object(at: indexPath.item)

        // 准备「缩略图视图」

        cell.assetIdentifier = asset.localIdentifier

        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        let scale = UIScreen.main.scale
        let targetSize: CGSize = CGSize(width: targetAssetsCollectionViewCellSize.width * scale, height: targetAssetsCollectionViewCellSize.height * scale)
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (image, info) in
            if cell.assetIdentifier == asset.localIdentifier {
                cell.thumbImageView.image = image
            }
        }

        // 准备「视频时长标签」

        if asset.mediaType == .video {
            cell.videoDurationLabel.isHidden = false
            let formatter: DateComponentsFormatter = DateComponentsFormatter()
            formatter.unitsStyle = .positional
            formatter.allowedUnits = [.minute, .second]
            formatter.zeroFormattingBehavior = [.pad]
            cell.videoDurationLabel.text = formatter.string(from: asset.duration)
        } else {
            cell.videoDurationLabel.isHidden = true
            cell.videoDurationLabel.text = ""
        }

        return cell
    }

    /// 准备「目标素材集合视图」单元格尺寸
    private func prepareTargetAssetsCollectionViewCellSize() {

        var numberOfCellsPerRow: Int
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            numberOfCellsPerRow = 3
            break
        case .pad, .mac, .tv, .carPlay, .unspecified:
            numberOfCellsPerRow = 5
            break
        @unknown default:
            numberOfCellsPerRow = 3
            break
        }

        let cellSpacing = VC.targetAssetsCollectionViewCellSpacing

        let cellWidth: CGFloat = ((view.bounds.width - VC.targetAssetsCollectionViewInsetX * 2 - CGFloat(numberOfCellsPerRow + 1) * cellSpacing) / CGFloat(numberOfCellsPerRow)).rounded(.down)
        let cellHeight: CGFloat = (cellWidth / GVC.defaultSceneAspectRatio).rounded(.down)

        targetAssetsCollectionViewCellSize = CGSize(width: cellWidth, height: cellHeight)
    }
}
