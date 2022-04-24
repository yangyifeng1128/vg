///
/// AVAssetTrackResource
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVFoundation
import UIKit

public class AVAssetTrackResource: Resource {

    public var asset: AVAsset?

    public init(asset: AVAsset) {

        super.init()

        self.asset = asset
        let duration = CMTimeMakeWithSeconds(asset.duration.seconds, preferredTimescale: GVC.preferredTimescale)
        self.duration = duration
        selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: duration)
    }

    required public init() {

        super.init()
    }

    //
    //
    // MARK: - Load Media before use resource
    //
    //

    @discardableResult
    open override func prepare(progressHandler: ((Double) -> Void)? = nil, completion: @escaping (ResourceStatus, Error?) -> Void) -> ResourceTask? {

        if let asset = asset {

            asset.loadValuesAsynchronously(forKeys: ["tracks", "duration"], completionHandler: { [weak self] in

                guard let s = self else { return }

                func finished() {
                    if !asset.tracks.isEmpty {
                        if let track = asset.tracks(withMediaType: .video).first {
                            s.size = track.naturalSize.applying(track.preferredTransform)
                        }
                        s.status = .avaliable
                        s.duration = asset.duration
                    }
                    DispatchQueue.main.async {
                        completion(s.status, s.statusError)
                    }
                }

                var error: NSError?

                let tracksStatus = asset.statusOfValue(forKey: "tracks", error: &error)
                if tracksStatus != .loaded {
                    s.statusError = error
                    s.status = .unavaliable
                    Log.error("Failed to load tracks, status: \(tracksStatus), error: \(String(describing: error))")
                    finished()
                    return
                }

                let durationStatus = asset.statusOfValue(forKey: "duration", error: &error)
                if durationStatus != .loaded {
                    s.statusError = error
                    s.status = .unavaliable
                    Log.error("Failed to duration tracks, status: \(tracksStatus), error: \(String(describing: error))")
                    finished()
                    return
                }

                finished()
            })

            return ResourceTask.init(cancel: {
                asset.cancelLoading()
            })

        } else {

            completion(status, statusError)
        }

        return nil
    }

    //
    //
    // MARK: - Content provider
    //
    //

    open override func tracks(for type: AVMediaType) -> [AVAssetTrack] {

        if let asset = asset {
            return asset.tracks(withMediaType: type)
        }
        return []
    }

    //
    //
    // MARK: - ResourceTrackInfoProvider
    //
    //

    public override func trackInfo(for type: AVMediaType, at index: Int) -> ResourceTrackInfo {

        let track = tracks(for: type)[index]
        return ResourceTrackInfo(track: track,
                                 selectedTimeRange: selectedTimeRange,
                                 scaleToDuration: scaledDuration)
    }

    override public func copy(with zone: NSZone? = nil) -> Any {

        let resource = super.copy(with: zone) as! AVAssetTrackResource
        resource.asset = asset
        return resource
    }
}
