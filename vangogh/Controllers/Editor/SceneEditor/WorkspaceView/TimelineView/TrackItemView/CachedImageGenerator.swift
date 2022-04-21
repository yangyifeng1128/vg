///
/// CachedImageGenerator
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVFoundation
import UIKit

class CachedImageGenerator: AVAssetImageGenerator {

    private var cache: ReusableImageCache<NSValue, CGImage> = ReusableImageCache()
    private var memoryWarningObserver: NSObjectProtocol?

    deinit {
        if let observer = memoryWarningObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    static func createFrom(_ imageGenerator: AVAssetImageGenerator) -> CachedImageGenerator {

        let generator = CachedImageGenerator(asset: imageGenerator.asset)
        generator.appliesPreferredTrackTransform = imageGenerator.appliesPreferredTrackTransform
        generator.maximumSize = imageGenerator.maximumSize
        generator.apertureMode = imageGenerator.apertureMode
        generator.videoComposition = imageGenerator.videoComposition
        generator.requestedTimeToleranceBefore = imageGenerator.requestedTimeToleranceBefore
        generator.requestedTimeToleranceAfter = imageGenerator.requestedTimeToleranceAfter

        return generator
    }

    override init(asset: AVAsset) {

        super.init(asset: asset)

        cache.limitCount = 1024
        memoryWarningObserver = NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification, object: self, queue: OperationQueue.main) { [weak self] notification in
            guard let strongSelf = self else { return }
            strongSelf.cache.clear()
        }
    }

    override func generateCGImagesAsynchronously(forTimes requestedTimes: [NSValue], completionHandler handler: @escaping AVAssetImageGeneratorCompletionHandler) {

        var times: [NSValue] = []
        for time in requestedTimes {
            if let image = cache.get(key: time) {
                handler(time.timeValue, image, time.timeValue, .succeeded, nil)
            } else {
                times.append(time)
            }
        }
        guard times.count > 0 else { return }
        super.generateCGImagesAsynchronously(forTimes: times) { [weak self] time1, cgimage, time2, result, error in
            self?.cache.set(object: cgimage, key: NSValue(time: time1))
            handler(time1, cgimage, time2, result, error)
        }
    }

    override func copyCGImage(at requestedTime: CMTime, actualTime: UnsafeMutablePointer<CMTime>?) throws -> CGImage {

        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        let key = NSValue(time: requestedTime)
        if let image = cache.get(key: key) {
            return image
        }
        do {
            let cgimage = try super.copyCGImage(at: requestedTime, actualTime: actualTime)
            cache.set(object: cgimage, key: key)
            return cgimage
        } catch let e {
            throw e
        }
    }

    func getCachedImage(at time: CMTime) -> CGImage? {

        let key = NSValue(time: time)
        if let image = cache.get(key: key) {
            return image
        }
        return nil
    }
}

class ReusableImageCache<K: Hashable, V> {

    private var keys: [K] = []
    private var cache: [K: V] = [:]
    private let semaphore = DispatchSemaphore(value: 1)
    var limitCount = 0 // 0: 没有限制

    init() {
    }

    func set(object: V?, key: K) {

        guard let object = object else { return }
        semaphore.wait()
        keys.insert(key, at: 0)
        cache[key] = object
        checkCount()
        semaphore.signal()
    }

    func get(key: K) -> V? {

        semaphore.wait()
        if let index = keys.firstIndex(of: key) {
            keys.remove(at: index)
            keys.insert(key, at: 0)
        }
        let res = cache[key]
        semaphore.signal()

        return res
    }

    func clear() {

        semaphore.wait()
        keys.removeAll()
        cache.removeAll()
        semaphore.signal()
    }

    private func checkCount() {

        guard limitCount > 0 else { return }
        if keys.count > limitCount {
            let k = keys.removeLast()
            cache.removeValue(forKey: k)
        }
    }
}
