///
/// TargetScenesViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

extension TargetScenesViewController {

    /// 加载目标场景列表
    func loadTargetScenes(completion handler: (() -> Void)? = nil) {

        targetScenes = gameBundle.scenes.filter { targetScene in
            // 过滤当前选中的场景
            if targetScene.index == gameBundle.selectedSceneIndex {
                return false
            }
            // 过滤已保存的穿梭器
            let existedTransitions = gameBundle.selectedTransitions()
            if let _ = existedTransitions.first(where: { $0.to == targetScene.index }) { return false }
            // 返回其余的场景
            return true
        }.reversed() // 倒序

        if let handler = handler {
            handler()
        }
    }

    /// 添加穿梭器
    func addTransition(from: Int, to: Int, completion handler: (() -> Void)? = nil) {

        // FIXME：重新处理「MetaTransition - MetaCondition」

        var conditions = [MetaCondition]()
        let defaultCondition = MetaCondition(sensor: MetaSensor(gameUUID: gameBundle.uuid, sceneUUID: nil, nodeUUID: nil, key: .timeControl), operatorKey: .equalTo, value: "end")
        conditions.append(defaultCondition)

        if let transition = gameBundle.addTransition(from: from, to: to, conditions: conditions) {

            MetaGameBundleManager.shared.save(gameBundle)

            // 保存作品编辑器外部变更记录

            GameEditorExternalChangeManager.shared.set(key: .addTransition, value: transition)

            if let handler = handler {
                handler()
            }
        }
    }
}
