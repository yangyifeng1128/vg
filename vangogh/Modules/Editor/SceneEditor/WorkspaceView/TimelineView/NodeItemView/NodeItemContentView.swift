///
/// NodeItemContentView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVFoundation
import SnapKit
import UIKit

class NodeItemContentView: UIView {

    /// 视图布局常量枚举值
    enum ViewLayoutConstants {
        static let height: CGFloat = 32
    }

    private var nodeType: MetaNodeType!
    var startTime: CMTime! // 开始时刻
    var endTime: CMTime! // 结束时刻

    var minDuration: CMTime = CMTimeMake(value: GlobalValueConstants.minNodeItemDurationMilliseconds, timescale: GlobalValueConstants.preferredTimescale) // 最小时长

    var width: CGFloat {
        return (GlobalValueConstants.defaultTimelineItemWidthPerSecond * (endTime.seconds - startTime.seconds)).rounded()
    } // 视图宽度

    private var previousSnappedTimeMilliseconds: Int64 = -1 // 先前对齐的边缘时刻

    init(nodeType: MetaNodeType, startTime: CMTime, endTime: CMTime) {

        super.init(frame: .zero)

        self.nodeType = nodeType
        self.startTime = startTime
        self.endTime = endTime

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {

        backgroundColor = MetaNodeTypeManager.shared.getNodeTypeBackgroundColor(nodeType: nodeType)
    }
}

extension NodeItemContentView {

    func expand(translationOffsetX: CGFloat, withLeftEar: Bool) {

        let translationDurationMilliseconds: Int64 = Int64((translationOffsetX * 1000 / GlobalValueConstants.defaultTimelineItemWidthPerSecond).rounded())

        if withLeftEar {

            var startTimeMilliseconds: Int64 = startTime.milliseconds() + translationDurationMilliseconds

            // 对齐边缘时刻

            guard let snappedTimeMillisecondsPool = UserDefaults.standard.array(forKey: "snappedTimeMillisecondsPool") as? [Int64] else { return }
            for snappedTimeMilliseconds in snappedTimeMillisecondsPool {
                if abs(startTimeMilliseconds - snappedTimeMilliseconds) <= GlobalValueConstants.snappedTimeMillisecondsThreshold {
                    startTimeMilliseconds = snappedTimeMilliseconds
                    if snappedTimeMilliseconds != previousSnappedTimeMilliseconds {
                        UIImpactFeedbackGenerator().impactOccurred()
                        previousSnappedTimeMilliseconds = snappedTimeMilliseconds
                    }
                    break
                }
            }
            if abs(startTimeMilliseconds - previousSnappedTimeMilliseconds) > GlobalValueConstants.snappedTimeMillisecondsThreshold {
                previousSnappedTimeMilliseconds = -1
            }

            // 检查极限时刻

            startTimeMilliseconds = min(max(0, startTimeMilliseconds), endTime.milliseconds() - minDuration.milliseconds())

            startTime = CMTimeMake(value: startTimeMilliseconds, timescale: GlobalValueConstants.preferredTimescale)

        } else {

            var endTimeMilliseconds: Int64 = endTime.milliseconds() + translationDurationMilliseconds

            // 对齐边缘时刻

            guard let snappedTimeMillisecondsPool = UserDefaults.standard.array(forKey: "snappedTimeMillisecondsPool") as? [Int64] else { return }
            for snappedTimeMilliseconds in snappedTimeMillisecondsPool {
                if abs(endTimeMilliseconds - snappedTimeMilliseconds) <= GlobalValueConstants.snappedTimeMillisecondsThreshold {
                    endTimeMilliseconds = snappedTimeMilliseconds
                    if snappedTimeMilliseconds != previousSnappedTimeMilliseconds {
                        UIImpactFeedbackGenerator().impactOccurred()
                        previousSnappedTimeMilliseconds = snappedTimeMilliseconds
                    }
                    break
                }
            }
            if abs(endTimeMilliseconds - previousSnappedTimeMilliseconds) > GlobalValueConstants.snappedTimeMillisecondsThreshold {
                previousSnappedTimeMilliseconds = -1
            }

            // 检查极限时刻

            endTimeMilliseconds = max(endTimeMilliseconds, startTime.milliseconds() + minDuration.milliseconds())

            endTime = CMTimeMake(value: endTimeMilliseconds, timescale: GlobalValueConstants.preferredTimescale)
        }
    }
}
