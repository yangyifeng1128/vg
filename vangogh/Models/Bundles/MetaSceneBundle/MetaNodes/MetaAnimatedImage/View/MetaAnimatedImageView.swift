///
/// MetaAnimatedImageView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import SwiftyGif
import UIKit

class MetaAnimatedImageView: MetaNodeView {

    /// 视图布局常量枚举值
    enum VC {
    }

    private(set) var animatedImage: MetaAnimatedImage!
    override var node: MetaNode! {
        get {
            return animatedImage
        }
    }

    private var imageView: UIImageView!

    /// 初始化
    init(animatedImage: MetaAnimatedImage) {

        super.init()

        self.animatedImage = animatedImage

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = UIColor.colorWithRGBA(rgba: animatedImage.backgroundColorCode)

        do {
            let image = try UIImage(gifName: "happy.gif")
            imageView = UIImageView(gifImage: image)
            addSubview(imageView)
        } catch {
            print(error.localizedDescription)
        }
    }

    override func reloadData() {

        guard let dataSource = dataSource else { return }

        let renderScale: CGFloat = dataSource.renderScale()

//        if playerView.isEditable {
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan)))
//        } else {
//            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
//        }

        // 更新图像视图布局

        imageView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        // 更新当前视图布局

        // parent.addSubview(self)

        bounds = CGRect(origin: .zero, size: CGSize(width: animatedImage.size.width * renderScale, height: animatedImage.size.height * renderScale))
        center = CGPoint(x: animatedImage.center.x * renderScale, y: animatedImage.center.y * renderScale)
    }
}

extension MetaAnimatedImageView {

    @objc private func tap() {

        guard let nodeTypeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: animatedImage.nodeType) else { return }
        let nodeTitle: String = nodeTypeTitle + " " + animatedImage.index.description

        print("[MetaNode] animatedImageView \"\(nodeTitle)\" did tap")
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
            animatedImage.center = CGPoint(x: centerX, y: centerY)

            // 保存资源包

            // delegate.saveBundleWhenNodeViewChanged(node: animatedImage)

            break

        case .ended:
            break

        default:
            break
        }
    }
}
