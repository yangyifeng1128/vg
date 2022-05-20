///
/// NextSceneDescriptorCollectionViewCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class NextSceneDescriptorCollectionViewCell: RoundedCollectionViewCell {

    static let reuseId: String = "NextSceneDescriptorCollectionViewCell"

    /// 视图布局常量枚举值
    enum VC {
        static let infoLabelFontSize: CGFloat = 16
        static let infoLabelIconWidth: CGFloat = 20
        static let hintLabelFontSize: CGFloat = 20
    }

    /// 缩略图视图
    var thumbImageView: UIImageView!
    /// 信息标签
    var infoLabel: BottomAlignedLabel!
    /// 提示标签
    var hintLabel: UILabel!

    /// 初始化
    override init(frame: CGRect) {

        super.init(frame: frame)

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        contentView.backgroundColor = GVC.defaultViewBackgroundColor

        // 初始化「缩略图视图」

        thumbImageView = UIImageView(frame: contentView.bounds)
        thumbImageView.contentMode = .scaleAspectFill
        contentView.addSubview(thumbImageView)

        // 初始化「信息标签」

        infoLabel = BottomAlignedLabel()
        infoLabel.font = .systemFont(ofSize: VC.infoLabelFontSize, weight: .regular)
        infoLabel.textColor = .mgLabel
        infoLabel.numberOfLines = 3
        infoLabel.lineBreakMode = .byTruncatingTail
        infoLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        infoLabel.layer.shadowOpacity = 1
        infoLabel.layer.shadowRadius = 1
        infoLabel.layer.shadowColor = UIColor.black.cgColor
        contentView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make -> Void in
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().offset(-12)
        }

        // 初始化「提示标签」

        hintLabel = UILabel()
        hintLabel.font = .systemFont(ofSize: VC.hintLabelFontSize, weight: .regular)
        hintLabel.textColor = .mgLabel
        hintLabel.textAlignment = .center
        hintLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        hintLabel.layer.shadowOpacity = 1
        hintLabel.layer.shadowRadius = 1
        hintLabel.layer.shadowColor = UIColor.black.cgColor
        contentView.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make -> Void in
            make.width.height.equalToSuperview()
            make.center.equalToSuperview()
        }
    }

    /// 准备重用单元格
    override func prepareForReuse() {

        super.prepareForReuse()

        thumbImageView.image = nil
    }
}

extension NextSceneDescriptorCollectionViewCell {

    /// 准备「信息标签」文本
    func prepareInfoLabelAttributedText(_ text: String?, icon: UIImage?) {

        let completeInfoTextString: NSMutableAttributedString = NSMutableAttributedString(string: "")

        // 准备图标

        if let icon = icon {
            let iconAttachment: NSTextAttachment = NSTextAttachment()
            iconAttachment.image = icon.withTintColor(.secondaryLabel)
            let infoLabelFont: UIFont = UIFont.systemFont(ofSize: VC.infoLabelFontSize, weight: .regular)
            let iconAttachmentY: CGFloat = (infoLabelFont.capHeight - VC.infoLabelIconWidth) / 2
            iconAttachment.bounds = CGRect(x: 0, y: iconAttachmentY, width: VC.infoLabelIconWidth, height: VC.infoLabelIconWidth)
            let iconString: NSAttributedString = NSAttributedString(attachment: iconAttachment)
            completeInfoTextString.append(iconString)
        }

        // 准备标题

        if let text = text {
            let titleString: NSAttributedString = NSAttributedString(string: " " + text)
            completeInfoTextString.append(titleString)
        }

        infoLabel.attributedText = completeInfoTextString
    }
}
