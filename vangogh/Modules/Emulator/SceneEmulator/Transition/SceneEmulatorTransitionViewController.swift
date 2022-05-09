///
/// SceneEmulatorTransitionViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Hero
import UIKit

class SceneEmulatorTransitionViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let oopsLabelFontSize: CGFloat = 64
        static let titleLabelFontSize: CGFloat = 20
        static let nextScenesTitleLabelFontSize: CGFloat = 16
        static let nextSceneIndicatorCollectionViewCellSpacing: CGFloat = 8
    }

    /// 后续场景提示器集合视图
    var nextSceneIndicatorsCollectionView: UICollectionView!

    /// 场景资源包
    var sceneBundle: MetaSceneBundle!
    /// 作品资源包
    var gameBundle: MetaGameBundle!
    /// 后续场景提示器列表
    var nextSceneIndicators: [NextSceneIndicator] = [NextSceneIndicator]()

    /// 初始化
    init(sceneBundle: MetaSceneBundle, gameBundle: MetaGameBundle) {

        super.init(nibName: nil, bundle: nil)

        self.sceneBundle = sceneBundle
        self.gameBundle = gameBundle
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 视图加载完成
    override func viewDidLoad() {

        super.viewDidLoad()

        initViews()
    }

    /// 视图即将显示
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // 隐藏导航栏

        navigationController?.navigationBar.isHidden = true

        // 加载后续场景提示器列表

        loadNextSceneIndicators() { [weak self] in
            guard let s = self else { return }
            s.nextSceneIndicatorsCollectionView.reloadData()
        }
    }

    /// 初始化视图
    private func initViews() {

        // 启用 hero 转场动画

        hero.isEnabled = true

        // 初始化「oops 标签」

        let oopsLabel: UILabel = UILabel()
        oopsLabel.text = "\\(^o^)/"
        oopsLabel.font = .systemFont(ofSize: VC.oopsLabelFontSize, weight: .regular)
        oopsLabel.textColor = .secondaryLabel
        view.addSubview(oopsLabel)
        oopsLabel.snp.makeConstraints { make -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(120)
        }

        // 初始化「标题标签」

        let titleLabel: UILabel = UILabel()
        titleLabel.text = String.localizedStringWithFormat(NSLocalizedString("UpNextIn", comment: ""), 8)
        titleLabel.font = .systemFont(ofSize: VC.titleLabelFontSize, weight: .regular)
        titleLabel.textColor = .mgLabel
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(oopsLabel.snp.bottom).offset(48)
        }

        // 初始化「后续场景提示器集合视图」

        nextSceneIndicatorsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        nextSceneIndicatorsCollectionView.backgroundColor = .clear
        nextSceneIndicatorsCollectionView.showsVerticalScrollIndicator = false
        nextSceneIndicatorsCollectionView.register(NextSceneIndicatorCollectionViewCell.self, forCellWithReuseIdentifier: NextSceneIndicatorCollectionViewCell.reuseId)
        nextSceneIndicatorsCollectionView.dataSource = self
        nextSceneIndicatorsCollectionView.delegate = self
        view.addSubview(nextSceneIndicatorsCollectionView)
        nextSceneIndicatorsCollectionView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(48)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
}

extension SceneEmulatorTransitionViewController: UICollectionViewDataSource {

    /// 设置单元格数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return prepareNextSceneIndicatorsCount()
    }

    /// 设置单元格
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        return prepareNextSceneIndicatorCollectionViewCell(indexPath: indexPath)
    }
}

extension SceneEmulatorTransitionViewController: UICollectionViewDelegate {

    /// 选中单元格
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        selectNextSceneIndicatorCollectionViewCell(indexPath: indexPath)
    }
}

extension SceneEmulatorTransitionViewController: UICollectionViewDelegateFlowLayout {

    /// 设置单元格尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return prepareNextSceneIndicatorCollectionViewCellSize(indexPath: indexPath)
    }

    /// 设置内边距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let inset = VC.nextSceneIndicatorCollectionViewCellSpacing
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }

    /// 设置最小行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return VC.nextSceneIndicatorCollectionViewCellSpacing
    }

    /// 设置最小单元格间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return VC.nextSceneIndicatorCollectionViewCellSpacing
    }
}
