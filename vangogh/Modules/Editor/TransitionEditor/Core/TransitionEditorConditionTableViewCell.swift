///
/// TransitionEditorConditionTableViewCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class TransitionEditorConditionTableViewCell: UITableViewCell {

    static let reuseId: String = "TransitionEditorConditionTableViewCell"

    /// 视图布局常量枚举值
    enum VC {
        static let contentViewHeight: CGFloat = 64
        static let editButtonWidth: CGFloat = 36
        static let titleLabelFontSize: CGFloat = 16
        static let deleteButtonWidth: CGFloat = 48
        static let orLabelFontSize: CGFloat = 14
    }

    /// 标题标签
    var titleLabel: UILabel!
    /// 删除按钮
    var deleteButton: UIButton!
    /// or 标签
    var orLabel: UILabel!

    /// 初始化
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = .clear
        selectionStyle = .none

        // 初始化「删除按钮」

        deleteButton = UIButton()
        deleteButton.tintColor = .secondaryLabel
        deleteButton.setImage(.delete, for: .normal)
        deleteButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        deleteButton.imageView?.contentMode = .scaleAspectFit
        deleteButton.imageView?.tintColor = .secondaryLabel
        contentView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.deleteButtonWidth)
            make.height.equalTo(VC.contentViewHeight)
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }

        // 初始化「内容视图」

        let contentView: RoundedView = RoundedView()
        contentView.backgroundColor = .tertiarySystemGroupedBackground
        contentView.addSubview(contentView)
        contentView.snp.makeConstraints { make -> Void in
            make.height.equalTo(VC.contentViewHeight)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(deleteButton.snp.left)
            make.top.equalToSuperview()
        }

        // 初始化「编辑按钮」

        let editButton: UIButton = UIButton()
        editButton.tintColor = .secondaryLabel
        editButton.setImage(.editNote, for: .normal)
        editButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 6)
        editButton.imageView?.contentMode = .scaleAspectFit
        editButton.imageView?.tintColor = .secondaryLabel
        contentView.addSubview(editButton)
        editButton.snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.editButtonWidth)
            make.height.equalToSuperview()
            make.left.equalToSuperview().offset(2)
            make.top.equalToSuperview()
        }

        // 初始化「标题标签」

        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: VC.titleLabelFontSize, weight: .regular)
        titleLabel.textColor = .mgLabel
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make -> Void in
            make.height.equalToSuperview()
            make.left.equalTo(editButton.snp.right)
            make.right.equalToSuperview().offset(-12)
        }

        // 初始化「or 标签」

        orLabel = UILabel()
        orLabel.text = NSLocalizedString("Or", comment: "")
        orLabel.font = .systemFont(ofSize: VC.orLabelFontSize, weight: .regular)
        orLabel.textColor = .secondaryLabel
        orLabel.textAlignment = .center
        contentView.addSubview(orLabel)
        orLabel.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.left.equalTo(contentView)
            make.top.equalTo(contentView.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }

    /// 准备重用单元格
    override func prepareForReuse() {

        super.prepareForReuse()
    }
}
