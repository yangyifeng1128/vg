///
/// LoadingView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class LoadingView: RoundedView {

    /// 视图常量枚举值
    enum VC {
        static let width: CGFloat = 80
        static let indicatorViewWidth: CGFloat = 32
        static let infoLabelFontSize: CGFloat = 13
    }

    /// 指示器视图
    private var indicatorView: UIActivityIndicatorView!
    /// 信息标签
    private var infoLabel: UILabel!

    /// 加载进度
    var progress: CGFloat = 0 {
        didSet {
            let percentage: Int = Int(round(progress * 100))
            infoLabel.text = percentage >= 100 ? "" : "\(percentage)%"
        }
    }

    /// 初始化
    init() {

        super.init(cornerRadius: GVC.defaultViewCornerRadius)

        // 初始化视图

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }
}

extension LoadingView {

    /// 初始化视图
    private func initViews() {

        isHidden = true

        backgroundColor = GVC.defaultSceneControlBackgroundColor

        // 初始化「指示器视图」

        indicatorView = UIActivityIndicatorView()
        indicatorView.hidesWhenStopped = true
        indicatorView.color = .white
        addSubview(indicatorView)
        indicatorView.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.indicatorViewWidth)
            make.center.equalToSuperview()
        }

        // 初始化「信息标签」

        infoLabel = UILabel()
        infoLabel.font = .systemFont(ofSize: VC.infoLabelFontSize, weight: .regular)
        infoLabel.textColor = .white
        infoLabel.textAlignment = .center
        addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(indicatorView.snp.bottom)
        }
    }
}

extension LoadingView {

    /// 启动加载动画
    func startAnimating() {

        indicatorView.startAnimating()
        isHidden = false
    }

    /// 结束加载动画
    func stopAnimating() {

        indicatorView.stopAnimating()
        isHidden = true
        infoLabel.text = ""
    }
}
