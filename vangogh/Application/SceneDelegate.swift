///
/// SceneDelegate
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AwaitToast
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        customizeToast()

        if let windowScene = scene as? UIWindowScene {

            let window = UIWindow(windowScene: windowScene)
            window.tintColor = .accent
            if UserDefaults.standard.bool(forKey: "ignoresSystemUserInterfaceStyle") {
                let isInLightMode: Bool = UserDefaults.standard.bool(forKey: "isInLightMode")
                window.overrideUserInterfaceStyle = isInLightMode ? .light : .dark
            }

            setTabBarAsRootController(window: window)
            // setNavigationBarAsRootController(window: window)

            self.window = window

            window.makeKeyAndVisible()
        }
    }

    private func setNavigationBarAsRootController(window: UIWindow) {

        let compositionVC = CompositionViewController()
        let mainNavigation = UINavigationController(rootViewController: compositionVC)
        window.rootViewController = mainNavigation
    }

    private func setTabBarAsRootController(window: UIWindow) {

        let mainTabBar = MainTabBarController()
        window.rootViewController = mainTabBar
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}

extension SceneDelegate {

    private func customizeToast () {

        let defaultAppearance = ToastAppearanceManager.default
        defaultAppearance.height = 64
        if let backgroundColor = UIColor.accent {
            defaultAppearance.backgroundColor = backgroundColor
        }
        defaultAppearance.textFont = .systemFont(ofSize: 16)

        let defaultBehavior = ToastBehaviorManager.default
        defaultBehavior.duration = 0.8
    }
}
