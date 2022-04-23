///
/// NodeItemBottomBarView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

protocol NodeItemBottomBarViewDelegate: AnyObject {
    func nodeItemBottomBarItemDidTap(node: MetaNode, actionBarItem: NodeItemBottomBarItem)
    func goBackFromNodeItemBottomBar()
}

class NodeItemBottomBarView: BorderedView {

    /// 视图布局常量枚举值
    enum ViewLayoutConstants {
        static let actionBarItemCellWidth: CGFloat = 120
        static let actionBarItemCellHeight: CGFloat = 42
        static let titleLabelFontSize: CGFloat = 12
        static let goBackIconViewWidth: CGFloat = 20
    }

    weak var delegate: NodeItemBottomBarViewDelegate?

    private var collectionView: UICollectionView!
    private var titleLabel: AttributedLabel!
    private var goBackView: UIView!

    private var actionBarItems: [NodeItemBottomBarItem]!
    var node: MetaNode? {
        didSet {
            updateContentView()
        }
    }

    init() {

        super.init(side: .top)

        actionBarItems = NodeItemBottomBarItemManager.shared.get()

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {

        initCollectionView()
        initTitleLabel()
        initGoBackView()
    }

    private func initCollectionView() {

        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(NodeItemBottomBarItemCell.self, forCellWithReuseIdentifier: NodeItemBottomBarItemCell.reuseId)
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(ViewLayoutConstants.actionBarItemCellHeight)
            make.bottom.equalToSuperview()
        }
    }

    private func initTitleLabel() {

        titleLabel = AttributedLabel()
        titleLabel.insets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        titleLabel.text = NSLocalizedString("Node", comment: "") // 此处设置字符串是为了保持高度占位，避免切换视图时产生异常动画效果
        titleLabel.font = .systemFont(ofSize: ViewLayoutConstants.titleLabelFontSize, weight: .regular)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byTruncatingTail
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview().inset(12)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(6)
        }
    }

    private func initGoBackView() {

        goBackView = UIView()
        goBackView.backgroundColor = UIColor.systemGroupedBackground.withAlphaComponent(0.9)
        goBackView.isUserInteractionEnabled = true
        goBackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goBackViewDidTap)))
        addSubview(goBackView)
        goBackView.snp.makeConstraints { make -> Void in
            make.width.equalTo(ViewLayoutConstants.actionBarItemCellWidth)
            make.height.equalTo(collectionView)
            make.left.equalToSuperview()
            make.bottom.equalTo(collectionView)
        }

        let goBackIconView: UIImageView = UIImageView()
        goBackIconView.image = .goBack
        goBackIconView.tintColor = .secondaryLabel
        goBackView.addSubview(goBackIconView)
        goBackIconView.snp.makeConstraints { make -> Void in
            make.width.height.equalTo(ViewLayoutConstants.goBackIconViewWidth)
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }

        let goBackTitleLabel: UILabel = UILabel()
        goBackTitleLabel.text = NSLocalizedString("Return", comment: "")
        goBackTitleLabel.font = .systemFont(ofSize: NodeItemBottomBarItemCell.ViewLayoutConstants.titleLabelFontSize, weight: .regular)
        goBackTitleLabel.textColor = .secondaryLabel
        goBackView.addSubview(goBackTitleLabel)
        goBackTitleLabel.snp.makeConstraints { make -> Void in
            make.left.equalTo(goBackIconView.snp.right).offset(4)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

extension NodeItemBottomBarView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return actionBarItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NodeItemBottomBarItemCell.reuseId, for: indexPath) as? NodeItemBottomBarItemCell else {
            fatalError("Unexpected cell type")
        }

        let actionBarItem = actionBarItems[indexPath.item]
        if actionBarItem.type == .edit {
            cell.infoView.backgroundColor = .secondarySystemBackground
        }
        cell.iconView.image = actionBarItem.icon
        cell.iconView.tintColor = actionBarItem.tintColor
        cell.titleLabel.text = actionBarItem.title
        cell.titleLabel.textColor = actionBarItem.tintColor

        return cell
    }
}

extension NodeItemBottomBarView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let node = node else { return }
        let actionBarItem = actionBarItems[indexPath.item]
        delegate?.nodeItemBottomBarItemDidTap(node: node, actionBarItem: actionBarItem)
    }
}

extension NodeItemBottomBarView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: ViewLayoutConstants.actionBarItemCellWidth, height: ViewLayoutConstants.actionBarItemCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let contentOffsetX: CGFloat = (UIScreen.main.bounds.width - ViewLayoutConstants.actionBarItemCellWidth) / 2
        return UIEdgeInsets(top: 0, left: contentOffsetX, bottom: 0, right: contentOffsetX)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return 0
    }
}

extension NodeItemBottomBarView {

    @objc private func goBackViewDidTap() {

        delegate?.goBackFromNodeItemBottomBar()
    }

    private func updateContentView() {

        guard let node = node, let nodeTypeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: node.nodeType) else { return }
        titleLabel.text = nodeTypeTitle + " " + node.index.description
        titleLabel.textColor = MetaNodeTypeManager.shared.getNodeTypeTextColor(nodeType: node.nodeType)
    }
}
