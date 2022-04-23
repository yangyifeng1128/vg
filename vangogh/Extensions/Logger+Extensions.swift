///
/// Logger+Extensions
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import OSLog

extension Logger {

    private static let subsystem: String = Bundle.main.bundleIdentifier!

    static let application = Logger(subsystem: subsystem, category: "Application")

    static let appSettings = Logger(subsystem: subsystem, category: "AppSettings")
    static let composition = Logger(subsystem: subsystem, category: "Composition")
    static let gameEditor = Logger(subsystem: subsystem, category: "GameEditor")
    static let sceneEditor = Logger(subsystem: subsystem, category: "SceneEditor")
    static let transitionEditor = Logger(subsystem: subsystem, category: "TransitionEditor")
    static let sceneEmulator = Logger(subsystem: subsystem, category: "SceneEmulator")
    static let home = Logger(subsystem: subsystem, category: "Home")
    static let userAssets = Logger(subsystem: subsystem, category: "UserAssets")

    static let coreData = Logger(subsystem: subsystem, category: "CoreData")

    static let avComposition = Logger(subsystem: subsystem, category: "AVComposition")
}
