///
/// HomeViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension HomeViewController {

    /// 签署协议
    func signAgreements() {

        let agreementsSigned: Bool = UserDefaults.standard.bool(forKey: GKC.agreementsSigned)
        if !agreementsSigned {
            presentAgreementsVC()
        }
    }

    /// 展示协议
    func presentAgreementsVC() {

        let agreementsVC: AgreementsViewController = AgreementsViewController()
        let agreementsNav: UINavigationController = UINavigationController(rootViewController: agreementsVC)
        agreementsNav.modalPresentationStyle = .overFullScreen
        agreementsNav.modalTransitionStyle = .crossDissolve

        present(agreementsNav, animated: true, completion: nil)
    }
}

extension HomeViewController {

    /// 准备记录数量
    func prepareRecordsCount() -> Int {

        if records.isEmpty {
            recordsCollectionView.showNoDataInfo(title: NSLocalizedString("NoRecordsFound", comment: ""))
        } else {
            recordsCollectionView.hideNoDataInfo()
        }

        return records.count
    }

    /// 准备「记录集合视图」单元格
    func prepareRecordCollectionViewCell(indexPath: IndexPath) -> UICollectionViewCell {

        let record: MetaRecord = records[indexPath.item]

        guard let cell = recordsCollectionView.dequeueReusableCell(withReuseIdentifier: RecordCollectionViewCell.reuseId, for: indexPath) as? RecordCollectionViewCell else {
            fatalError("Unexpected cell type")
        }

        // 准备「标题标签」

        cell.titleLabel.text = record.title

        return cell
    }

    /// 准备「记录集合视图」单元格尺寸
    func prepareRecordCollectionViewCellSize(indexPath: IndexPath) -> CGSize {

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

        let cellWidth: CGFloat = ((recordsCollectionView.bounds.width - CGFloat(numberOfCellsPerRow + 1) * VC.recordCollectionViewCellSpacing) / CGFloat(numberOfCellsPerRow)).rounded(.down)
        let cellHeight: CGFloat = (cellWidth / GVC.defaultSceneAspectRatio).rounded(.down)

        return CGSize(width: cellWidth, height: cellHeight)
    }

    /// 选择「记录集合视图」单元格
    func selectRecordCollectionViewCell(indexPath: IndexPath) {

        let _: MetaRecord = records[indexPath.item]
    }
}
