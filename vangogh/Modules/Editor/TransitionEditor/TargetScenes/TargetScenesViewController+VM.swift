///
/// TargetScenesViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

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
}
