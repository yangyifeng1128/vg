///
/// AppDelegate.swift
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import OSLog
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    //
    //
    // MARK: - 应用程序生命周期
    //
    //

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    //
    //
    // MARK: - 设备方向
    //
    //

    var orientations: UIInterfaceOrientationMask = .portrait {
        didSet {
            if orientations.contains(.portrait) {
                // 强制设置为竖屏
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            } else {
                // 强制设置为横屏
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            }
        }
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {

        return orientations
    }

    //
    //
    // MARK: - 后台处理 URL Session
    //
    //

    var backgroundCompletionHandler: (() -> Void)?

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {

        if identifier == GKC.downloadTemplatesURLSessionIdentifier {
            backgroundCompletionHandler = completionHandler
        }

        Logger.application.info("handling events for background URL session: \"\(identifier)\"")
    }
}
