///
/// MetaThumbManager
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaThumbManager: NSObject {

    static var shared = MetaThumbManager()

    func loadGameThumbImage(gameUUID: String) -> UIImage? {

        let thumbFileURL: URL = getThumbImageFileURL(uuid: gameUUID, gameUUID: gameUUID)
        var thumbImage: UIImage?
        if let encodedData = FileManager.default.contents(atPath: thumbFileURL.path) {
            thumbImage = UIImage(data: encodedData)
        }

        return thumbImage
    }

    func saveGameThumbImage(gameUUID: String, image: UIImage) {

        let thumbFileURL = getThumbImageFileURL(uuid: gameUUID, gameUUID: gameUUID)
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            try? imageData.write(to: thumbFileURL)
        }
    }

    func loadSceneThumbImage(sceneUUID: String, gameUUID: String) -> UIImage? {

        let thumbFileURL: URL = getThumbImageFileURL(uuid: sceneUUID, gameUUID: gameUUID)
        var thumbImage: UIImage?
        if let encodedData = FileManager.default.contents(atPath: thumbFileURL.path) {
            thumbImage = UIImage(data: encodedData)
        }

        return thumbImage
    }

    func saveSceneThumbImage(sceneUUID: String, gameUUID: String, image: UIImage) {

        let thumbFileURL = getThumbImageFileURL(uuid: sceneUUID, gameUUID: gameUUID)
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            try? imageData.write(to: thumbFileURL)
        }
    }

    //
    //
    // MARK: - 文件系统相关方法
    //
    //

    private func getThumbImageFileURL(uuid: String, gameUUID: String) -> URL {

        return getThumbImageFilesRootDirectoryURL(gameUUID: gameUUID).appendingPathComponent(uuid).appendingPathExtension("jpg")
    }

    private func getThumbImageFilesRootDirectoryURL(gameUUID: String) -> URL {

        let rootDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(GKC.editorDirectoryName).appendingPathComponent(gameUUID).appendingPathComponent(GKC.sourceDirectoryName).appendingPathComponent(GKC.thumbImageFilesDirectoryName)
        var isDirectory: ObjCBool = true
        if !FileManager.default.fileExists(atPath: rootDirectoryURL.path, isDirectory: &isDirectory) {
            try? FileManager.default.createDirectory(at: rootDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }

        return rootDirectoryURL
    }
}
