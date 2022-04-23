///
/// MetaGameBundleManager
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaGameBundleManager: NSObject {

    static var shared = MetaGameBundleManager()

    func load(uuid: String) -> MetaGameBundle? {

        let bundleFileURL: URL = getMetaGameBundleFileURL(uuid: uuid)
        var metaGameBundle: MetaGameBundle?
        if let encodedData = FileManager.default.contents(atPath: bundleFileURL.path) {
            metaGameBundle = try? JSONDecoder().decode(MetaGameBundle.self, from: encodedData)
        }
        if metaGameBundle == nil {
            metaGameBundle = MetaGameBundle(uuid: uuid)
        }

        return metaGameBundle
    }

    func save(_ bundle: MetaGameBundle) {

        let bundleFileURL: URL = getMetaGameBundleFileURL(uuid: bundle.uuid)
        if let encodedData = try? JSONEncoder().encode(bundle) {
            try? encodedData.write(to: bundleFileURL)
        }
    }

    func delete(uuid: String) {

        let rootDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(GKC.editorDirectoryName).appendingPathComponent(uuid)
        var isDirectory: ObjCBool = true
        if FileManager.default.fileExists(atPath: rootDirectoryURL.path, isDirectory: &isDirectory) {
            try? FileManager.default.removeItem(at: rootDirectoryURL)
        }
    }

    //
    //
    // MARK: - 文件系统相关方法
    //
    //

    private func getMetaGameBundleFileURL(uuid: String) -> URL {

        return getMetaGameSourceDirectoryURL(uuid: uuid).appendingPathComponent(uuid).appendingPathExtension("json")
    }

    private func getMetaGameSourceDirectoryURL(uuid: String) -> URL {

        let rootDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(GKC.editorDirectoryName).appendingPathComponent(uuid).appendingPathComponent(GKC.sourceDirectoryName)
        var isDirectory: ObjCBool = true
        if !FileManager.default.fileExists(atPath: rootDirectoryURL.path, isDirectory: &isDirectory) {
            try? FileManager.default.createDirectory(at: rootDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }

        return rootDirectoryURL
    }
}
