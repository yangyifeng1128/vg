///
/// AudioProcessingChain
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVFoundation

public protocol AudioProcessingNode: AnyObject {
    func process(timeRange: CMTimeRange, bufferListInOut: UnsafeMutablePointer<AudioBufferList>)
}

public class AudioProcessingChain: NSObject, NSCopying {
    public var nodes: [AudioProcessingNode] = []

    public func process(timeRange: CMTimeRange, bufferListInOut: UnsafeMutablePointer<AudioBufferList>) {
        nodes.forEach { (node) in
            node.process(timeRange: timeRange, bufferListInOut: bufferListInOut)
        }
    }

    public required override init() {

        super.init()
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let chain = type(of: self).init()
        chain.nodes = nodes
        return chain
    }
}
