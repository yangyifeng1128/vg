///
/// MetaSceneBundleManager
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVFoundation
import UIKit

class MetaSceneBundleManager: NSObject {

    static var shared = MetaSceneBundleManager()

    func load(sceneUUID: String, gameUUID: String) -> MetaSceneBundle? {

        let bundleFileURL: URL = getMetaSceneBundleFileURL(sceneUUID: sceneUUID, gameUUID: gameUUID)
        var sceneBundle: MetaSceneBundle?
        if let encodedData = FileManager.default.contents(atPath: bundleFileURL.path) {
            sceneBundle = try? JSONDecoder().decode(MetaSceneBundle.self, from: encodedData)
        }
        if sceneBundle == nil {
            sceneBundle = MetaSceneBundle(sceneUUID: sceneUUID, gameUUID: gameUUID)
        }

        return sceneBundle
    }

    func save(_ sceneBundle: MetaSceneBundle) {

        let sceneBundleFileURL: URL = getMetaSceneBundleFileURL(sceneUUID: sceneBundle.sceneUUID, gameUUID: sceneBundle.gameUUID)
        if let encodedData = try? JSONEncoder().encode(sceneBundle) {
            try? encodedData.write(to: sceneBundleFileURL)
        }
    }

    func delete(sceneUUID: String, gameUUID: String) {

        let sceneDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(GKC.editorDirectoryName).appendingPathComponent(gameUUID).appendingPathComponent(GKC.sourceDirectoryName).appendingPathComponent(GKC.scenesDirectoryName).appendingPathComponent(sceneUUID)
        var isDirectory: ObjCBool = true
        if FileManager.default.fileExists(atPath: sceneDirectoryURL.path, isDirectory: &isDirectory) {
            try? FileManager.default.removeItem(at: sceneDirectoryURL)
        }
    }

    //
    //
    // MARK: - 镜头片段 footage 相关的方法
    //
    //

