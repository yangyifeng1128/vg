///
/// TransitionEditorConditionTableViewCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class TransitionEditorConditionTableViewCell: UITableViewCell {

    static let reuseId: String = "TransitionEditorConditionTableViewCell"

    // 视图布局常量枚举值

    enum ViewLayoutConstants {
        static let bodyViewHeight: CGFloat = 64
        static let editButtonWidth: CGFloat = 36
        static let titleLabelFontSize: CGFloat = 16
        static let deleteButtonWidth: CGFloat = 48
        static let orLabelFontSize: CGFloat = 14
    }

    var bodyView: UIView! // 主体视图
    var editButton: UIButton! // 编辑按钮
    var titleLabel: UILabel! // 标题标签
    var deleteButton: UIButton! // 删除按钮
    var orLabel: UILabel! // OR 标签

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {

        backgroundColor = .clear
        selectionStyle = .none

        // 添加删除按钮

        deleteButton = UIButton()
        deleteButton.tintColor = .secondaryLabel
        deleteButton.setImage(.delete, for: .normal)
        deleteButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        deleteButton.imageView?.contentMode = .scaleAspectFit
        deleteButton.imageView?.tintColor = .secondaryLabel
        contentView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make -> Void in
            make.width.equalTo(ViewLayoutConstants.deleteButtonWidth)
            make.height.equalTo(ViewLayoutConstants.bodyViewHeight)
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }

        // 添加主体视图

        bodyView = RoundedView()
        bodyView.backgroundColor = .tertiarySystemGroupedBackground
        contentView.addSubview(bodyView)
        bodyView.snp.makeConstraints { make -> Void in
            make.height.equalTo(ViewLayoutConstants.bodyViewHeight)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(deleteButton.snp.left)
            make.top.equalToSuperview()
        }

        editButton = UIButton()
        editButton.tintColor = .secondaryLabel
        editButton.setImage(.editNote, for: .normal)
        editButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 6)
        editButton.imageView?.contentMode = .scaleAspectFit
        editButton.imageView?.tintColor = .secondaryLabel
        bodyView.addSubview(editButton)
        editButton.snp.makeConstraints { make -> Void in
            make.width.equalTo(ViewLayoutConstants.editButtonWidth)
            make.height.equalToSuperview()
            make.left.equalToSuperview().offset(2)
            make.top.equalToSuperview()
        }

        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: ViewLayoutConstants.titleLabelFontSize, weight: .regular)
        titleLabel.textColor = .mgLabel
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        bodyView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.height.equalToSuperview()
            make.left.equalTo(editButton.snp.right)
            make.right.equalToSuperview().offset(-12)
        }

        // 添加 OR 标签

        orLabel = UILabel()
        orLabel.text = NSLocalizedString("Or", comment: "")
        orLabel.font = .systemFont(ofSize: ViewLayoutConstants.orLabelFontSize, weight: .regular)
        orLabel.textColor = .secondaryLabel
        orLabel.textAlignment = .center
        contentView.addSubview(orLabel)
        orLabel.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalTo(bodyView)
            make.top.equalTo(bodyView.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }

    override func prepareForReuse() {

        super.prepareForReuse()
    }
}
