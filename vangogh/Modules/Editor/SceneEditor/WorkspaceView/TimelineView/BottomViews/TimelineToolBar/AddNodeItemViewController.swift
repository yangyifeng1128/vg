///
/// AddNodeItemViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

protocol AddNodeItemViewControllerDelegate: AnyObject {
    func toolBarSubitemDidTap(_ toolBarSubitem: TimelineToolBarSubitem)
}

class AddNodeItemViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
        static let height: CGFloat = 132
        static let collectionViewHeight: CGFloat = 92
        static let collectionViewCellWidth: CGFloat = 96
    }

    weak var delegate: AddNodeItemViewControllerDelegate?

    private var collectionView: UICollectionView!

    private var toolBarItem: TimelineToolBarItem!
    private var toolBarSubitems: [TimelineToolBarSubitem]!

    init(toolBarItem: TimelineToolBarItem) {

        super.init(nibName: nil, bundle: nil)

        self.toolBarItem = toolBarItem
        toolBarSubitems = TimelineToolBarSubitemManager.shared.get(toolBarItemType: toolBarItem.type)
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    //
    //
    // MARK: - 视图生命周期
    //
    //

    override func viewDidLoad() {

        super.viewDidLoad()

        // 单独强制设置用户界面风格

        overrideUserInterfaceStyle = SceneEditorViewController.preferredUserInterfaceStyle

        // 初始化视图

        initViews()
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // 隐藏导航栏

        navigationController?.navigationBar.isHidden = true
    }

    //
    //
    // MARK: - 初始化子视图
    //
    //

    private func initViews() {

        view.backgroundColor = .bcGrey

        // 初始化集合视图

        initCollectionView()
    }

    private func initCollectionView() {

        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(AddNodeItemCollectionViewCell.self, forCellWithReuseIdentifier: AddNodeItemCollectionViewCell.reuseId)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(VC.collectionViewHeight)
            make.left.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

extension AddNodeItemViewController: UICollectionViewDataSource {

    /// 设置单元格数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return toolBarSubitems.count
    }

    /// 设置单元格
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddNodeItemCollectionViewCell.reuseId, for: indexPath) as? AddNodeItemCollectionViewCell else {
            fatalError("Unexpected cell type")
        }

        let toolBarSubitem = toolBarSubitems[indexPath.item]
        cell.titleLabel.text = toolBarSubitem.title
        cell.tagView.iconView.image = toolBarSubitem.icon
        cell.tagView.backgroundColor = toolBarSubitem.backgroundColor

        return cell
    }
}

extension AddNodeItemViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let toolBarSubitem = toolBarSubitems[indexPath.item]
        delegate?.toolBarSubitemDidTap(toolBarSubitem)
    }
}

extension AddNodeItemViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: VC.collectionViewCellWidth, height: VC.collectionViewHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return 0
    }
}
