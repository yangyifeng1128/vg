///
/// PHAssetTrackResource
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Photos

public class PHAssetTrackResource: AVAssetTrackResource {

    public var phasset: PHAsset?

    public init(phasset: PHAsset) {

        super.init()

        self.phasset = phasset
        let duration = CMTimeMakeWithSeconds(phasset.duration, preferredTimescale: GVC.preferredTimescale)
        self.duration = duration
        self.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: duration)
    }

    required public init() {

        super.init()
    }

    @discardableResult
    open override func prepare(progressHandler: ((Double) -> Void)? = nil, completion: @escaping (ResourceStatus, Error?) -> Void) -> ResourceTask? {

        if self.asset != nil {
            return super.prepare(progressHandler: progressHandler, completion: completion)
        }

        guard let phasset = phasset else {
            completion(status, nil)
            return nil
        }

        let options = PHVideoRequestOptions()
        options.version = .current
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = { (progress, error, stop, info) in
            if let b = info?[PHImageCancelledKey] as? NSNumber, b.boolValue {
                return
            }
            if error != nil {
                return
            }
            DispatchQueue.main.async {
                progressHandler?(progress)
            }
        }

        let requestID = PHImageManager.default().requestAVAsset(forVideo: phasset, options: options) { [weak self] asset, audioMix, info in
            guard let strongSelf = self else { return }
            if let asset = asset {
                strongSelf.duration = asset.duration
                strongSelf.asset = asset
                if let track = asset.tracks(withMediaType: .video).first {
                    strongSelf.size = track.naturalSize.applying(track.preferredTransform)
                }
                strongSelf.status = .avaliable
            } else {
                strongSelf.status = .unavaliable
            }
            DispatchQueue.main.async {
                completion(strongSelf.status, nil)
            }
        }

        return ResourceTask.init(cancel: {
            PHImageManager.default().cancelImageRequest(requestID)
        })
    }

    override public func copy(with zone: NSZone? = nil) -> Any {

        let resource = super.copy(with: zone) as! PHAssetTrackResource
        resource.asset = asset
        resource.phasset = phasset

        return resource
    }
}
