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

    init() {

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    //
    //
    // MARK: - 视图生命周期
    //
    //

    override func viewDidLoad() {

        super.viewDidLoad()

        // 初始化视图

        initViews()
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // 隐藏导航栏

        navigationController?.navigationBar.isHidden = true
    }

    //
    //
    // MARK: - 初始化子视图
    //
    //

    private func initViews() {

        view.backgroundColor = .systemGroupedBackground
    }
}

extension GameEmulatorViewController {
}
