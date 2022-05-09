///
/// NextSceneIndicator
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

class NextSceneIndicator {

    /// 后续场景提示器类型枚举值
    enum NextSceneIndicatorType: String, CaseIterable {
        case resume = "Resume"
        case loop = "Loop"
        case next = "Next"
    }

    /// 后续场景提示器类型
    private(set) var type: NextSceneIndicatorType
    /// 标题
    private(set) var title: String

    /// 初始化
    init(type: NextSceneIndicatorType, title: String) {

        self.type = type
        self.title = title
    }
}
