///
/// MainTabBarController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import OSLog
import UIKit

class MainTabBarController: UITabBarController {

    /// 视图加载完成
    override func viewDidLoad() {

        super.viewDidLoad()

        delegate = self

        view.tintColor = .accent
        tabBar.unselectedItemTintColor = .mgLabel

        // 为 UITabBarItem 设置字体

        // UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10, weight: .regular)], for: .normal)
    }

    /// 视图即将显示
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        initViewControllers()
    }

    /// 初始化视图控制器
    private func initViewControllers() {

        let homeVC: HomeViewController = HomeViewController()
        let homeNav: UINavigationController = UINavigationController(rootViewController: homeVC)
        let homeItem: UITabBarItem = UITabBarItem(title: NSLocalizedString("Play", comment: ""), image: .emulate, selectedImage: .emulate)
        homeVC.tabBarItem = homeItem

        let compositionVC: CompositionViewController = CompositionViewController()
        let compositionNav: UINavigationController = UINavigationController(rootViewController: compositionVC)
        let compositionItem: UITabBarItem = UITabBarItem(title: NSLocalizedString("Compose", comment: ""), image: .compose, selectedImage: .compose)
        compositionNav.tabBarItem = compositionItem

        viewControllers = [homeNav, compositionNav]

        detectFirstTimeUserIntent()
    }

    /// 探测首次访问用户意图
    private func detectFirstTimeUserIntent() {

        let isOldFriend: Bool = UserDefaults.standard.bool(forKey: GKC.isOldFriend)
        if !isOldFriend {
            let wantsCompose: Bool = true
            selectedIndex = wantsCompose ? 1 : 0
            UserDefaults.standard.setValue(selectedIndex, forKey: GKC.currentMainTabBarItemIndex)
            UserDefaults.standard.set(true, forKey: GKC.isOldFriend)
        } else {
            selectedIndex = UserDefaults.standard.integer(forKey: GKC.currentMainTabBarItemIndex)
        }
    }
}

extension MainTabBarController: UITabBarControllerDelegate {

    /// 选中标签栏的某个标签
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {

        guard let title = viewController.tabBarItem.title else { return }

        UserDefaults.standard.setValue(tabBarController.selectedIndex, forKey: GKC.currentMainTabBarItemIndex)

        Logger.application.info("selected main tab bar item: \(title)")
    }
}
