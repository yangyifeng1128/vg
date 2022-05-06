///
/// SceneEmulatorGameboardButton
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class SceneEmulatorGameboardButton: RoundedButton {

    /// 视图布局常量枚举值
    enum VC {
        static let iconViewWidth: CGFloat = 24
        static let infoLabelFontSize: CGFloat = 14
    }

    /// 图标视图
    var iconView: UIImageView!
    /// 信息标签
    var infoLabel: UILabel!

    /// 初始化
    override init(cornerRadius: CGFloat) {

        super.init(cornerRadius: cornerRadius)

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = GVC.defaultSceneControlBackgroundColor

        // 初始化「图标视图」

        iconView = UIImageView()
        iconView.image = .emulate
        iconView.tintColor = .mgLabel
        addSubview(iconView)
        iconView.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.iconViewWidth)
            make.centerY.equalToSuperview()
            make.left.equalTo(24)
        }

        // 初始化「信息标签」

        infoLabel = UILabel()
        infoLabel.font = .systemFont(ofSize: VC.infoLabelFontSize, weight: .regular)
        infoLabel.textColor = .mgLabel
        infoLabel.lineBreakMode = .byTruncatingTail
        addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make -> Void in
            make.height.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.left.equalTo(iconView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-24)
        }
    }
}
