///
/// NewGameViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import OSLog
import UIKit

extension NewGameViewController {

    @objc func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }

    @objc func newBlankGameButtonDidTap() {

        addGame { [weak self] game in
            guard let s = self else { return }
            s.pushGameEditorVC(game: game)
            Logger.composition.info("created a new blank game")
        }
    }

    @objc func pullToRefreshTemplates() {

        // 同步模版列表

        syncTemplates() { [weak self] in
            guard let s = self else { return }
            s.loadTemplates() {
                s.templatesCollectionView.reloadData()
                s.templatesCollectionView.refreshControl?.endRefreshing()
            }
        }
    }
}

extension NewGameViewController {

    /// 选择模板
    func selectTemplate(_ template: MetaTemplate) {

        addGame { [weak self] game in
            guard let s = self else { return }
            s.pushGameEditorVC(game: game)
            Logger.composition.info("created a new game with template: \(template.title)")
        }
    }

    /// 进入「作品编辑器」
    func pushGameEditorVC(game: MetaGame) {

        guard let gameBundle = MetaGameBundleManager.shared.load(uuid: game.uuid) else { return }

        let gameEditorVC: GameEditorViewController = GameEditorViewController(game: game, gameBundle: gameBundle, parentType: .new)
        gameEditorVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(gameEditorVC, animated: true)
    }
}
