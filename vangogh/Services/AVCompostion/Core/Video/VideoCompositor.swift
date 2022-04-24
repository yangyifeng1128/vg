///
/// VideoCompositor
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVFoundation
import CoreImage

open class VideoCompositor: NSObject, AVFoundation.AVVideoCompositing {

    public static var ciContext: CIContext = CIContext()
    private let renderContextQueue: DispatchQueue = DispatchQueue(label: "cabbage.videocore.rendercontextqueue")
    private let renderingQueue: DispatchQueue = DispatchQueue(label: "cabbage.videocore.renderingqueue")
    private var renderContextDidChange = false
    private var shouldCancelAllRequests = false
    private var renderContext: AVVideoCompositionRenderContext?

    public var sourcePixelBufferAttributes: [String: Any]? =
        [String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
         String(kCVPixelBufferOpenGLESCompatibilityKey): true,
         String(kCVPixelBufferMetalCompatibilityKey): true]

    public var requiredPixelBufferAttributesForRenderContext: [String: Any] =
        [String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32BGRA,
         String(kCVPixelBufferOpenGLESCompatibilityKey): true,
         String(kCVPixelBufferMetalCompatibilityKey): true]

    open func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext) {
        renderContextQueue.sync(execute: { [weak self] in
            guard let s = self else { return }
            s.renderContext = newRenderContext
            s.renderContextDidChange = true
        })
    }

    public enum PixelBufferRequestError: Error {
        case newRenderedPixelBufferForRequestFailure
    }

    open func startRequest(_ request: AVAsynchronousVideoCompositionRequest) {

        renderingQueue.async(execute: { [weak self] in
            guard let s = self else { return }
            if s.shouldCancelAllRequests {
                request.finishCancelledRequest()
            } else {
                autoreleasepool {
                    if let resultPixels = s.newRenderedPixelBufferForRequest(request: request) {
                        request.finish(withComposedVideoFrame: resultPixels)
                    } else {
                        request.finish(with: PixelBufferRequestError.newRenderedPixelBufferForRequestFailure)
                    }
                }
            }
        })
    }

    open func cancelAllPendingVideoCompositionRequests() {

        shouldCancelAllRequests = true
        renderingQueue.async(flags: .barrier) { [weak self] in
            guard let s = self else { return }
            s.shouldCancelAllRequests = false
        }
    }

    open func newRenderedPixelBufferForRequest(request: AVAsynchronousVideoCompositionRequest) -> CVPixelBuffer? {

        guard let outputPixels = renderContext?.newPixelBuffer() else { return nil }
        guard let instruction = request.videoCompositionInstruction as? VideoCompositionInstruction else {
            return nil
        }
        var image = CIImage(cvPixelBuffer: outputPixels)

        // Background
        let backgroundImage = CIImage(color: instruction.backgroundColor).cropped(to: image.extent)
        image = backgroundImage

        if let destinationImage = instruction.apply(request: request) {
            image = destinationImage.composited(over: image)
        }

        VideoCompositor.ciContext.render(image, to: outputPixels)

        return outputPixels
    }
}
