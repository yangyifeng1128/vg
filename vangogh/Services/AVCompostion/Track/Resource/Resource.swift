///
/// Resource
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVFoundation
import CoreImage

public struct ResourceTrackInfo {
    public var track: AVAssetTrack
    public var selectedTimeRange: CMTimeRange
    public var scaleToDuration: CMTime
}

public protocol ResourceTrackInfoProvider: AnyObject {
    func trackInfo(for type: AVMediaType, at index: Int) -> ResourceTrackInfo
    func image(at time: CMTime, renderSize: CGSize) -> CIImage?
}

open class Resource: NSObject, NSCopying, ResourceTrackInfoProvider {

    required override public init() {
    }

    /// Max duration of this resource

    open var duration: CMTime = .zero

    /// Selected time range, indicate how many resources will be inserted to AVCompositionTrack

    open var selectedTimeRange: CMTimeRange = .zero

    private var _scaledDuration: CMTime = .invalid
    public var scaledDuration: CMTime {
        get {
            if !_scaledDuration.isValid {
                return selectedTimeRange.duration
            }
            return _scaledDuration
        }
        set {
            _scaledDuration = newValue
        }
    }

    public func sourceTime(for timelineTime: CMTime) -> CMTime {

        let seconds = selectedTimeRange.start.seconds + timelineTime.seconds * (selectedTimeRange.duration.seconds / scaledDuration.seconds)

        return CMTimeMakeWithSeconds(seconds, preferredTimescale: GlobalValueConstants.preferredTimescale)
    }

    /// Natural frame size of this resource

    open var size: CGSize = .zero

    /// Provide tracks for specific media type
    ///
    /// - Parameter type: specific media type, currently only support AVMediaTypeVideo and AVMediaTypeAudio
    /// - Returns: tracks

    open func tracks(for type: AVMediaType) -> [AVAssetTrack] {

        if let tracks = Resource.emptyAsset?.tracks(withMediaType: type) {
            return tracks
        }

        return []
    }

    //
    //
    // MARK: - Load content
    //
    //

    public enum ResourceStatus: Int {
        case unavaliable
        case avaliable
    }

    /// Resource's status, indicate weather the tracks are avaiable. Default is avaliable

    public var status: ResourceStatus = .unavaliable
    public var statusError: Error?

    /// Load content makes it available to get tracks. When use load resource from PHAsset or internet resource, it's your responsibility to determinate when and where to load the content.
    ///
    /// - Parameters:
    ///   - progressHandler: loading progress
    ///   - completion: load completion

    @discardableResult
    open func prepare(progressHandler: ((Double) -> Void)? = nil, completion: @escaping (ResourceStatus, Error?) -> Void) -> ResourceTask? {

        completion(status, statusError)

        return nil
    }

    open func copy(with zone: NSZone? = nil) -> Any {

        let resource = type(of: self).init()
        resource.size = size
        resource.duration = duration
        resource.selectedTimeRange = selectedTimeRange
        resource.scaledDuration = scaledDuration

        return resource
    }

    //
    //
    // MARK: - ResourceTrackInfoProvider
    //
    //

    public func trackInfo(for type: AVMediaType, at index: Int) -> ResourceTrackInfo {

        let track = tracks(for: type)[index]
        let emptyDuration = CMTimeMake(value: 1, timescale: 30)
        let emptyTimeRange = CMTimeRange(start: CMTime.zero, duration: emptyDuration)

        return ResourceTrackInfo(track: track, selectedTimeRange: emptyTimeRange, scaleToDuration: scaledDuration)
    }

    open func image(at time: CMTime, renderSize: CGSize) -> CIImage? {

        return nil
    }

    //
    //
    // MARK: - Helper
    //
    //

    private static let emptyAsset: AVAsset? = {

        if let url = Bundle.main.url(forResource: "black_empty", withExtension: "mp4") {
            let asset = AVAsset(url: url)
            return asset
        }
        return nil
    }()
}

public class ResourceTask {

    public var cancelHandler: (() -> Void)?

    public init(cancel: (() -> Void)? = nil) {

        self.cancelHandler = cancel
    }

    public func cancel() {
        cancelHandler?()
    }
}

public extension Resource {

    func setSpeed(_ speed: Float) {

        scaledDuration = selectedTimeRange.duration * (1 / speed)
    }
}
