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

    private var scanButtonContainer: UIView!
    private var scanButton: CircleNavigationBarButton! // 扫描按钮

    private var recordsView: UIView! // 记录视图
    private var recordsCollectionView: UICollectionView!
    private var recordCollectionViewCellWidth: CGFloat!
    private var recordCollectionViewCellHeight: CGFloat!

    private var records = [NSManagedObject]() // 记录列表

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

        // 从本地加载记录列表

        loadRecords()
    }

    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        // 签署协议

        signAgreements()
    }

    private func signAgreements() {

        let agreementsSigned: Bool = UserDefaults.standard.bool(forKey: "agreementsSigned")
        if !agreementsSigned {
            DispatchQueue.main.asyncAfter(
                deadline: .now(),
                execute: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.presentAgreementsViewController()
                }
            )
        }
    }

    //
    //
    // MARK: - 初始化子视图
    //
    //

    private func initViews() {

        view.backgroundColor = .systemGroupedBackground

        // 初始化导航栏

        initNavigationBar()

        // 初始化记录视图

        initMetaRecordsView()
    }

    private func initNavigationBar() {

        // 初始化扫描按钮

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

        scanButton = CircleNavigationBarButton(icon: .scan, imageEdgeInset: 11) // 此处 .scan 图标偏大，所以单独设置了 imageEdgeInset
        scanButton.addTarget(self, action: #selector(scanButtonDidTap), for: .touchUpInside)
        scanButtonContainer.addSubview(scanButton)
        scanButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.VC.width)
            make.left.equalToSuperview().offset(VC.topButtonContainerPadding)
            make.bottom.equalToSuperview().offset(-VC.topButtonContainerPadding)
        }
    }

    private func initMetaRecordsView() {

        recordsView = UIView()
        view.addSubview(recordsView)
        recordsView.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(8)
            make.top.equalTo(scanButtonContainer.snp.bottom).offset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        // 初始化记录集合视图

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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if records.isEmpty {
            recordsCollectionView.showNoDataInfo(title: NSLocalizedString("NoRecordsFound", comment: ""))
        } else {
            recordsCollectionView.hideNoDataInfo()
        }

        return records.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TemplateCollectionViewCell.reuseId, for: indexPath) as? TemplateCollectionViewCell else {
            fatalError("Unexpected cell type")
        }

        if let record = records[indexPath.item] as? MetaRecord {

            // 准备标题标签

            cell.titleLabel.text = record.title
        }

        return cell
    }
}

extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let record = records[indexPath.item] as? MetaRecord {

            print("[Home] did select record: \(record.bundleFileName)")
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {

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

    //
    //
    // MARK: - 数据操作
    //
    //

    /// 加载记录
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
