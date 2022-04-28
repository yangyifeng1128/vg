///
/// GameSettingsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension GameSettingsViewController {

    /// 保存作品标题
    func saveGameTitle(_ game: MetaGame, newTitle: String, completion handler: (() -> Void)? = nil) {

        game.title = newTitle
        CoreDataManager.shared.saveContext()

        GameboardViewExternalChangeManager.shared.set(key: .updateGameTitle, value: nil) // 保存「作品板视图外部变更记录字典」

        if let handler = handler {
            DispatchQueue.main.async {
                handler()
            }
        }
    }
}