    func addMetaImageFootage(sceneBundle: MetaSceneBundle, image: UIImage) {

        sceneBundle.maxFootageIndex = sceneBundle.maxFootageIndex + 1

        let durationMilliseconds: Int64 = GVC.defaultImageTrackItemDurationMilliseconds
        let footage: MetaFootage = MetaFootage(index: sceneBundle.maxFootageIndex, footageType: .image, durationMilliseconds: durationMilliseconds, maxDurationMilliseconds: 0)

        let footageURL: URL = getMetaImageFootageFileURL(footageUUID: footage.uuid, sceneUUID: sceneBundle.sceneUUID, gameUUID: sceneBundle.gameUUID)
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            try? imageData.write(to: footageURL)
            sceneBundle.footages.append(footage)
            save(sceneBundle)
        }
    }

    func addMetaVideoFootage(sceneBundle: MetaSceneBundle, asset: AVAsset) {

        sceneBundle.maxFootageIndex = sceneBundle.maxFootageIndex + 1

        let durationMilliseconds: Int64 = asset.duration.milliseconds()
        let footage = MetaFootage(index: sceneBundle.maxFootageIndex, footageType: .video, durationMilliseconds: durationMilliseconds, maxDurationMilliseconds: durationMilliseconds)

        let footageURL: URL = getMetaVideoFootageFileURL(footageUUID: footage.uuid, sceneUUID: sceneBundle.sceneUUID, gameUUID: sceneBundle.gameUUID)
        if let asset = asset as? AVURLAsset, let videoData: NSData = NSData(contentsOf: asset.url) {
            videoData.write(to: footageURL, atomically: true)
            sceneBundle.footages.append(footage)
            save(sceneBundle)
        }
    }

    func deleteMetaFootage(sceneBundle: MetaSceneBundle, footage: MetaFootage) {

        for (i, f) in sceneBundle.footages.enumerated().reversed() {

            if f == footage {

                deleteMetaFootageFile(sceneBundle: sceneBundle, footage: footage)

                sceneBundle.footages.remove(at: i)
                sceneBundle.currentTimeMilliseconds = sceneBundle.footages.enumerated().filter({ $0.0 < i }).map({ $0.1.durationMilliseconds }).reduce(0, +) // 记录当前时刻为「已删除镜头片段」的开始时刻
                save(sceneBundle)

                break
            }
        }
    }

    func deleteMetaFootageFile(sceneBundle: MetaSceneBundle, footage: MetaFootage) {

        var footageFileExtension: String
        switch footage.footageType {
        case .image:
            footageFileExtension = "jpg"
            break
        case .video:
            footageFileExtension = "mp4"
            break
        }

        let footageDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(GKC.editorDirectoryName).appendingPathComponent(sceneBundle.gameUUID).appendingPathComponent(GKC.sourceDirectoryName).appendingPathComponent(GKC.scenesDirectoryName).appendingPathComponent(sceneBundle.sceneUUID).appendingPathComponent(footage.uuid).appendingPathExtension(footageFileExtension)
        var isDirectory: ObjCBool = true
        if FileManager.default.fileExists(atPath: footageDirectoryURL.path, isDirectory: &isDirectory) {
            try? FileManager.default.removeItem(at: footageDirectoryURL)
        }
    }

    //
    //
    // MARK: - 组件 Node 相关的方法
    //
    //

    func addMetaNode(sceneBundle: MetaSceneBundle, nodeType: MetaNodeType, startTimeMilliseconds: Int64) -> MetaNode {

        sceneBundle.maxNodeIndex = sceneBundle.maxNodeIndex + 1

        var node: MetaNode
        switch nodeType {
        case .music:
            node = MetaMusic(index: sceneBundle.maxNodeIndex, startTimeMilliseconds: startTimeMilliseconds)
            break
        case .voiceOver:
            node = MetaVoiceOver(index: sceneBundle.maxNodeIndex, startTimeMilliseconds: startTimeMilliseconds)
            break
        case .text:
            node = MetaText(index: sceneBundle.maxNodeIndex, startTimeMilliseconds: startTimeMilliseconds)
            break
        case .animatedImage:
            node = MetaAnimatedImage(index: sceneBundle.maxNodeIndex, startTimeMilliseconds: startTimeMilliseconds)
            break
        case .button:
            node = MetaButton(index: sceneBundle.maxNodeIndex, startTimeMilliseconds: startTimeMilliseconds, backgroundImageName: "abc", highlightedBackgroundImageName: "def")
            break
        case .vote:
            node = MetaVote(index: sceneBundle.maxNodeIndex, startTimeMilliseconds: startTimeMilliseconds)
            break
        case .multipleChoice:
            node = MetaMultipleChoice(index: sceneBundle.maxNodeIndex, startTimeMilliseconds: startTimeMilliseconds)
            break
        case .hotspot:
            node = MetaHotspot(index: sceneBundle.maxNodeIndex, startTimeMilliseconds: startTimeMilliseconds)
            break
        case .checkpoint:
            node = MetaCheckpoint(index: sceneBundle.maxNodeIndex, startTimeMilliseconds: startTimeMilliseconds)
            break
        case .bulletScreen:
            node = MetaBulletScreen(index: sceneBundle.maxNodeIndex, startTimeMilliseconds: startTimeMilliseconds)
            break
        case .sketch:
            node = MetaSketch(index: sceneBundle.maxNodeIndex, startTimeMilliseconds: startTimeMilliseconds)
            break
        case .coloring:
            node = MetaColoring(index: sceneBundle.maxNodeIndex, startTimeMilliseconds: startTimeMilliseconds)
            break
        case .camera:
            node = MetaCamera(index: sceneBundle.maxNodeIndex, startTimeMilliseconds: startTimeMilliseconds)
            break
        case .arCamera:
            node = MetaARCamera(index: sceneBundle.maxNodeIndex, startTimeMilliseconds: startTimeMilliseconds)
            break
        case .duet:
            node = MetaDuet(index: sceneBundle.maxNodeIndex, startTimeMilliseconds: startTimeMilliseconds)
            break
        }

        sceneBundle.nodes.append(node)
        save(sceneBundle)

        return node
    }

    func deleteMetaNode(sceneBundle: MetaSceneBundle, node: MetaNode) {

        for (i, n) in sceneBundle.nodes.enumerated().reversed() {
            if n.uuid == node.uuid {
                sceneBundle.nodes.remove(at: i)
                save(sceneBundle)
                break
            }
        }
    }

    //
    //
    // MARK: - 文件系统相关方法
    //
    //

    private func getMetaSceneBundleFileURL(sceneUUID: String, gameUUID: String) -> URL {

        return getMetaSceneDirectoryURL(sceneUUID: sceneUUID, gameUUID: gameUUID).appendingPathComponent(sceneUUID).appendingPathExtension("json")
    }

    func getMetaImageFootageFileURL(footageUUID: String, sceneUUID: String, gameUUID: String) -> URL {

        return getMetaSceneDirectoryURL(sceneUUID: sceneUUID, gameUUID: gameUUID).appendingPathComponent(footageUUID).appendingPathExtension("jpg")
    }

    func getMetaVideoFootageFileURL(footageUUID: String, sceneUUID: String, gameUUID: String) -> URL {

        return getMetaSceneDirectoryURL(sceneUUID: sceneUUID, gameUUID: gameUUID).appendingPathComponent(footageUUID).appendingPathExtension("mp4")
    }

    private func getMetaSceneDirectoryURL(sceneUUID: String, gameUUID: String) -> URL {

        let rootDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(GKC.editorDirectoryName).appendingPathComponent(gameUUID).appendingPathComponent(GKC.sourceDirectoryName).appendingPathComponent(GKC.scenesDirectoryName).appendingPathComponent(sceneUUID)
        var isDirectory: ObjCBool = true
        if !FileManager.default.fileExists(atPath: rootDirectoryURL.path, isDirectory: &isDirectory) {
            try? FileManager.default.createDirectory(at: rootDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }

        return rootDirectoryURL
    }
}
