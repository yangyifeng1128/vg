///
/// AddTransitionDiagramView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class AddTransitionDiagramView: RoundedView {

    /// 视图布局常量枚举值
    enum ViewLayoutConstants {
        static let width: CGFloat = 128
        static let height: CGFloat = 48
        static let borderLayerWidth: CGFloat = 1
        static let iconViewWidth: CGFloat = 24
        static let sceneIndexLabelFontSize: CGFloat = 14
        static let arrowViewWidth: CGFloat = 16
    }

    private var borderLayer: CAShapeLayer!
    private var arrowView: ArrowView!

    var startSceneView: RoundedImageView!
    var startSceneIndexLabel: UILabel!
    var endSceneView: RoundedImageView!
    var endSceneIndexLabel: UILabel!

    init() {

        super.init(cornerRadius: ViewLayoutConstants.height / 2)

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {

        addBorderLayer()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)

        addBorderLayer()

        arrowView.arrowLayerColor = UIColor.accent?.cgColor
        arrowView.updateView()
    }

    private func initSubviews() {

        backgroundColor = .systemBackground

        let iconView: UIImageView = UIImageView()
        iconView.image = .addLink
        iconView.tintColor = .accent
        addSubview(iconView)
        iconView.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(ViewLayoutConstants.iconViewWidth)
            make.centerY.equalToSuperview()
            make.left.equalTo(12)
        }

        let sceneViewHeight: CGFloat = ViewLayoutConstants.height - 20
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
        startSceneIndexLabel = UILabel()
        startSceneIndexLabel.font = .systemFont(ofSize: ViewLayoutConstants.sceneIndexLabelFontSize, weight: .regular)
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

        arrowView = ArrowView()
        arrowView.arrowLayerColor = UIColor.accent?.cgColor
        addSubview(arrowView)
        let arrowViewHeight: CGFloat = ViewLayoutConstants.height - 16
        arrowView.snp.makeConstraints { make -> Void in
            make.width.equalTo(ViewLayoutConstants.arrowViewWidth)
            make.height.equalTo(arrowViewHeight)
            make.centerY.equalToSuperview()
            make.left.equalTo(startSceneView.snp.right).offset(4)
        }

        endSceneView = RoundedImageView(cornerRadius: 4)
        endSceneView.backgroundColor = .systemFill
        addSubview(endSceneView)
        endSceneView.snp.makeConstraints { make -> Void in
            make.width.equalTo(sceneViewWidth)
            make.height.equalTo(sceneViewHeight)
            make.centerY.equalToSuperview()
            make.left.equalTo(arrowView.snp.right).offset(4)
        }
        endSceneIndexLabel = UILabel()
        endSceneIndexLabel.text = "?"
        endSceneIndexLabel.font = .systemFont(ofSize: ViewLayoutConstants.sceneIndexLabelFontSize, weight: .regular)
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

    private func addBorderLayer() {

        if borderLayer != nil {
            borderLayer.removeFromSuperlayer()
            borderLayer = nil
        }

        borderLayer = CAShapeLayer()
        borderLayer.lineWidth = ViewLayoutConstants.borderLayerWidth
        borderLayer.strokeColor = UIColor.separator.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.frame = bounds
        borderLayer.path = maskLayer.path

        layer.addSublayer(borderLayer)
    }
}
