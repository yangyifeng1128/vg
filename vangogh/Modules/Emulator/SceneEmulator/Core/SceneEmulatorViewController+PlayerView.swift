///
/// SceneEmulatorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension SceneEmulatorViewController: SceneEmulatorPlayerViewDataSource {
    
    func aspectRatioType() -> MetaSceneAspectRatioType {
        
        return sceneBundle.aspectRatioType
    }
}

extension SceneEmulatorViewController: SceneEmulatorPlayerViewDelegate {

}
