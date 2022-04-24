///
/// TrackItemContentView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVFoundation
import SnapKit
import UIKit

class TrackItemContentView: UIView {

    /// 视图布局常量枚举值
    enum VC {
        static let height: CGFloat = 56
        static let preheatThumbImageViewIndexCount: Int = 4
    }

    private var thumbImageViewDict: [Int: UIImageView] = [:] // 缩略图视图字典
    private var reusableThumbImageViewList: [UIImageView] = [] // 不在当前屏幕可视范围内的缩略图视图要赶快移除掉，但是被移除的缩略图视图对象不要直接丢弃掉，而是要放到这个回收列表中，有机会的时候还是可以被重复利用的（避免重新创建 UIImageView）

    var loadThumbImageQueue: DispatchQueue?
    var loadThumbImageWorkItemDict: [Int: DispatchWorkItem] = [:]
    var imageGenerator: CachedImageGenerator? // 带缓存的图像生成器

    private var footageType: MetaFootageType!
    var leftMarkTime: CMTime! // 左标时刻
    var rightMarkTime: CMTime! // 右标时刻
    var thumbImageSize: CGSize! // 缩略图尺寸

    var maxDuration: CMTime! // 最大时长
    var minDuration: CMTime = CMTimeMake(value: GVC.minTrackItemDurationMilliseconds, timescale: GVC.preferredTimescale) // 最小时长

    var width: CGFloat {
        return (GVC.defaultTimelineItemWidthPerSecond * (rightMarkTime.seconds - leftMarkTime.seconds)).rounded()
    } // 视图宽度

    init(footageType: MetaFootageType, leftMarkTime: CMTime, rightMarkTime: CMTime, thumbImageSize: CGSize, maxDuration: CMTime = .zero) {

        super.init(frame: .zero)

        self.footageType = footageType
        self.leftMarkTime = leftMarkTime
        self.rightMarkTime = rightMarkTime
        self.thumbImageSize = thumbImageSize
        self.maxDuration = maxDuration

        // 初始化视图

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    deinit {

        imageGenerator?.cancelAllCGImageGeneration() // 取消生成缩略图
    }

    private func initViews() {

        backgroundColor = .black
        clipsToBounds = true // 防止末尾的缩略图视图超出父视图的边界
    }
}

extension TrackItemContentView {

    func updateThumbImageViews() {

        // 获取当前屏幕可视范围内的缩略图索引

        let indexRange: CountableRange<Int> = visibleThumbImageViewIndexRange()
        guard indexRange.count > 0 else { return }

        // 移除不在当前屏幕可视范围内的缩略图视图

        removeThumbImageViews(except: indexRange)

        // 更新当前屏幕可视范围内的缩略图视图

        indexRange.forEach { updateThumbImageView(index: $0) }
    }

    private func visibleThumbImageViewIndexRange() -> CountableRange<Int> {

        guard let asset = imageGenerator?.asset else { // 如果 imageGenerator?.asset 不存在，则清空缩略图视图字典
            for (_, thumbImageView) in thumbImageViewDict {
                thumbImageView.tag = 0
                thumbImageView.image = nil
                thumbImageView.removeFromSuperview()
                reusableThumbImageViewList.append(thumbImageView)
            }
            thumbImageViewDict.removeAll()
            return 0..<0
        }

        // 计算当前屏幕可视范围内的缩略图索引

        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return 0..<0 }

        let rectInWindow: CGRect = convert(frame, to: window)
        let availableRectInWindow: CGRect = window.bounds.intersection(rectInWindow)

        if availableRectInWindow.isNull { return 0..<0 }
        let availableRect: CGRect = convert(availableRectInWindow, from: window)

        let startOffset: CGFloat = availableRect.origin.x
        var startIndex: Int = Int(startOffset / thumbImageSize.width)
        var endIndex: Int = Int(ceil((availableRect.width + startOffset) / thumbImageSize.width))

        if VC.preheatThumbImageViewIndexCount > 0 { // 在当前屏幕可视范围内的缩略图索引之外，预加载额外的索引
            startIndex = startIndex - VC.preheatThumbImageViewIndexCount
            startIndex = max(0, startIndex)
            endIndex = endIndex + VC.preheatThumbImageViewIndexCount
            let maxIndex = Int(ceil(GVC.defaultTimelineItemWidthPerSecond * asset.duration.seconds / thumbImageSize.width))
            endIndex = min(maxIndex, endIndex)
        }

        return startIndex..<endIndex
    }

    private func removeThumbImageViews(except indexRange: CountableRange<Int>) {

        // 计算不在当前屏幕可视范围内的缩略图视图索引

        let targetIndexRange = thumbImageViewDict.keys.filter({ !indexRange.contains($0) })

        // 将其移除并将视图对象放到回收列表中

        for index in targetIndexRange {

            if let thumbImageView = thumbImageViewDict.removeValue(forKey: index) {
                thumbImageView.tag = 0
                thumbImageView.image = nil
                thumbImageView.removeFromSuperview()
                reusableThumbImageViewList.append(thumbImageView)
            }
        }
    }

