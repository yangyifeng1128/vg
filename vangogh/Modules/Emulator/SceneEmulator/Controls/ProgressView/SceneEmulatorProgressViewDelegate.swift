///
/// SceneEmulatorProgressViewDelegate
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

protocol SceneEmulatorProgressViewDelegate: AnyObject {

    func progressViewDidBeginSliding()
    func progressViewDidEndSliding(to value: Double)
}
