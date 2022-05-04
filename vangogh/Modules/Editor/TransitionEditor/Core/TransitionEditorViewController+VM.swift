///
/// TransitionEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

extension TransitionEditorViewController {

    /// 删除条件
    func deleteCondition(_ condition: MetaCondition, completion handler: (() -> Void)? = nil) {

        gameBundle.deleteCondition(transition: transition, condition: condition)
        MetaGameBundleManager.shared.save(gameBundle)

        if let handler = handler {
            handler()
        }
    }
}
