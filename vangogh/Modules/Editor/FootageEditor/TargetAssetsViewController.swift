///
/// TargetAssetsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Photos
import SnapKit
import UIKit

protocol TargetAssetsViewControllerDelegate: AnyObject {
    func assetDidPick(_ asset: PHAsset, thumbImage: UIImage?)
}

class TargetAssetsViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let topButtonContainerWidth: CGFloat = 64
        static let topButtonContainerPadding: CGFloat = 12
        static let titleLabelFontSize: CGFloat = 16
        static let menuControlTitleTextFontSize: CGFloat = 13
        static let collectionViewInsetX: CGFloat = 4
        static let collectionViewCellSpacing: CGFloat = 8
    }

    weak var delegate: TargetAssetsViewControllerDelegate?

    private var backButtonContainer: UIView!
    private var backButton: CircleNavigationBarButton!
    private var titleLabel: UILabel!

    private var menuControl: UISegmentedControl!
    private var collectionView: UICollectionView!

    private var menuItems: [String]!
    private var assets: PHFetchResult<PHAsset>!
    private var imageManager: PHCachingImageManager!
    private var thumbSize: CGSize!
    private var previousPreheatRect: CGRect!

    /// 初始化
    init() {

        super.init(nibName: nil, bundle: nil)

        menuItems = [NSLocalizedString("Pictures", comment: ""), NSLocalizedString("Videos", comment: "")]
        assets = PHFetchResult()
        imageManager = PHCachingImageManager()
        previousPreheatRect = .zero
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    deinit {

        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

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

        // 单独强制设置状态栏风格

        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        navigationController?.navigationBar.barStyle = (window.overrideUserInterfaceStyle == .dark) ? .black : .default

        // 重置缓存素材

        resetCachedAssets()

        // 加载素材

        loadAssets(menuItemIndex: menuControl.selectedSegmentIndex)

        // 监听相册是否发生变化

        PHPhotoLibrary.shared().register(self)
    }

    /// 视图显示完成
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        // 更新缓存素材

        updateCachedAssets()
    }

    /// 视图即将消失
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        // 禁止「场景编辑器」视图控制器在 viewDidAppear 中重新加载播放器
        // 我们会在 TargetAssetsViewControllerDelegate.assetDidPick 中重新加载播放器

        if let parent = navigationController?.viewControllers[0] as? SceneEditorViewController {
            parent.needsReloadPlayer = false
        }
    }

    /// 初始化视图
    private func initViews() {

        view.backgroundColor = .systemGroupedBackground

        // 初始化「导航栏」

        initNavigationBar()

        // 初始化「素材视图」

        initAssetsView()
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

        titleLabel = UILabel()
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
    }

    /// 初始化「素材视图」
    private func initAssetsView() {

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

        prepareAssetThumbSize()

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TargetAssetCollectionViewCell.self, forCellWithReuseIdentifier: TargetAssetCollectionViewCell.reuseId)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(VC.collectionViewInsetX)
            make.top.equalTo(menuControl.snp.bottom).offset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        let swipeLeftGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(collectionViewDidSwipeLeft))
        swipeLeftGesture.direction = .left
        collectionView.addGestureRecognizer(swipeLeftGesture)

        let swipeRightGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(collectionViewDidSwipeRight))
        swipeRightGesture.direction = .right
        collectionView.addGestureRecognizer(swipeRightGesture)
    }

    private func prepareAssetThumbSize() {

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

        let cellSpacing = VC.collectionViewCellSpacing

        let cellWidth: CGFloat = ((view.bounds.width - VC.collectionViewInsetX * 2 - CGFloat(numberOfCellsPerRow + 1) * cellSpacing) / CGFloat(numberOfCellsPerRow)).rounded(.down)
        let cellHeight: CGFloat = (cellWidth / GVC.defaultSceneAspectRatio).rounded(.down)

        thumbSize = CGSize(width: cellWidth, height: cellHeight)
    }
}

extension TargetAssetsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

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
            collectionView.showNoDataInfo(title: noDataInfoTitle)
        } else {
            collectionView.hideNoDataInfo()
        }

        return assets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TargetAssetCollectionViewCell.reuseId, for: indexPath) as? TargetAssetCollectionViewCell else {
            fatalError("Unexpected cell type")
        }

        let asset = assets.object(at: indexPath.item)

        // 准备缩略图视图

        cell.assetIdentifier = asset.localIdentifier

        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        let scale = UIScreen.main.scale
        let targetSize: CGSize = CGSize(width: thumbSize.width * scale, height: thumbSize.height * scale)
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (image, info) in
            if cell.assetIdentifier == asset.localIdentifier {
                cell.thumbImageView.image = image
            }
        }

        // 准备视频时长标签

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
}

