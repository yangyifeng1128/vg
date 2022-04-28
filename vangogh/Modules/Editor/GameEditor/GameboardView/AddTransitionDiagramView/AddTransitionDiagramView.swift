///
/// AddTransitionDiagramView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class AddTransitionDiagramView: RoundedView {

    /// 视图布局常量枚举值
    enum VC {
        static let width: CGFloat = 128
        static let height: CGFloat = 48
        static let borderLayerWidth: CGFloat = 1
        static let iconViewWidth: CGFloat = 24
        static let sceneIndexLabelFontSize: CGFloat = 14
        static let arrowViewWidth: CGFloat = 16
    }

    /// 边框图层
    var borderLayer: CAShapeLayer!
    /// 箭头视图
    var arrowView: ArrowView!

    /// 开始场景视图
    var startSceneView: RoundedImageView!
    /// 开始场景索引标签
    var startSceneIndexLabel: UILabel!
    /// 结束场景视图
    var endSceneView: RoundedImageView!
    /// 结束场景索引标签
    var endSceneIndexLabel: UILabel!

    /// 初始化
    init() {

        super.init(cornerRadius: VC.height / 2)

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 重写布局子视图方法
    override func layoutSubviews() {

        addBorderLayer()
    }

    /// 重写用户界面风格变化处理方法
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)

        addBorderLayer()

        arrowView.arrowLayerColor = UIColor.accent?.cgColor
        arrowView.updateView()
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = .systemBackground

        // 初始化「图标视图」

        let iconView: UIImageView = UIImageView()
        iconView.image = .addLink
        iconView.tintColor = .accent
        addSubview(iconView)
        iconView.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.iconViewWidth)
            make.centerY.equalToSuperview()
            make.left.equalTo(12)
        }

        // 初始化「开始场景视图」

        let sceneViewHeight: CGFloat = VC.height - 20
        let sceneViewWidth: CGFloat = sceneViewHeight * GVC.defaultSceneAspectRatio
        startSceneView = RoundedImageView(cornerRadius: 4)
        startSceneView.contentMode = .scaleAspectFill
        startSceneView.image = .sceneBackgroundThumb
        addSubview(startSceneView)
        startSceneView.snp.makeConstraints { make -> Void in
            make.width.equalTo(sceneViewWidth)
            make.height.equalTo(sceneViewHeight)
            make.centerY.equalToSuperview()
            make.left.equalTo(iconView.snp.right).offset(8)
        }

        // 初始化「开始场景索引标签」

        startSceneIndexLabel = UILabel()
        startSceneIndexLabel.font = .systemFont(ofSize: VC.sceneIndexLabelFontSize, weight: .regular)
        startSceneIndexLabel.textColor = .white
        startSceneIndexLabel.textAlignment = .center
        startSceneIndexLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        startSceneIndexLabel.layer.shadowOpacity = 1
        startSceneIndexLabel.layer.shadowRadius = 0
        startSceneIndexLabel.layer.shadowColor = UIColor.black.cgColor
        startSceneView.addSubview(startSceneIndexLabel)
        startSceneIndexLabel.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        // 初始化「箭头视图」

        arrowView = ArrowView()
        arrowView.arrowLayerColor = UIColor.accent?.cgColor
        addSubview(arrowView)
        let arrowViewHeight: CGFloat = VC.height - 16
        arrowView.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.arrowViewWidth)
            make.height.equalTo(arrowViewHeight)
            make.centerY.equalToSuperview()
            make.left.equalTo(startSceneView.snp.right).offset(4)
        }

        // 初始化「结束场景视图」

        endSceneView = RoundedImageView(cornerRadius: 4)
        endSceneView.backgroundColor = .systemFill
        addSubview(endSceneView)
        endSceneView.snp.makeConstraints { make -> Void in
            make.width.equalTo(sceneViewWidth)
            make.height.equalTo(sceneViewHeight)
            make.centerY.equalToSuperview()
            make.left.equalTo(arrowView.snp.right).offset(4)
        }

        // 初始化「结束场景索引标签」

        endSceneIndexLabel = UILabel()
        endSceneIndexLabel.text = "?"
        endSceneIndexLabel.font = .systemFont(ofSize: VC.sceneIndexLabelFontSize, weight: .regular)
        endSceneIndexLabel.textColor = .white
        endSceneIndexLabel.textAlignment = .center
        endSceneIndexLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        endSceneIndexLabel.layer.shadowOpacity = 1
        endSceneIndexLabel.layer.shadowRadius = 0
        endSceneIndexLabel.layer.shadowColor = UIColor.black.cgColor
        endSceneView.addSubview(endSceneIndexLabel)
        endSceneIndexLabel.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }
    }
}

extension AddTransitionDiagramView {

    /// 添加边框图层
    private func addBorderLayer() {

        if borderLayer != nil {
            borderLayer.removeFromSuperlayer()
            borderLayer = nil
        }

        borderLayer = CAShapeLayer()
        borderLayer.lineWidth = VC.borderLayerWidth
        borderLayer.strokeColor = UIColor.separator.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.frame = bounds
        borderLayer.path = maskLayer.path

        layer.addSublayer(borderLayer)
    }
}
