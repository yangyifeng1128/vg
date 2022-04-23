///
/// LoadingView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class LoadingView: RoundedView {

    /// 视图布局常量枚举值
    enum ViewLayoutConstants {
        static let width: CGFloat = 80
        static let indicatorViewWidth: CGFloat = 32
        static let infoLabelFontSize: CGFloat = 13
    }

    private var indicatorView: UIActivityIndicatorView!
    private var infoLabel: UILabel!

    var progress: CGFloat = 0 {
        didSet {
            let percentage: Int = Int(round(progress * 100))
            infoLabel.text = percentage >= 100 ? "" : "\(percentage)%"
        }
    }

    init() {

        super.init(cornerRadius: GlobalViewLayoutConstants.defaultViewCornerRadius)

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {

        isHidden = true

        backgroundColor = GlobalViewLayoutConstants.defaultSceneControlBackgroundColor

        indicatorView = UIActivityIndicatorView()
        indicatorView.hidesWhenStopped = true
        indicatorView.color = .white
        addSubview(indicatorView)
        indicatorView.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(ViewLayoutConstants.indicatorViewWidth)
            make.center.equalToSuperview()
        }

        infoLabel = UILabel()
        infoLabel.font = .systemFont(ofSize: ViewLayoutConstants.infoLabelFontSize, weight: .regular)
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

    func startAnimating() {

        indicatorView.startAnimating()
        isHidden = false
    }

    func stopAnimating() {

        indicatorView.stopAnimating()
        isHidden = true
        infoLabel.text = ""
    }
}
