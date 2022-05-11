///
/// WorkspaceNoDataView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

protocol WorkspaceNoDataViewDelegate: AnyObject {
    func initialFootageButtonDidTap()
}

class WorkspaceNoDataView: UIView {

    /// 视图布局常量枚举值
    enum VC {
        static let initialFootageButtonWidth: CGFloat = 56
        static let initialFootageButtonImageEdgeInset: CGFloat = 11.2
        static let initialFootageTitleLabelFontSize: CGFloat = 16
    }

    weak var delegate: WorkspaceNoDataViewDelegate?

    private var initialFootageButton: AddFootageButton!
    private var initialFootageTitleLabel: UILabel!

    init() {

        super.init(frame: .zero)

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {

        // 初始化「添加镜头片段」按钮

        initialFootageButton = AddFootageButton(imageEdgeInset: VC.initialFootageButtonImageEdgeInset)
        initialFootageButton.addTarget(self, action: #selector(initialFootageButtonDidTap), for: .touchUpInside)
        addSubview(initialFootageButton)
        initialFootageButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.initialFootageButtonWidth)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-VC.initialFootageButtonWidth / 2)
        }

        // 初始化「添加镜头片段」标题标签

        initialFootageTitleLabel = UILabel()
        initialFootageTitleLabel.text = NSLocalizedString("AddFootage", comment: "")
        initialFootageTitleLabel.font = .systemFont(ofSize: VC.initialFootageTitleLabelFontSize, weight: .regular)
        initialFootageTitleLabel.textColor = .secondaryLabel
        initialFootageTitleLabel.textAlignment = .center
        addSubview(initialFootageTitleLabel)
        initialFootageTitleLabel.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(initialFootageButton.snp.bottom).offset(20)
        }
    }
}

extension WorkspaceNoDataView {

    @objc private func initialFootageButtonDidTap() {

        delegate?.initialFootageButtonDidTap()
    }
}
