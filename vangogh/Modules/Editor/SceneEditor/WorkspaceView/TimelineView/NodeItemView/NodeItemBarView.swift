///
/// NodeItemBarView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class NodeItemBarView: UIView {

    /// 视图布局常量枚举值
    enum ViewLayoutConstants {
        static let height: CGFloat = 40
    }

    var leftEarView: NodeItemEarView!
    var rightEarView: NodeItemEarView!
    var backgroundView: NodeItemBackgroundView!
    var contentView: NodeItemContentView!

    var width: CGFloat {
        return contentView.width + GVC.timelineItemEarViewWidth * 2
    } // 视图宽度

    private var nodeType: MetaNodeType!

    init(nodeType: MetaNodeType) {

        super.init(frame: .zero)

        self.nodeType = nodeType

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {

        let nodeTypeBackgroundColor: UIColor? = MetaNodeTypeManager.shared.getNodeTypeBackgroundColor(nodeType: nodeType)

        // 初始化左执耳视图

        leftEarView = NodeItemEarView(direction: .left, tintColor: nodeTypeBackgroundColor)
        addSubview(leftEarView)
        leftEarView.snp.makeConstraints { make -> Void in
            make.width.equalTo(GVC.timelineItemEarViewWidth)
            make.height.equalTo(ViewLayoutConstants.height)
            make.left.top.equalToSuperview()
        }

        // 初始化右执耳视图

        rightEarView = NodeItemEarView(direction: .right, tintColor: nodeTypeBackgroundColor)
        addSubview(rightEarView)

        // 初始化背景视图

        backgroundView = NodeItemBackgroundView()
        addSubview(backgroundView)
    }
}

extension NodeItemBarView {

    func updateContentView(_ contentView: NodeItemContentView) {

        // 移除先前的内容视图

        if let previousContentView = self.contentView {
            previousContentView.removeFromSuperview()
        }

        // 更新内容视图

        self.contentView = contentView
        addSubview(contentView)
        contentView.snp.makeConstraints { make -> Void in
            make.width.equalTo(contentView.width)
            make.height.equalTo(NodeItemContentView.ViewLayoutConstants.height)
            make.left.equalTo(leftEarView.snp.right)
            make.top.equalTo((ViewLayoutConstants.height - NodeItemContentView.ViewLayoutConstants.height) / 2)
        }

        rightEarView.snp.remakeConstraints { make -> Void in
            make.width.equalTo(GVC.timelineItemEarViewWidth)
            make.height.equalTo(leftEarView)
            make.left.equalTo(contentView.snp.right)
        }

        backgroundView.snp.remakeConstraints { make -> Void in
            make.width.equalTo(contentView.width)
            make.height.equalTo(leftEarView)
            make.left.equalTo(contentView.snp.left)
            make.top.equalToSuperview()
        }
        sendSubviewToBack(backgroundView)
    }
}