extension TargetAssetsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) as? TargetAssetCollectionViewCell else { return }
        delegate?.assetDidPick(assets[indexPath.item], thumbImage: cell.thumbImageView.image)

        navigationController?.popViewController(animated: true)
    }
}

extension TargetAssetsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return thumbSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let inset = VC.collectionViewCellSpacing
        return UIEdgeInsets(top: 0, left: inset, bottom: inset, right: inset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        let lineSpacing = VC.collectionViewCellSpacing
        return lineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return VC.collectionViewCellSpacing
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        // 更新缓存素材

        updateCachedAssets()
    }
}

extension TargetAssetsViewController: PHPhotoLibraryChangeObserver {

    func photoLibraryDidChange(_ changeInstance: PHChange) {

        guard let changeDetails = changeInstance.changeDetails(for: assets) else { return }

        DispatchQueue.main.sync { [weak self] in

            guard let strongSelf = self else { return }

            // 重新获取素材

            strongSelf.assets = changeDetails.fetchResultAfterChanges

            if changeDetails.hasIncrementalChanges { // 如果存在增量更新
                strongSelf.collectionView.performBatchUpdates({
                    if let removed = changeDetails.removedIndexes, !removed.isEmpty {
                        strongSelf.collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changeDetails.insertedIndexes, !inserted.isEmpty {
                        strongSelf.collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changeDetails.enumerateMoves { fromIndex, toIndex in
                        strongSelf.collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0), to: IndexPath(item: toIndex, section: 0))
                    }
                })
                // We are reloading items after the batch update since `PHFetchResultChangeDetails.changedIndexes` refers to items in the *after* state and not the *before* state as expected by `performBatchUpdates(_:completion:)`
                if let changed = changeDetails.changedIndexes, !changed.isEmpty {
                    strongSelf.collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                }
            } else {
                strongSelf.collectionView.reloadData()
            }

            // 重置缓存素材

            resetCachedAssets()
        }
    }
}

extension TargetAssetsViewController {

    //
    //
    // MARK: - 界面操作
    //
    //

    /// 点击「返回按钮」
    @objc private func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }

    @objc private func collectionViewDidSwipeLeft() {

        var index = menuControl.selectedSegmentIndex - 1
        if index < 0 { index = menuItems.count - 1 }
        menuControl.selectedSegmentIndex = index
        menuControl.sendActions(for: .valueChanged)
    }

    @objc private func collectionViewDidSwipeRight() {

        var index = menuControl.selectedSegmentIndex + 1
        if index > menuItems.count - 1 { index = 0 }
        menuControl.selectedSegmentIndex = index
        menuControl.sendActions(for: .valueChanged)
    }

    @objc private func menuControlDidChange() {

        print("[TargetAssets] selected menu control index: \(menuControl.selectedSegmentIndex)")

        loadAssets(menuItemIndex: menuControl.selectedSegmentIndex)
    }

    //
    //
    // MARK: - 数据操作
    //
    //

    private func loadAssets(menuItemIndex: Int) {

        var type: PHAssetMediaType = .image
        switch menuItemIndex {
        case 0:
            type = .image
            break
        case 1:
            type = .video
            break
        default:
            break
        }

        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        assets = PHAsset.fetchAssets(with: type, options: options)

        collectionView.reloadData()
        if assets.count > 0 {
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }

    private func updateCachedAssets() {

        // The window you prepare ahead of time is twice the height of the visible rect

        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)

        // Update only if the visible area is significantly different from the last preheated area

        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }

        // Compute the assets to start and stop caching

        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .map { indexPath in assets.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .map { indexPath in assets.object(at: indexPath.item) }

        // Update the assets the PHCachingImageManager is caching

        imageManager.startCachingImages(for: addedAssets,
            targetSize: thumbSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
            targetSize: thumbSize, contentMode: .aspectFill, options: nil)

        // Store the computed rectangle for future comparison

        previousPreheatRect = preheatRect
    }

    private func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {

        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                    width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                    width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                    width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                    width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }

    private func resetCachedAssets() {

        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
}

private extension UICollectionView {

    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {

        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}
