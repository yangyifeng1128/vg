///
/// PHAssetImageResource
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVFoundation
import CoreImage
import Photos

open class PHAssetImageResource: ImageResource {

    open var asset: PHAsset?

    public init(asset: PHAsset, duration: CMTime) {

        super.init()

        self.asset = asset
        self.duration = duration
        self.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: duration)
    }

    required public init() {

        super.init()
    }

    open override func image(at time: CMTime, renderSize: CGSize) -> CIImage? {

        return image
    }

    @discardableResult
    open func prepare(targetSize: CGSize, progressHandler: ((Double) -> Void)? = nil, completion: @escaping (ResourceStatus, Error?) -> Void) -> ResourceTask? {

        status = .unavaliable
        statusError = NSError.init(domain: "com.resource.status", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Empty resource", comment: "")])

        guard let asset = asset else {
            completion(status, statusError)
            return nil
        }

        let progressHandler: PHAssetImageProgressHandler = { (progress, error, stop, info) in
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

        let options = PHImageRequestOptions()
        options.version = .current
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = progressHandler
        let requestID = PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { [weak self] image, info in
            guard let s = self else { return }
            if let error = info?[PHImageErrorKey] as? NSError {
                DispatchQueue.main.async {
                    s.statusError = error
                    s.status = .unavaliable
                    completion(s.status, s.statusError)
                }
                return
            }
            DispatchQueue.main.async {
                if let image = image {
                    s.size = image.size
                    s.image = CIImage(image: image)
                }
                s.status = .avaliable
                completion(s.status, s.statusError)
            }
        }

        return ResourceTask.init(cancel: {
            PHImageManager.default().cancelImageRequest(requestID)
        })
    }

    override open func copy(with zone: NSZone? = nil) -> Any {

        let resource = super.copy(with: zone) as! PHAssetImageResource
        resource.asset = asset

        return resource
    }
}
