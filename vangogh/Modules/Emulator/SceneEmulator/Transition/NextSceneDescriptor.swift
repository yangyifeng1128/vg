///
/// NextSceneDescriptor
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

class NextSceneDescriptor {

    /// 后续场景描述符类型枚举值
    enum NextSceneDescriptorType: String, CaseIterable {
        case resume = "Resume"
        case restart = "Restart"
        case redirectTo = "RedirectTo"
    }

    /// 后续场景描述符类型
    private(set) var type: NextSceneDescriptorType
    /// 标题
    private(set) var scene: MetaScene

    /// 初始化
    init(type: NextSceneDescriptorType, scene: MetaScene) {

        self.type = type
        self.scene = scene
    }
}
