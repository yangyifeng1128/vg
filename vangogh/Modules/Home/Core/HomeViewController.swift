///
/// HomeViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class HomeViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let topButtonContainerWidth: CGFloat = 64
        static let topButtonContainerPadding: CGFloat = 12
        static let recordCollectionViewCellSpacing: CGFloat = 8
    }

    /// 记录集合视图
    var recordsCollectionView: UICollectionView!

    /// 记录列表
    var records: [MetaRecord] = [MetaRecord]()

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

        loadRecords() { [weak self] in
            guard let s = self else { return }
            s.recordsCollectionView.reloadData()
        }
    }

    /// 视图显示完成
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        // 签署协议

        signAgreements()
    }

    /// 初始化视图
    private func initViews() {

        view.backgroundColor = .systemGroupedBackground

        // 初始化「扫描按钮容器」

        let scanButtonContainer: UIView = UIView()
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

        let scanButton: CircleNavigationBarButton = CircleNavigationBarButton(icon: .scan, imageEdgeInset: 11) // 此处 .scan 图标偏大，所以单独设置了 imageEdgeInset
        scanButton.addTarget(self, action: #selector(scanButtonDidTap), for: .touchUpInside)
        scanButtonContainer.addSubview(scanButton)
        scanButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(CircleNavigationBarButton.VC.width)
            make.left.equalToSuperview().offset(VC.topButtonContainerPadding)
            make.bottom.equalToSuperview().offset(-VC.topButtonContainerPadding)
        }

        // 初始化「记录视图」

        let recordsView: UIView = UIView()
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
        recordsCollectionView.register(RecordCollectionViewCell.self, forCellWithReuseIdentifier: RecordCollectionViewCell.reuseId)
        recordsCollectionView.dataSource = self
        recordsCollectionView.delegate = self
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

        return prepareRecordsCount()
    }

    /// 设置单元格
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        return prepareRecordCollectionViewCell(indexPath: indexPath)
    }
}

extension HomeViewController: UICollectionViewDelegate {

    /// 选中单元格
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        selectRecordCollectionViewCell(indexPath: indexPath)
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {

    /// 设置单元格尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return prepareRecordCollectionViewCellSize(indexPath: indexPath)
    }

    /// 设置内边距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let inset = VC.recordCollectionViewCellSpacing
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }

    /// 设置最小行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return VC.recordCollectionViewCellSpacing
    }

    /// 设置最小单元格间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return VC.recordCollectionViewCellSpacing
    }
}
