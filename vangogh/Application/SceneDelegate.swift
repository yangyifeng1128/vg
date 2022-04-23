///
/// SceneDelegate
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AwaitToast
import OSLog
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    /// 窗体
    var window: UIWindow?

    /// 即将连接应用
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        if let windowScene = scene as? UIWindowScene {

            // 创建窗体

            let window = UIWindow(windowScene: windowScene)
            window.tintColor = .accent

            // 定制吐司提示

            customizeToast()

            // 重写用户界面风格

            overrideUserInterfaceStyle(window: window)

            // 设置「标签栏」为根视图控制器

            setTabBarAsRootController(window: window)
            // setNavigationBarAsRootController(window: window)

            // 显示窗体

            self.window = window
            window.makeKeyAndVisible()
        }
    }

    /// 设置「导航栏」为根视图控制器
    private func setNavigationBarAsRootController(window: UIWindow) {

        let compositionVC = CompositionViewController()
        let mainNavigation = UINavigationController(rootViewController: compositionVC)
        window.rootViewController = mainNavigation
    }

    /// 设置「标签栏」为根视图控制器
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

    /// 定制吐司提示
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

    /// 重写用户界面风格
    private func overrideUserInterfaceStyle(window: UIWindow) {

        if UserDefaults.standard.bool(forKey: GKC.ignoresSystemUserInterfaceStyle) {
            let isInLightMode: Bool = UserDefaults.standard.bool(forKey: GKC.isInLightMode)
            window.overrideUserInterfaceStyle = isInLightMode ? .light : .dark
        } else {
            window.overrideUserInterfaceStyle = .unspecified
        }

        Logger.application.info("overrided user interface style: \(window.overrideUserInterfaceStyle.rawValue)")
    }
}
