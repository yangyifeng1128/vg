///
/// GameSettingsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

extension GameSettingsViewController {

    /// 保存作品标题
    func saveGameTitle(_ title: String, completion handler: (() -> Void)? = nil) {

        game.title = title
        CoreDataManager.shared.saveContext()

        // 保存作品编辑器外部变更字典

        GameEditorExternalChangeManager.shared.set(key: .updateGameTitle, value: nil)

        if let handler = handler {
            handler()
        }
    }
}
