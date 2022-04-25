///
/// SceneEmulatorProgressView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import AVFoundation
import UIKit

protocol SceneEmulatorProgressViewDelegate: AnyObject {
    func progressViewDidBeginSliding()
    func progressViewDidEndSliding(to value: Double)
}

class SceneEmulatorProgressView: UIView {

    /// 视图布局常量枚举值
    enum VC {
        static let height: CGFloat = 48
        static let barHeight: CGFloat = 32
        static let visibleBarHeight: CGFloat = 4
        static let sliderThumbImageHeight: CGFloat = 12
    }

    weak var delegate: SceneEmulatorProgressViewDelegate?

    private var barView: SceneEmulatorProgressBarView!
    private var slider: UISlider!
    private var tagViewContainer: UIView!
    private var tagViewList: [SceneEmulatorProgressTagView] = []

    var isEnabled: Bool {
        get {
            return slider.isEnabled
        }
        set {
            slider.isEnabled = newValue
        }
    }

    var value: CGFloat = 0 {
        didSet {
            slider.setValue(Float(value), animated: false)
        }
    }
    static let minimumValue: CGFloat = 0
    static let maximumValue: CGFloat = 100

    private var playerItemDurationMilliseconds: Int64!

    init() {

        super.init(frame: .zero)

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {

        initBarView()
        initSlider()
        initTagViews()
    }

    private func initBarView() {

        barView = SceneEmulatorProgressBarView()
        addSubview(barView)
        barView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(VC.barHeight)
            make.left.top.equalToSuperview()
        }
    }

    private func initSlider() {

        slider = UISlider()
        slider.isContinuous = true
        slider.minimumTrackTintColor = .clear
        slider.maximumTrackTintColor = .clear
        slider.minimumValue = Float(SceneEmulatorProgressView.minimumValue)
        slider.maximumValue = Float(SceneEmulatorProgressView.maximumValue)
        slider.setThumbImage(UIImage.circle(diameter: VC.sliderThumbImageHeight, color: .accent!), for: .normal)
        slider.addTarget(self, action: #selector(slide), for: .valueChanged)
        addSubview(slider)
        slider.snp.makeConstraints { make -> Void in
            make.height.equalTo(barView)
            make.left.equalTo(barView).offset(-VC.sliderThumbImageHeight / 2 + 2)
            make.right.equalTo(barView).offset(VC.sliderThumbImageHeight / 2 - 2)
            make.top.equalTo(barView).offset(-1)
        }
    }

    private func initTagViews() {

        tagViewContainer = UIView()
        insertSubview(tagViewContainer, at: 0)
        tagViewContainer.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(SceneEmulatorProgressTagView.VC.height)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

extension SceneEmulatorProgressView {

    func updateNodeItemViews(nodes: [MetaNode], playerItemDurationMilliseconds: Int64) {

        self.playerItemDurationMilliseconds = playerItemDurationMilliseconds

        // 移除先前的全部组件项标签视图

        for tagView in tagViewList {
            tagView.removeFromSuperview()
        }
        tagViewList.removeAll()

        // 添加新的标签视图

        nodes.forEach {
            let contentOffsetX: CGFloat = tagViewContainer.bounds.width * CGFloat($0.startTimeMilliseconds) / CGFloat(playerItemDurationMilliseconds)
            addTagView(node: $0, contentOffsetX: contentOffsetX)
        }
    }

    func addTagView(node: MetaNode, contentOffsetX: CGFloat) {

        // 添加新的组件项标签视图

        let tagView = SceneEmulatorProgressTagView(node: node)
        tagViewContainer.addSubview(tagView)
        tagViewList.append(tagView)
        tagView.snp.makeConstraints { make -> Void in
            make.width.equalTo(SceneEmulatorProgressTagView.VC.width)
            make.height.equalTo(SceneEmulatorProgressTagView.VC.height)
            make.left.equalToSuperview().offset(contentOffsetX - SceneEmulatorProgressTagView.VC.width / 2)
            make.top.equalToSuperview()
        }
    }
}

extension SceneEmulatorProgressView {

    @objc private func slide(_ sender: Any, event: UIEvent) {

        guard let touchEvent = event.allTouches?.first else { return }

        if touchEvent.phase == .began {
            delegate?.progressViewDidBeginSliding()
        } else if touchEvent.phase == .ended {
            delegate?.progressViewDidEndSliding(to: Double(slider.value))
        }
    }
}
