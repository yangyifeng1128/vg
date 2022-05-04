///
/// TransparentCoachMarkBodyView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Instructions
import SnapKit
import UIKit

class TransparentCoachMarkBodyView: UIControl, CoachMarkBodyView {

    /// 视图常量枚举值
    enum VC {
        static let hintTextViewFontSize: CGFloat = 18
    }

    /// 高亮箭头代理
    weak var highlightArrowDelegate: CoachMarkBodyHighlightArrowDelegate?
    /// 下一个控制器
    var nextControl: UIControl? { return self }
    /// 提示文本视图
    var hintTextView: UITextView!

    /// 初始化
    override init (frame: CGRect) {
        super.init(frame: frame)

        self.initViews()
    }

    /// 初始化
    convenience init() {

        self.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding.")
    }

    /// 初始化视图
    private func initViews() {

        translatesAutoresizingMaskIntoConstraints = false

        // 初始化「提示文本视图」

        hintTextView = UITextView()
        hintTextView.backgroundColor = .clear
        hintTextView.textColor = .white
        hintTextView.font = .systemFont(ofSize: VC.hintTextViewFontSize, weight: .semibold)
        hintTextView.isEditable = false
        hintTextView.isSelectable = false
        hintTextView.isScrollEnabled = false
        hintTextView.isUserInteractionEnabled = false
        addSubview(hintTextView)
        hintTextView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }
    }
}
