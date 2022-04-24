///
/// MetaDuetView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Lottie
import SnapKit
import UIKit

class MetaDuetView: MetaNodeView {

    /// 视图布局常量枚举值
    enum VC {
        static let width: CGFloat = 240
        static let marginBottom: CGFloat = 24
        static let indicatorViewWidth: CGFloat = 120
        static let indicatorViewMarginBottom: CGFloat = 16
        static let indicatorButtonWidth: CGFloat = 72
        static let animatedIconViewEdgeInset: CGFloat = 16
        static let hintLabelMarginBottom: CGFloat = 16
        static let hintLabelFontSize: CGFloat = 18
    }

    private var hintLabel: BottomAlignedLabel!
    private var indicatorView: UIView!
    private var indicatorButton: UIButton!
    private var animatedIconView: AnimationView!
    private var progressView: UIView!

    private var pulseAnimationLayer: CALayer!
    private var pulseAnimationGroup: CAAnimationGroup!
    private var pulseAnimationDuration: TimeInterval = 1.2

    private(set) var duet: MetaDuet!
    override var node: MetaNode! {
        get {
            return duet
        }
    }

    init(duet: MetaDuet) {

        super.init()

        self.duet = duet

        // 初始化视图

        initViews()

        // 监听是否进入前台/后台运行

        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    deinit {

        NotificationCenter.default.removeObserver(self)
    }

    override func layoutSubviews() {

        startPulseAnimating()
    }

    private func initViews() {

        backgroundColor = UIColor.colorWithRGBA(rgba: duet.backgroundColorCode)

        indicatorView = UIView()
        addSubview(indicatorView)

        indicatorButton = UIButton()
        addSubview(indicatorButton)

        animatedIconView = AnimationView(name: "microphone")
        animatedIconView.loopMode = .loop
        animatedIconView.backgroundBehavior = .pauseAndRestore
        animatedIconView.play()
        indicatorButton.addSubview(animatedIconView)

        hintLabel = BottomAlignedLabel()
        hintLabel.text = duet.hint
        hintLabel.textColor = .white
        hintLabel.textAlignment = .center
        hintLabel.numberOfLines = 2
        hintLabel.lineBreakMode = .byTruncatingTail
        hintLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        hintLabel.layer.shadowOpacity = 1
        hintLabel.layer.shadowRadius = 1
        hintLabel.layer.shadowColor = UIColor.black.cgColor
        addSubview(hintLabel)

        progressView = UIView()
        addSubview(progressView)
    }

    override func layout(parent: UIView) {

        guard let playerView = playerView, let renderScale = playerView.renderScale else { return }

        // 更新提示器视图布局

        indicatorView.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.indicatorViewWidth * renderScale)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-VC.indicatorViewMarginBottom * renderScale)
        }

        // 更新提示器按钮布局

        indicatorButton.layer.cornerRadius = VC.indicatorButtonWidth * renderScale / 2
        indicatorButton.backgroundColor = .white
        let indicatorButtonMarginBottom: CGFloat = (VC.indicatorViewWidth - VC.indicatorButtonWidth) / 2 + VC.indicatorViewMarginBottom
        indicatorButton.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(VC.indicatorButtonWidth * renderScale)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-indicatorButtonMarginBottom * renderScale)
        }

        animatedIconView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview().inset(VC.animatedIconViewEdgeInset * renderScale)
        }

        // 更新提示标签布局

        hintLabel.font = .systemFont(ofSize: VC.hintLabelFontSize * renderScale, weight: .regular)
        hintLabel.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(indicatorView.snp.top).offset(-VC.hintLabelMarginBottom * renderScale)
        }

        // 更新进度视图布局

        progressView.backgroundColor = .accent
        progressView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(MetaNodeView.VC.progressViewHeight * renderScale)
            make.left.equalToSuperview()
            make.bottom.equalTo(hintLabel.snp.top).offset(-MetaNodeView.VC.progressViewMarginBottom * renderScale)
        }

        // 更新当前视图布局

        parent.addSubview(self)

        snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.width * renderScale)
            make.centerX.equalToSuperview()
            make.top.equalTo(progressView)
            make.bottom.equalToSuperview().offset(-VC.marginBottom * renderScale)
        }
    }
}

extension MetaDuetView {

    @objc private func willEnterForeground() {

        startPulseAnimating()
    }

    @objc private func didEnterBackground() {

        stopPulseAnimating()
    }

    func startPulseAnimating() {

        guard let playerView = playerView, let renderScale = playerView.renderScale else { return }

        pulseAnimationLayer = CALayer()
        let position = CGPoint(x: VC.indicatorViewWidth * renderScale / 2, y: VC.indicatorViewWidth * renderScale / 2)
        pulseAnimationLayer.position = position
        pulseAnimationLayer.bounds = CGRect(x: 0, y: 0, width: VC.indicatorViewWidth * renderScale, height: VC.indicatorViewWidth * renderScale)
        pulseAnimationLayer.backgroundColor = UIColor.accent?.withAlphaComponent(0.4).cgColor
        pulseAnimationLayer.opacity = 0
        pulseAnimationLayer.cornerRadius = VC.indicatorViewWidth * renderScale / 2

        pulseAnimationGroup = CAAnimationGroup()
        pulseAnimationGroup.duration = pulseAnimationDuration
        pulseAnimationGroup.repeatCount = .infinity
        pulseAnimationGroup.timingFunction = CAMediaTimingFunction(name: .default)
        pulseAnimationGroup.animations = [scaleAnimation(), opacityAnimation()]
        pulseAnimationLayer.add(pulseAnimationGroup, forKey: "pulse")

        indicatorView.layer.addSublayer(pulseAnimationLayer)
    }

    private func stopPulseAnimating() {

        if pulseAnimationLayer != nil {
            pulseAnimationLayer.removeFromSuperlayer()
            pulseAnimationLayer = nil
            pulseAnimationGroup = nil
        }
    }

    func scaleAnimation() -> CABasicAnimation {

        let scaleAnimaton: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimaton.duration = pulseAnimationDuration
        scaleAnimaton.fromValue = NSNumber(value: 0.75)
        scaleAnimaton.toValue = NSNumber(value: 1)

        return scaleAnimaton
    }

    func opacityAnimation() -> CAKeyframeAnimation {

        let opacityAnimiation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimiation.duration = pulseAnimationDuration
        opacityAnimiation.values = [0.4, 0.8, 0]
        opacityAnimiation.keyTimes = [0, 0.3, 1]

        return opacityAnimiation
    }
}
