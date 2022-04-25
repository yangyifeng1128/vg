///
/// HomeViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import CoreData
import OSLog
import SnapKit
import UIKit

class HomeViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let topButtonContainerWidth: CGFloat = 64
        static let topButtonContainerPadding: CGFloat = 12
        static let recordCollectionViewCellSpacing: CGFloat = 8
    }

    /// 扫描按钮容器
    private var scanButtonContainer: UIView!
    /// 扫描按钮
    private var scanButton: CircleNavigationBarButton!

    /// 记录视图
    private var recordsView: UIView!
    private var recordsCollectionView: UICollectionView!
    private var recordCollectionViewCellWidth: CGFloat!
    private var recordCollectionViewCellHeight: CGFloat!

    /// 记录列表
    private var records: [MetaRecord] = [MetaRecord]()

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

        // 加载记录列表

        loadRecords()
    }

    /// 视图显示完成
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        // 签署协议

        signAgreements()
    }

    /// 签署协议
    private func signAgreements() {

        let agreementsSigned: Bool = UserDefaults.standard.bool(forKey: GKC.agreementsSigned)
        if !agreementsSigned {
            DispatchQueue.main.asyncAfter(
                deadline: .now(),
                execute: { [weak self] in
                    guard let s = self else { return }
                    s.presentAgreementsViewController()
                }
            )
        }
    }

    /// 初始化视图
    private func initViews() {

        view.backgroundColor = .systemGroupedBackground

        // 初始化「导航栏」

        initNavigationBar()

        // 初始化「记录视图」

        initRecordsView()
    }

    /// 初始化「导航栏」
    private func initNavigationBar() {

        // 初始化「扫描按钮容器」

        scanButtonContainer = UIView()
        scanButtonContainer.backgroundColor = .clear
        scanButtonContainer.isUserInteractionEnabled = true
        scanButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scanButtonDidTap)))
        view.addSubview(scanButtonContainer)
        let scanButtonContainerLeft: CGFloat = view.bounds.width - VC.topButtonContainerWidth
        scanButtonContainer.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.topButtonContainerWidth)
            make.left.equalToSuperview().offset(scanButtonContainerLeft)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        // 初始化「扫描按钮」

        scanButton = CircleNavigationBarButton(icon: .scan, imageEdgeInset: 11) // 此处 .scan 图标偏大，所以单独设置了 imageEdgeInset
        scanButton.addTarget(self, action: #selector(scanButtonDidTap), for: .touchUpInside)
        scanButtonContainer.addSubview(scanButton)
        scanButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.VC.width)
            make.left.equalToSuperview().offset(VC.topButtonContainerPadding)
            make.bottom.equalToSuperview().offset(-VC.topButtonContainerPadding)
        }
    }

    /// 初始化「记录视图」
    private func initRecordsView() {

        // 初始化「记录视图」

        recordsView = UIView()
        view.addSubview(recordsView)
        recordsView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(8)
            make.top.equalTo(scanButtonContainer.snp.bottom).offset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化「记录集合视图」

        recordsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        recordsCollectionView.backgroundColor = .clear
        recordsCollectionView.showsVerticalScrollIndicator = false
        recordsCollectionView.dataSource = self
        recordsCollectionView.delegate = self
        recordsCollectionView.register(TemplateCollectionViewCell.self, forCellWithReuseIdentifier: TemplateCollectionViewCell.reuseId)
        recordsView.addSubview(recordsCollectionView)
        recordsCollectionView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {

    /// 设置单元格数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if records.isEmpty {
            recordsCollectionView.showNoDataInfo(title: NSLocalizedString("NoRecordsFound", comment: ""))
        } else {
            recordsCollectionView.hideNoDataInfo()
        }

        return records.count
    }

    /// 设置单元格
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let record: MetaRecord = records[indexPath.item]

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TemplateCollectionViewCell.reuseId, for: indexPath) as? TemplateCollectionViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备「标题标签」

        cell.titleLabel.text = record.title

        return cell
    }
}

extension HomeViewController: UICollectionViewDelegate {

    /// 选中单元格
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let record: MetaRecord = records[indexPath.item]

        print("[Home] did select record: \(record.bundleFileName)")
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {

    /// 设置单元格尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var numberOfCellsPerRow: Int
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            numberOfCellsPerRow = 2
            break
        case .pad, .mac, .tv, .carPlay, .unspecified:
            numberOfCellsPerRow = 3
            break
        @unknown default:
            numberOfCellsPerRow = 2
            break
        }

        let cellSpacing = VC.recordCollectionViewCellSpacing

        recordCollectionViewCellWidth = ((collectionView.bounds.width - CGFloat(numberOfCellsPerRow + 1) * cellSpacing) / CGFloat(numberOfCellsPerRow)).rounded(.down)
        recordCollectionViewCellHeight = (recordCollectionViewCellWidth / GVC.defaultSceneAspectRatio).rounded(.down)

        return CGSize(width: recordCollectionViewCellWidth, height: recordCollectionViewCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let inset = VC.recordCollectionViewCellSpacing
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        let lineSpacing = VC.recordCollectionViewCellSpacing
        return lineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return VC.recordCollectionViewCellSpacing
    }
}

extension HomeViewController: GameScannerViewControllerDelegate {

    func scanDidSucceed(gameUUID: String) {

        guard let gameBundle = MetaGameBundleManager.shared.load(uuid: gameUUID), let selectedScene = gameBundle.selectedScene(), let selectedSceneBundle = MetaSceneBundleManager.shared.load(sceneUUID: selectedScene.uuid, gameUUID: gameBundle.uuid) else { return }

        let sceneEmulatorVC = SceneEmulatorViewController(sceneBundle: selectedSceneBundle, gameBundle: gameBundle)
        sceneEmulatorVC.definesPresentationContext = false
        sceneEmulatorVC.modalPresentationStyle = .currentContext

        present(sceneEmulatorVC, animated: true, completion: nil)
    }
}

extension HomeViewController {

    //
    //
    // MARK: - 界面操作
    //
    //

    @objc private func scanButtonDidTap() {

        print("[Home] did tap scanButton")

        presentGameScannerViewController()
    }

    private func presentAgreementsViewController() {

        let agreementsVC = AgreementsViewController()
        let agreementsNav = UINavigationController(rootViewController: agreementsVC)
        agreementsNav.modalPresentationStyle = .overFullScreen
        agreementsNav.modalTransitionStyle = .crossDissolve

        present(agreementsNav, animated: true, completion: nil)
    }

    private func presentGameScannerViewController() {

        let gameScannerVC: GameScannerViewController = GameScannerViewController()
        gameScannerVC.delegate = self
        gameScannerVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(gameScannerVC, animated: true)
    }

    /// 加载记录列表
    func loadRecords(completion handler: (() -> Void)? = nil) {

        let request: NSFetchRequest<MetaRecord> = MetaRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "mtime", ascending: false)]

        do {
            records = try CoreDataManager.shared.persistentContainer.viewContext.fetch(request)
            Logger.home.info("loading meta records: ok")
        } catch {
            Logger.home.info("loading meta records error: \(error.localizedDescription)")
        }

        if let handler = handler {
            DispatchQueue.main.async {
                handler()
            }
        }
    }
}
