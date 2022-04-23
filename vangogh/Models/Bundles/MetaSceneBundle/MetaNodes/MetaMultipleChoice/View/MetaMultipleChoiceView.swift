///
/// MetaMultipleChoiceView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class MetaMultipleChoiceView: MetaNodeView {

    /// 视图布局常量枚举值
    enum ViewLayoutConstants {
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

    init(multipleChoice: MetaMultipleChoice) {

        super.init()

        self.multipleChoice = multipleChoice

        // 初始化子视图

        initSubviews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {

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
        questionLabel.textColor = .white
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

    override func layout(parent: UIView) {

        guard let playerView = playerView, let renderScale = playerView.renderScale else { return }

        let optionsTableViewHeight: CGFloat = ViewLayoutConstants.optionTableViewCellHeight * CGFloat(multipleChoice.options.count)
        optionsTableView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview().inset(ViewLayoutConstants.optionsTableViewMargin * renderScale)
            make.height.equalTo(optionsTableViewHeight * renderScale)
            make.left.equalToSuperview().offset(ViewLayoutConstants.optionsTableViewMargin * renderScale)
            make.bottom.equalToSuperview().offset(-ViewLayoutConstants.optionsTableViewMargin * renderScale)
        }

        questionLabel.font = .systemFont(ofSize: ViewLayoutConstants.questionLabelFontSize * renderScale, weight: .regular)
        questionLabel.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview().inset(ViewLayoutConstants.paddingX * renderScale)
            make.left.equalToSuperview().offset(ViewLayoutConstants.paddingX * renderScale)
            make.bottom.equalTo(optionsTableView.snp.top).offset(-ViewLayoutConstants.questionLabelMarginBottom * renderScale)
        }

        progressView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(MetaNodeView.ViewLayoutConstants.progressViewHeight * renderScale)
            make.left.equalToSuperview()
            make.bottom.equalTo(questionLabel.snp.top).offset(-MetaNodeView.ViewLayoutConstants.progressViewMarginBottom * renderScale)
        }

        // 更新当前视图布局

        parent.addSubview(self)

        snp.makeConstraints { make -> Void in
            make.width.equalTo(ViewLayoutConstants.width * renderScale)
            make.right.equalToSuperview().offset(-ViewLayoutConstants.marginRight * renderScale)
            make.top.equalTo(progressView)
            make.bottom.equalToSuperview().offset(-ViewLayoutConstants.marginBottom * renderScale)
        }
    }
}

extension MetaMultipleChoiceView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return multipleChoice.options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = optionsTableView.dequeueReusableCell(withIdentifier: MetaMultipleChoiceOptionTableViewCell.reuseId) as? MetaMultipleChoiceOptionTableViewCell, let playerView = playerView, let renderScale = playerView.renderScale else {
            fatalError("Unexpected cell")
        }

        // 准备选项视图

        cell.optionView.cornerRadius = MetaMultipleChoiceOptionTableViewCell.ViewLayoutConstants.optionViewCornerRadius * renderScale
        cell.optionView.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview()
            make.height.equalToSuperview().inset(4 * renderScale)
            make.center.equalToSuperview()
        }

        // 准备标题标签

        cell.titleLabel.text = multipleChoice.options[indexPath.row]
        cell.titleLabel.font = .systemFont(ofSize: MetaMultipleChoiceOptionTableViewCell.ViewLayoutConstants.titleLabelFontSize * renderScale, weight: .regular)
        cell.titleLabel.snp.makeConstraints { make -> Void in
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview().inset(24 * renderScale)
        }

        return cell
    }
}

extension MetaMultipleChoiceView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        guard let playerView = playerView, let renderScale = playerView.renderScale else {
            fatalError("Unexpected row height")
        }

        return ViewLayoutConstants.optionTableViewCellHeight * renderScale
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        print("[MetaMultipleChoice] did select \"\(multipleChoice.options[indexPath.row])\"")

        guard let cell = tableView.cellForRow(at: indexPath) as? MetaMultipleChoiceOptionTableViewCell else { return }
        cell.optionView.backgroundColor = .accent
        cell.titleLabel.textColor = .white
        // cell.optionView.borderLayer.strokeColor = UIColor.accent?.cgColor
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        guard let cell = tableView.cellForRow(at: indexPath) as? MetaMultipleChoiceOptionTableViewCell else { return }
        cell.optionView.backgroundColor = MetaMultipleChoiceOptionTableViewCell.ViewLayoutConstants.optionViewBackgroundColor
        cell.titleLabel.textColor = MetaMultipleChoiceOptionTableViewCell.ViewLayoutConstants.titleLabelTextColor
        // cell.optionView.borderLayer.strokeColor = MetaMultipleChoiceOptionTableViewCell.ViewLayoutConstants.optionViewBorderLayerStrokeColor.cgColor
    }
}
