///
/// MainTabBarController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MainTabBarController: UITabBarController {

    //
    //
    // MARK: - 视图生命周期
    //
    //

    override func viewDidLoad() {

        super.viewDidLoad()

        delegate = self

        view.tintColor = .accent
        tabBar.unselectedItemTintColor = .mgLabel

        // 为 UITabBarItem 设置字体

        // UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10, weight: .regular)], for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        initViewControllers()
    }

    private func initViewControllers() {

        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        let homeItem = UITabBarItem(title: NSLocalizedString("Play", comment: ""), image: .emulate, selectedImage: .emulate)
        homeVC.tabBarItem = homeItem

        let compositionVC = CompositionViewController()
        let compositionNav = UINavigationController(rootViewController: compositionVC)
        let compositionItem = UITabBarItem(title: NSLocalizedString("Compose", comment: ""), image: .compose, selectedImage: .compose)
        compositionNav.tabBarItem = compositionItem

        viewControllers = [homeNav, compositionNav]

        detectFirstTimeUserIntent()
    }

    private func detectFirstTimeUserIntent() {

        let isOldFriend: Bool = UserDefaults.standard.bool(forKey: "isOldFriend")
        if !isOldFriend {
            let wantsCompose: Bool = true
            selectedIndex = wantsCompose ? 1 : 0
            UserDefaults.standard.setValue(selectedIndex, forKey: "CurrentMainTabBarItemIndex")
            UserDefaults.standard.set(true, forKey: "isOldFriend")
        } else {
            selectedIndex = UserDefaults.standard.integer(forKey: "CurrentMainTabBarItemIndex")
        }
    }
}

extension MainTabBarController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {

        guard let title = viewController.tabBarItem.title else { return }

        print("[MainTabBar] did select item at: \(title)")

        UserDefaults.standard.setValue(tabBarController.selectedIndex, forKey: "CurrentMainTabBarItemIndex")
    }
}
