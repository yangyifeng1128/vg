///
/// MetaButtonView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class MetaButtonView: MetaNodeView {

    /// 视图布局常量枚举值
    enum VC {
    }

    private(set) var button: MetaButton!
    override var node: MetaNode! {
        get {
            return button
        }
    }

    private var backgroundView: RoundedImageView!
    private var infoLabel: AttributedLabel!

    /// 初始化
    init(button: MetaButton) {

        super.init()

        self.button = button

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        backgroundView = RoundedImageView()
        backgroundView.backgroundColor = UIColor.colorWithRGBA(rgba: button.backgroundColorCode)
        addSubview(backgroundView)

        infoLabel = AttributedLabel()
        infoLabel.text = button.info
        infoLabel.textColor = UIColor.colorWithRGBA(rgba: button.foregroundColorCode)
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 2
        infoLabel.lineBreakMode = .byTruncatingTail
        addSubview(infoLabel)
    }

    override func reloadData() {

        guard let dataSource = dataSource else { return }

        let renderScale: CGFloat = dataSource.renderScale()

//        if playerView.isEditable {
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan)))
//        } else {
//            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
//        }

        // 更新背景视图布局

        backgroundView.cornerRadius = button.cornerRadius * renderScale

        backgroundView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        // 更新信息标签布局

        infoLabel.insets = UIEdgeInsets(top: 0, left: 8 * renderScale, bottom: 0, right: 8 * renderScale)
        infoLabel.font = .systemFont(ofSize: button.fontSize * renderScale, weight: .regular)

        infoLabel.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        // 更新当前视图布局

        // parent.addSubview(self)

        bounds = CGRect(origin: .zero, size: CGSize(width: button.size.width * renderScale, height: button.size.height * renderScale))
        center = CGPoint(x: button.center.x * renderScale, y: button.center.y * renderScale)
    }
}

extension MetaButtonView {

    @objc private func tap() {

        guard let nodeTypeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: button.nodeType) else { return }
        let nodeTitle: String = nodeTypeTitle + " " + button.index.description

        print("[MetaNode] buttonView \"\(nodeTitle)\" did tap")
    }

    @objc private func pan(_ sender: UIPanGestureRecognizer) {

        guard let view = sender.view else { return }

        switch sender.state {
        case .began:
            break

        case .changed:

            guard let dataSource = dataSource else { return }

            let renderScale: CGFloat = dataSource.renderScale()

            let location: CGPoint = sender.location(in: superview)

            // 设置中心坐标

            view.center = location

            // 设置标准设备中心坐标

            let centerX: CGFloat = (location.x / renderScale).rounded()
            let centerY: CGFloat = (location.y / renderScale).rounded()
            button.center = CGPoint(x: centerX, y: centerY)

            // 保存资源包

            // delegate.saveBundleWhenNodeViewChanged(node: button)

            break

        case .ended:
            break

        default:
            break
        }
    }
}
