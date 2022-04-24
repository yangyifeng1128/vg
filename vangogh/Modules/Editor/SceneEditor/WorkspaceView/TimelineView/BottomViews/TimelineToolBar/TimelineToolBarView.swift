///
/// TimelineToolBarView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

protocol TimelineToolBarViewDelegate: AnyObject {
    func toolBarItemDidTap(_ toolBarItem: TimelineToolBarItem)
}

class TimelineToolBarView: BorderedView {

    /// 视图布局常量枚举值
    enum VC {
        static let toolBarItemCellWidth: CGFloat = 64
    }

    weak var delegate: TimelineToolBarViewDelegate?

    override var isUserInteractionEnabled: Bool {
        willSet {
            if let cells = collectionView.visibleCells as? [TimelineToolBarItemCell] {
                cells.forEach {
                    $0.iconView.alpha = newValue ? 1 : 0.5
                    $0.titleLabel.alpha = newValue ? 1 : 0.5
                }
            }
        }
    }

    private var collectionView: UICollectionView!

    private var toolBarItems: [TimelineToolBarItem]!

    init() {

        super.init(side: .top)

        // 初始化工具项

        toolBarItems = TimelineToolBarItemManager.shared.get()

        // 初始化视图

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {

        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(TimelineToolBarItemCell.self, forCellWithReuseIdentifier: TimelineToolBarItemCell.reuseId)
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(TimelineView.VC.bottomViewContainerHeight)
            make.left.bottom.equalToSuperview()
        }
    }
}

extension TimelineToolBarView: UICollectionViewDataSource {

    /// 设置单元格数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return toolBarItems.count
    }

    /// 设置单元格
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimelineToolBarItemCell.reuseId, for: indexPath) as? TimelineToolBarItemCell else {
            fatalError("Unexpected cell type")
        }

        let toolBarItem = toolBarItems[indexPath.item]
        cell.iconView.image = toolBarItem.icon
        cell.iconView.tintColor = toolBarItem.iconTintColor
        cell.titleLabel.text = toolBarItem.title

        return cell
    }
}

extension TimelineToolBarView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let toolBarItem = toolBarItems[indexPath.item]
        delegate?.toolBarItemDidTap(toolBarItem)
    }
}

extension TimelineToolBarView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: VC.toolBarItemCellWidth, height: TimelineView.VC.bottomViewContainerHeight)
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
