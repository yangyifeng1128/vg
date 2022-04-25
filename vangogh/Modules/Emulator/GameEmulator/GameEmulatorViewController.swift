///
/// GameEmulatorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class GameEmulatorViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
    }

    /// 初始化
    init() {

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 视图加载完成
    override func viewDidLoad() {

        super.viewDidLoad()

        initViews()
    }

    /// 视图即将显示
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // 隐藏导航栏

        navigationController?.navigationBar.isHidden = true
    }

    /// 初始化视图
    private func initViews() {

        view.backgroundColor = .systemGroupedBackground
    }
}

extension GameEmulatorViewController {
}