    private func updateThumbImageView(index: Int) {

        guard let imageGenerator = imageGenerator else { return }

        // 获取缩略图视图

        var thumbImageView: UIImageView
        if let imageView = thumbImageViewDict[index] { // 当前字典中已存在
            thumbImageView = imageView
        } else {
            if let imageView = reusableThumbImageViewList.first { // 从回收列表中挑一个视图对象重新利用
                thumbImageView = imageView
                thumbImageView.image = nil
                reusableThumbImageViewList.removeFirst()
            } else { // 创建一个新的视图对象
                thumbImageView = UIImageView()
            }
            thumbImageView.tag = -1
            thumbImageViewDict[index] = thumbImageView
        }
        let previousIndex = thumbImageView.tag // 获取之前的索引
        thumbImageView.tag = index // 设置新的索引

        if let parent = thumbImageView.superview, parent == self { // 如果该缩略图视图在当前视图中显示，则只需要更新其左侧布局约束
            thumbImageView.snp.updateConstraints { make -> Void in
                make.left.equalTo((thumbImageSize.width * CGFloat(index)))
            }
        } else { // 否则需要添加到当前视图中并重新布局
            thumbImageView.removeFromSuperview()
            addSubview(thumbImageView)
            thumbImageView.snp.remakeConstraints { make -> Void in
                make.width.equalTo(thumbImageSize.width)
                make.height.equalTo(thumbImageSize.height)
                make.centerY.equalToSuperview()
                make.left.equalTo((thumbImageSize.width * CGFloat(index)))
            }
        }

        // 如果图像生成器缓存池中已存在对应的缓存图像，则直接更新该缩略图视图，退出

        let durationMillisecondsPerImage: Int64 = Int64((thumbImageSize.width / GVC.defaultTimelineItemWidthPerSecond).rounded())
        let leftMarkTimeMilliseconds: Int64 = durationMillisecondsPerImage * Int64(index)
        let rightMarkTimeMilliseconds: Int64 = min(durationMillisecondsPerImage * Int64(index + 1), imageGenerator.asset.duration.milliseconds())
        let timeKey: CMTime = CMTimeMake(value: (leftMarkTimeMilliseconds + rightMarkTimeMilliseconds) / 2, timescale: imageGenerator.asset.duration.timescale) // 这里的时刻仅用作缓存池的 key
        if let cgImage = imageGenerator.getCachedImage(at: timeKey) { // 如果缓存池在当前时刻可以查找到缓存图像
            if index != previousIndex { // 并且当前的索引与之前的索引不一致
                thumbImageView.image = UIImage(cgImage: cgImage)
            }
            return
        }

        // 否则需要重新生成缩略图

        if loadThumbImageWorkItemDict[index] != nil { // 如果当前图像生成器的工作项已存在，则等待它完成剩余工作，退出
            return
        }

        // 创建并执行一个新的图像生成器工作项

        let workItem = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }
            defer { // 该工作项执行完成以后，将其移除
                strongSelf.loadThumbImageWorkItemDict.removeValue(forKey: index)
            }
            var cancel: Bool = true
            DispatchQueue.main.sync {
                cancel = thumbImageView.tag != index
            }
            guard !cancel else { return }
            guard let cgImage = try? imageGenerator.copyCGImage(at: timeKey, actualTime: nil) else { return }
            DispatchQueue.main.async {
                thumbImageView.image = UIImage(cgImage: cgImage)
            }
        }

        loadThumbImageQueue?.async(execute: workItem)
        loadThumbImageWorkItemDict[index] = workItem
    }
}

extension TrackItemContentView {

    func expand(translationOffsetX: CGFloat, withLeftEar: Bool) {

        let translationDurationMilliseconds: Int64 = Int64((translationOffsetX * 1000 / GVC.defaultTimelineItemWidthPerSecond).rounded())

        if footageType == .video {

            if withLeftEar {

                var leftMarkTimeMilliseconds: Int64 = leftMarkTime.milliseconds() + translationDurationMilliseconds

                // 检查极限时刻

                leftMarkTimeMilliseconds = min(max(0, leftMarkTimeMilliseconds), rightMarkTime.milliseconds() - minDuration.milliseconds())

                leftMarkTime = CMTimeMake(value: leftMarkTimeMilliseconds, timescale: GVC.preferredTimescale)

            } else {

                var rightMarkTimeMilliseconds: Int64 = rightMarkTime.milliseconds() + translationDurationMilliseconds

                // 检查极限时刻

                rightMarkTimeMilliseconds = max(min(rightMarkTimeMilliseconds, maxDuration.milliseconds()), leftMarkTime.milliseconds() + minDuration.milliseconds())

                rightMarkTime = CMTimeMake(value: rightMarkTimeMilliseconds, timescale: GVC.preferredTimescale)
            }

        } else {

            if withLeftEar {

                var leftMarkTimeMilliseconds: Int64 = leftMarkTime.milliseconds() + translationDurationMilliseconds

                // 检查极限时刻

                leftMarkTimeMilliseconds = min(leftMarkTimeMilliseconds, rightMarkTime.milliseconds() - minDuration.milliseconds())

                leftMarkTime = CMTimeMake(value: leftMarkTimeMilliseconds, timescale: GVC.preferredTimescale)

            } else {

                var rightMarkTimeMilliseconds: Int64 = rightMarkTime.milliseconds() + translationDurationMilliseconds

                // 检查极限时刻

                rightMarkTimeMilliseconds = max(rightMarkTimeMilliseconds, leftMarkTime.milliseconds() + minDuration.milliseconds())

                rightMarkTime = CMTimeMake(value: rightMarkTimeMilliseconds, timescale: GVC.preferredTimescale)
            }
        }
    }

    func relocateTimeRange(withLeftEar: Bool) {

        if footageType != .video && withLeftEar {
            let previousLeftMarkTime: CMTime = leftMarkTime
            leftMarkTime = .zero
            rightMarkTime = rightMarkTime - previousLeftMarkTime
        }
    }
}
