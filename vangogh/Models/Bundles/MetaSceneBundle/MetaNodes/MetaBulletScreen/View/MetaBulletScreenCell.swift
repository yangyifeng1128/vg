///
/// MetaBulletScreenCell
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import DanmakuKit
import SnapKit
import UIKit

class MetaBulletScreenCell: DanmakuCell {

    /// 视图布局常量枚举值
    enum VC {
    }

    /// 初始化
    required init(frame: CGRect) {

        super.init(frame: frame)

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = .red
    }

    override func displaying(_ context: CGContext, _ size: CGSize, _ isCancelled: Bool) {

        guard let model = model as? MetaBulletScreenCellModel else { return }

        let text = NSString(string: model.info)

        context.setLineWidth(1)
        context.setLineJoin(.round)
        context.setStrokeColor(UIColor.mgHoneydew!.cgColor)
        context.saveGState()
        context.setTextDrawingMode(.stroke)
        let attrs: [NSAttributedString.Key: Any] = [.font: model.font, .foregroundColor: UIColor.mgHoneydew!]
        text.draw(at: .zero, withAttributes: attrs)

        context.restoreGState()
        context.setTextDrawingMode(.fill)
        text.draw(at: .zero, withAttributes: attrs)
    }
}
