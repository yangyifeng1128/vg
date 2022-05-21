///
/// MetaMultipleChoiceView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class MetaMultipleChoiceView: MetaNodeView {

    /// 视图布局常量枚举值
    enum VC {
        static let width: CGFloat = 256
        static let marginRight: CGFloat = 24
        static let marginBottom: CGFloat = 24
        static let paddingX: CGFloat = 8
        static let optionTableViewCellHeight: CGFloat = 64
        static let optionsTableViewMargin: CGFloat = 16
        static let questionLabelMarginBottom: CGFloat = 16
        static let questionLabelFontSize: CGFloat = 18
    }

    private var optionsTableView: UITableView!
    private var questionLabel: BottomAlignedLabel!
    private var progressView: UIView!

    private(set) var multipleChoice: MetaMultipleChoice!
    override var node: MetaNode! {
        get {
            return multipleChoice
        }
    }

    /// 初始化
    init(multipleChoice: MetaMultipleChoice) {

        super.init()

        self.multipleChoice = multipleChoice

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = UIColor.colorWithRGBA(rgba: multipleChoice.backgroundColorCode)

        optionsTableView = UITableView()
        optionsTableView.backgroundColor = .clear
        optionsTableView.separatorStyle = .none
        optionsTableView.showsVerticalScrollIndicator = false
        optionsTableView.alwaysBounceVertical = false
        optionsTableView.register(MetaMultipleChoiceOptionTableViewCell.self, forCellReuseIdentifier: MetaMultipleChoiceOptionTableViewCell.reuseId)
        optionsTableView.dataSource = self
        optionsTableView.delegate = self
        addSubview(optionsTableView)

        questionLabel = BottomAlignedLabel()
        questionLabel.text = multipleChoice.question
        questionLabel.textColor = .mgHoneydew
        questionLabel.numberOfLines = 4
        questionLabel.lineBreakMode = .byTruncatingTail
        questionLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        questionLabel.layer.shadowOpacity = 1
        questionLabel.layer.shadowRadius = 1
        questionLabel.layer.shadowColor = UIColor.black.cgColor
        addSubview(questionLabel)

        progressView = UIView()
        progressView.backgroundColor = .accent
        addSubview(progressView)
    }

    override func reloadData() {

        guard let dataSource = dataSource else { return }

        let renderScale: CGFloat = dataSource.renderScale()

        let optionsTableViewHeight: CGFloat = VC.optionTableViewCellHeight * CGFloat(multipleChoice.options.count)
        optionsTableView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview().inset(VC.optionsTableViewMargin * renderScale)
            make.height.equalTo(optionsTableViewHeight * renderScale)
            make.left.equalToSuperview().offset(VC.optionsTableViewMargin * renderScale)
            make.bottom.equalToSuperview().offset(-VC.optionsTableViewMargin * renderScale)
        }

        questionLabel.font = .systemFont(ofSize: VC.questionLabelFontSize * renderScale, weight: .regular)
        questionLabel.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview().inset(VC.paddingX * renderScale)
            make.left.equalToSuperview().offset(VC.paddingX * renderScale)
            make.bottom.equalTo(optionsTableView.snp.top).offset(-VC.questionLabelMarginBottom * renderScale)
        }

        progressView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(MetaNodeView.VC.progressViewHeight * renderScale)
            make.left.equalToSuperview()
            make.bottom.equalTo(questionLabel.snp.top).offset(-MetaNodeView.VC.progressViewMarginBottom * renderScale)
        }

        // 更新当前视图布局

        // parent.addSubview(self)

        snp.makeConstraints { make -> Void in
            make.width.equalTo(VC.width * renderScale)
            make.right.equalToSuperview().offset(-VC.marginRight * renderScale)
            make.top.equalTo(progressView)
            make.bottom.equalToSuperview().offset(-VC.marginBottom * renderScale)
        }
    }
}

extension MetaMultipleChoiceView: UITableViewDataSource {

    /// 设置单元格数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return multipleChoice.options.count
    }

    /// 设置单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = optionsTableView.dequeueReusableCell(withIdentifier: MetaMultipleChoiceOptionTableViewCell.reuseId) as? MetaMultipleChoiceOptionTableViewCell else {
            fatalError("Unexpected cell")
        }

        guard let dataSource = dataSource else { fatalError("Unexpected data source") }

        let renderScale: CGFloat = dataSource.renderScale()

        // 准备选项视图

        cell.optionView.cornerRadius = MetaMultipleChoiceOptionTableViewCell.VC.optionViewCornerRadius * renderScale
        cell.optionView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalToSuperview().inset(4 * renderScale)
            make.center.equalToSuperview()
        }

        // 准备标题标签

        cell.titleLabel.text = multipleChoice.options[indexPath.row]
        cell.titleLabel.font = .systemFont(ofSize: MetaMultipleChoiceOptionTableViewCell.VC.titleLabelFontSize * renderScale, weight: .regular)
        cell.titleLabel.snp.makeConstraints { make -> Void in
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview().inset(24 * renderScale)
        }

        return cell
    }
}

extension MetaMultipleChoiceView: UITableViewDelegate {

    /// 设置单元格高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        guard let dataSource = dataSource else {
            fatalError("Unexpected row height")
        }

        let renderScale: CGFloat = dataSource.renderScale()

        return VC.optionTableViewCellHeight * renderScale
    }

    /// 选中单元格
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        print("[MetaMultipleChoice] did select \"\(multipleChoice.options[indexPath.row])\"")

        guard let cell = tableView.cellForRow(at: indexPath) as? MetaMultipleChoiceOptionTableViewCell else { return }
        cell.optionView.backgroundColor = .accent
        cell.titleLabel.textColor = .mgHoneydew
        // cell.optionView.borderLayer.strokeColor = UIColor.accent?.cgColor
    }

    /// 取消选中单元格
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        guard let cell = tableView.cellForRow(at: indexPath) as? MetaMultipleChoiceOptionTableViewCell else { return }
        cell.optionView.backgroundColor = MetaMultipleChoiceOptionTableViewCell.VC.optionViewBackgroundColor
        cell.titleLabel.textColor = MetaMultipleChoiceOptionTableViewCell.VC.titleLabelTextColor
        // cell.optionView.borderLayer.strokeColor = MetaMultipleChoiceOptionTableViewCell.VC.optionViewBorderLayerStrokeColor.cgColor
    }
}
