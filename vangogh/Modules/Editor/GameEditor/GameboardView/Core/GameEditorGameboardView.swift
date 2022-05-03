///
/// GameEditorGameboardView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class GameEditorGameboardView: UIScrollView {

    /// 视图布局常量枚举值
    enum VC {
        static let contentViewWidth: CGFloat = 1560 /* 960 */
        static let contentViewHeight: CGFloat = 2080 /* 1280 */
        static let gridWidth: CGFloat = 8
    }

    /// 数据源
    weak var gameDataSource: GameEditorGameboardViewDataSource? {
        didSet { reloadData() }
    }
    /// 代理
    weak var gameDelegate: GameEditorGameboardViewDelegate? {
        get { return delegate as? GameEditorGameboardViewDelegate }
        set { delegate = newValue }
    }

    /// 内容视图
    var contentView: UIView!

    /// 场景视图列表
    var sceneViewList: [GameEditorSceneView] = [GameEditorSceneView]()
    /// 穿梭器视图列表
    var transitionViewList: [GameEditorTransitionView] = [GameEditorTransitionView]()

    /// 初始化
    init() {

        super.init(frame: .zero)

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 重写用户界面风格变化处理方法
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)

        updateViewsWhenTraitCollectionChanged()
    }

    /// 初始化视图
    private func initViews() {

        initContentView()
    }
}

extension GameEditorGameboardView {

    /// 初始化「内容视图」
    private func initContentView() {

        scrollsToTop = false // 禁止点击状态栏滚动至视图顶部
        backgroundColor = .secondarySystemBackground
        contentInsetAdjustmentBehavior = .never
        showsVerticalScrollIndicator = true
        showsHorizontalScrollIndicator = true
        contentSize = CGSize(width: VC.contentViewWidth, height: VC.contentViewHeight)
        maximumZoomScale = 1
        minimumZoomScale = 0.98

        contentView = UIView()
        contentView.isUserInteractionEnabled = true
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentViewDidTap)))
        contentView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(contentViewDidLongPress)))
        addSubview(contentView)
        contentView.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.contentViewWidth)
            make.height.equalTo(VC.contentViewHeight)
            make.left.top.equalToSuperview()
        }
    }

    /// 初始化全部「场景视图」与「穿梭器视图」
    private func initAllSceneAndTransitionViews() {

        guard let dataSource = gameDataSource else { return }

        for index in 0..<dataSource.numberOfSceneViews() {
            let sceneView: GameEditorSceneView = dataSource.sceneViewAt(index)
            contentView.insertSubview(sceneView, at: 0)
            sceneViewList.append(sceneView)
        }

        for index in 0..<dataSource.numberOfTransitionViews() {
            let transitionView = dataSource.transitionViewAt(index)
            contentView.insertSubview(transitionView, at: 0)
            transitionViewList.append(transitionView)
        }
    }
}

extension GameEditorGameboardView {

    /// 重新加载数据
    func reloadData() {

        sceneViewList.forEach { $0.removeFromSuperview() }
        sceneViewList.removeAll()

        transitionViewList.forEach { $0.removeFromSuperview() }
        transitionViewList.removeAll()

        initAllSceneAndTransitionViews()
    }
}
