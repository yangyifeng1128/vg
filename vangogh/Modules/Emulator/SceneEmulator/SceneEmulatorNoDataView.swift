///
/// SceneEmulatorNoDataView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

protocol SceneEmulatorNoDataViewDelegate: AnyObject {
    func editSceneImmediatelyButtonDidTap()
    func editSceneLaterButtonDidTap()
}

class SceneEmulatorNoDataView: UIView {

    /// 视图布局常量枚举值
    enum VC {
        static let contentViewWidth: CGFloat = 240
        static let contentViewHeight: CGFloat = 200
        static let titleLabelFontSize: CGFloat = 22
        static let editSceneImmediatelyButtonHeight: CGFloat = 56
        static let editSceneImmediatelyButtonTitleLabelFontSize: CGFloat = 18
        static let editSceneLaterButtonHeight: CGFloat = 48
        static let editSceneLaterButtonTitleLabelFontSize: CGFloat = 16
    }

    weak var delegate: SceneEmulatorNoDataViewDelegate?

    private var contentView: UIView!
    private var titleLabel: UILabel!
    private var editSceneImmediatelyButton: RoundedButton!
    private var editSceneLaterButton: RoundedButton!

    init() {

        super.init(frame: .zero)

        // 初始化视图

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {

        contentView = UIView()
        contentView.backgroundColor = .clear
        addSubview(contentView)
        contentView.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.contentViewWidth)
            make.height.equalTo(VC.contentViewHeight)
            make.center.equalToSuperview()
        }

        // 初始化标题标签

        titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("SceneEmulatorNoData", comment: "")
        titleLabel.font = .systemFont(ofSize: VC.titleLabelFontSize, weight: .semibold)
        titleLabel.textColor = .lightText
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }

        // 初始化「立即编辑场景」按钮

        editSceneImmediatelyButton = RoundedButton(cornerRadius: GVC.defaultViewCornerRadius)
        editSceneImmediatelyButton.backgroundColor = .white
        editSceneImmediatelyButton.tintColor = .darkText
        editSceneImmediatelyButton.setTitle(NSLocalizedString("EditScene", comment: ""), for: .normal)
        editSceneImmediatelyButton.titleLabel?.font = .systemFont(ofSize: VC.editSceneImmediatelyButtonTitleLabelFontSize, weight: .regular)
        editSceneImmediatelyButton.setTitleColor(.darkText, for: .normal)
        editSceneImmediatelyButton.addTarget(self, action: #selector(editSceneImmediatelyButtonDidTap), for: .touchUpInside)
        contentView.addSubview(editSceneImmediatelyButton)
        editSceneImmediatelyButton.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(VC.editSceneImmediatelyButtonHeight)
            make.left.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(48)
        }

        // 初始化「稍后编辑场景」按钮

        editSceneLaterButton = RoundedButton(cornerRadius: GVC.defaultViewCornerRadius)
        editSceneLaterButton.backgroundColor = .clear
        editSceneLaterButton.tintColor = .lightText
        editSceneLaterButton.setTitle(NSLocalizedString("DecideLater", comment: ""), for: .normal)
        editSceneLaterButton.titleLabel?.font = .systemFont(ofSize: VC.editSceneLaterButtonTitleLabelFontSize, weight: .regular)
        editSceneLaterButton.setTitleColor(.lightText, for: .normal)
        editSceneLaterButton.addTarget(self, action: #selector(editSceneLaterButtonDidTap), for: .touchUpInside)
        contentView.addSubview(editSceneLaterButton)
        editSceneLaterButton.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(VC.editSceneLaterButtonHeight)
            make.left.equalToSuperview()
            make.top.equalTo(editSceneImmediatelyButton.snp.bottom).offset(8)
        }
    }
}

extension SceneEmulatorNoDataView {

    @objc private func editSceneImmediatelyButtonDidTap() {

        delegate?.editSceneImmediatelyButtonDidTap()
    }

    @objc private func editSceneLaterButtonDidTap() {

        delegate?.editSceneLaterButtonDidTap()
    }
}
