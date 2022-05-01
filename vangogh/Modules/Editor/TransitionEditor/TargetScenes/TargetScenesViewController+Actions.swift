///
/// TargetScenesViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import OSLog
import UIKit

extension TargetScenesViewController {

    @objc func backButtonDidTap() {

        navigationController?.popViewController(animated: true)
    }
}

extension TargetScenesViewController {

    /// 选择目标场景
    func selectTargetScene(_ targetScene: MetaScene) {

        Logger.gameEditor.info("selected target scene: \(targetScene.index)")

        // FIXME：重新处理「MetaTransition - MetaCondition」

        var conditions = [MetaCondition]()
        let defaultCondition = MetaCondition(sensor: MetaSensor(gameUUID: gameBundle.uuid, sceneUUID: nil, nodeUUID: nil, key: .timeControl), operatorKey: .equalTo, value: "end")
        conditions.append(defaultCondition)
//        let testCondition = MetaCondition(nodeIndex: 0, nodeType: 1, nodeBehaviorType: 12, parameters: "2次")
//        conditions.append(testCondition)
//        let test2Condition = MetaCondition(nodeIndex: 1, nodeType: 2, nodeBehaviorType: 21)
//        conditions.append(test2Condition)
//        let test3Condition = MetaCondition(nodeIndex: 2, nodeType: 3, nodeBehaviorType: 31, parameters: "(B)")
//        conditions.append(test3Condition)
//        let test4Condition = MetaCondition(nodeIndex: 3, nodeType: 4, nodeBehaviorType: 41, parameters: "3次")
//        conditions.append(test4Condition)
//        let test5Condition = MetaCondition(nodeIndex: 4, nodeType: 5, nodeBehaviorType: 51, parameters: "(熊猫)")
//        conditions.append(test5Condition)

        if let transition = gameBundle.addTransition(from: gameBundle.selectedSceneIndex, to: targetScene.index, conditions: conditions) {

            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let s = self else { return }
                MetaGameBundleManager.shared.save(s.gameBundle)
            }

            GameEditorExternalChangeManager.shared.set(key: .addTransitionView, value: transition) // 保存作品编辑器外部变更字典
        }

        // 返回父视图

        navigationController?.popViewController(animated: true)
    }
}
