///
/// PublicationViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension PublicationViewController {

    @objc func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }

    @objc func gameSettingsButtonDidTap() {

        pushGameSettingsVC()
    }

    @objc func publishButtonDidTap() {

    }

    @objc func pullToRefreshArchives() {

        syncArchives() { [weak self] in
            guard let s = self else { return }
            s.loadArchives() {
                s.archivesCollectionView.reloadData()
                s.archivesCollectionView.refreshControl?.endRefreshing()
            }
        }
    }
}

extension PublicationViewController {

    /// 跳转至「作品设置控制器」
    func pushGameSettingsVC() {

        let gameSettingsVC = GameSettingsViewController(game: game)
        gameSettingsVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(gameSettingsVC, animated: true)
    }

    /// 选择档案
    func selectArchive(_ archive: MetaTemplate) {

    }
}
