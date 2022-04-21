///
/// AVAssetImageGenerator
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVFoundation
import UIKit

public extension AVAssetImageGenerator {

    static func create(from items: [TrackItem], renderSize: CGSize) -> AVAssetImageGenerator? {

        let timeline = Timeline()
        timeline.videoChannel = items
        timeline.renderSize = renderSize
        let generator = CompositionGenerator(timeline: timeline)
        let imageGenerator = generator.buildImageGenerator()

        return imageGenerator
    }

    static func create(fromAsset asset: AVAsset) -> AVAssetImageGenerator {

        let generator = AVAssetImageGenerator(asset: asset)
        generator.requestedTimeToleranceBefore = CMTime.zero
        generator.requestedTimeToleranceAfter = CMTime.zero
        generator.appliesPreferredTrackTransform = true

        return generator
    }

    func makeCopy() -> AVAssetImageGenerator {

        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = appliesPreferredTrackTransform
        generator.maximumSize = maximumSize
        generator.apertureMode = apertureMode
        generator.videoComposition = videoComposition
        generator.requestedTimeToleranceBefore = requestedTimeToleranceBefore
        generator.requestedTimeToleranceAfter = requestedTimeToleranceAfter

        return generator
    }
}
