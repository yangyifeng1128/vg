///
/// AVAssetReaderImageResource
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVFoundation
import CoreImage
import Foundation

let loadBufferQueue: DispatchQueue = DispatchQueue(label: "com.cabbage.reader.loadbuffer")

private var operationQueue: OperationQueue = {
    let queue = OperationQueue.init()
    queue.maxConcurrentOperationCount = 1
    queue.name = "com.cabbage.reader.loadqueue"
    return queue
}()

/// Load image from AVAssetReader as video frame

open class AVAssetReaderImageResource: ImageResource {

    public private(set) var asset: AVAsset?
    public private(set) var videoComposition: AVVideoComposition?

    private var lastReaderTime = CMTime.zero

    private var assetReader: AVAssetReader?
    private var trackOutput: AVAssetReaderOutput?

    public init(asset: AVAsset, videoComposition: AVVideoComposition? = nil) {

        super.init()

        self.asset = asset
        self.videoComposition = videoComposition
        let duration = CMTimeMakeWithSeconds(asset.duration.seconds, preferredTimescale: GVC.preferredTimescale)
        selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: duration)
    }

    required public init() {

        super.init()
    }

    open override func image(at time: CMTime, renderSize: CGSize) -> CIImage? {

        let time = sourceTime(for: time)
        let sampleBuffer: CMSampleBuffer? = loadSamplebuffer(for: time)
        if let sampleBuffer = sampleBuffer, let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            return CIImage(cvPixelBuffer: imageBuffer)
        }

        return image
    }

    // TODO: 解决 seek 问题
    private func loadSamplebuffer(for time: CMTime) -> CMSampleBuffer? {

        var currentSampleBuffer: CMSampleBuffer?

        if time < self.lastReaderTime || time.seconds > self.lastReaderTime.seconds + 1.0 {
            self.cleanReader()
        }

        if self.assetReader == nil || self.trackOutput == nil {
            self.createAssetReaderOutput(at: time)
        }

        if self.assetReader == nil || self.trackOutput == nil {
            return nil
        }

        self.lastReaderTime = time

        while let sampleBuffer = self.trackOutput?.copyNextSampleBuffer() {
            if CMSampleBufferGetImageBuffer(sampleBuffer) != nil {
                let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                if presentationTime.seconds > time.seconds - 0.017 {
                    currentSampleBuffer = sampleBuffer
                    break
                }
            }
        }

        return currentSampleBuffer
    }

    private func createAssetReaderOutput(at time: CMTime) {

        guard let asset = asset, let reader = try? AVAssetReader.init(asset: asset), !asset.tracks(withMediaType: .video).isEmpty else {
            return
        }

        let outputSettings: [String: Any] =
            [String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32BGRA,
             String(kCVPixelBufferOpenGLESCompatibilityKey): true]
        let trackOutput: AVAssetReaderOutput = {
            if let videoComposition = self.videoComposition {
                let tracks = asset.tracks(withMediaType: .video)
                let output = AVAssetReaderVideoCompositionOutput(videoTracks: tracks, videoSettings: outputSettings)
                output.videoComposition = videoComposition
                return output
            }
            let track = asset.tracks(withMediaType: .video).first!
            return AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
        }()
        trackOutput.alwaysCopiesSampleData = false

        guard reader.canAdd(trackOutput) else {
            return
        }
        reader.add(trackOutput)
        reader.timeRange = CMTimeRange(start: time, end: selectedTimeRange.end)
        reader.startReading()

        self.assetReader = reader
        self.trackOutput = trackOutput
    }

    private func cleanReader() {

        self.assetReader?.cancelReading()
        self.assetReader = nil
        self.trackOutput = nil
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

                defer {
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
                    return
                }
                let durationStatus = asset.statusOfValue(forKey: "duration", error: &error)
                if durationStatus != .loaded {
                    s.statusError = error
                    s.status = .unavaliable
                    Log.error("Failed to duration tracks, status: \(tracksStatus), error: \(String(describing: error))")
                    return
                }
            })

            return ResourceTask.init(cancel: {
                asset.cancelLoading()
            })

        } else {

            completion(status, statusError)
        }

        return nil
    }

    override open func copy(with zone: NSZone? = nil) -> Any {

        let resource = super.copy(with: zone) as! AVAssetReaderImageResource
        resource.asset = asset

        return resource
    }
}
