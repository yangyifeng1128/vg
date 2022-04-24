///
/// MetaTextView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class MetaTextView: MetaNodeView {

    /// 视图布局常量枚举值
    enum VC {
    }

    private(set) var text: MetaText!
    override var node: MetaNode! {
        get {
            return text
        }
    }

    private var infoLabel: AttributedLabel!

    /// 初始化
    init(text: MetaText) {

        super.init()

        self.text = text

        // 初始化视图

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = UIColor.colorWithRGBA(rgba: text.backgroundColorCode)

        infoLabel = AttributedLabel()
        infoLabel.text = text.info
        infoLabel.textColor = UIColor.colorWithRGBA(rgba: text.foregroundColorCode)
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 4
        infoLabel.lineBreakMode = .byTruncatingTail
        infoLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        infoLabel.layer.shadowOpacity = 1
        infoLabel.layer.shadowRadius = 1
        infoLabel.layer.shadowColor = UIColor.black.cgColor
        addSubview(infoLabel)
    }

    override func layout(parent: UIView) {

        guard let playerView = playerView, let renderScale = playerView.renderScale else { return }

        if playerView.isEditable {
            addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan)))
        }

        // 更新信息标签布局

        infoLabel.insets = UIEdgeInsets(top: 0, left: 8 * renderScale, bottom: 0, right: 8 * renderScale)
        infoLabel.font = .systemFont(ofSize: text.fontSize * renderScale, weight: .regular)

        infoLabel.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        // 更新当前视图布局

        parent.addSubview(self)

        bounds = CGRect(origin: .zero, size: CGSize(width: text.size.width * renderScale, height: text.size.height * renderScale))
        center = CGPoint(x: text.center.x * renderScale, y: text.center.y * renderScale)
    }
}

extension MetaTextView {

    @objc private func pan(_ sender: UIPanGestureRecognizer) {

        guard let view = sender.view else { return }

        switch sender.state {
        case .began:
            break

        case .changed:

            guard let playerView = playerView, let renderScale = playerView.renderScale else { return }

            let location: CGPoint = sender.location(in: superview)

            // 设置中心坐标

            view.center = location

            // 设置标准设备中心坐标

            let centerX: CGFloat = (location.x / renderScale).rounded()
            let centerY: CGFloat = (location.y / renderScale).rounded()
            text.center = CGPoint(x: centerX, y: centerY)

            // 保存资源包

            playerView.saveBundleWhenNodeViewChanged(node: text)

            break

        case .ended:
            break

        default:
            break
        }
    }
}
