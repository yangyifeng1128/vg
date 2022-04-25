///
/// MetaNodeEditorView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaNodeEditorView: UIView {

    /// 视图布局常量枚举值
    enum VC {
        static let tableViewHeaderHeight: CGFloat = 56
        static let sectionControlTitleTextFontSize: CGFloat = 13
        static let deleteButtonTitleLabelFontSize: CGFloat = 14
    }

    // 段键枚举值

    enum SectionKey: String, CaseIterable {
        case style = "SectionKey_Style"
        case interaction = "SectionKey_Interaction"
    }

    // 行键枚举值

    enum RowKey: String, CaseIterable {
        case background = "RowKey_Background"
        case corner = "RowKey_Corner"
        case locationAndSize = "RowKey_LocationAndSize"
        case options = "RowKey_Options"
        case padding = "RowKey_Padding"
        case question = "RowKey_Question"
        case rules = "RowKey_Rules"
        case title = "RowKey_Title"
        case typography = "RowKey_Typography"
    }

    weak var viewController: EditNodeItemViewController?

    var tableView: UITableView!
    private var sectionControl: UISegmentedControl!
    private var deleteButton: UIButton!

    private var sections: OrderedDictionary<SectionKey, String> = [:]
    var dictionary: OrderedDictionary<RowKey, Any> = [:]

    /// 初始化
    init() {

        super.init(frame: .zero)

        for sectionKey in SectionKey.allCases {
            sections[sectionKey] = NSLocalizedString(sectionKey.rawValue, comment: "")
        }

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        // 初始化表格视图

        tableView = UITableView()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceVertical = false
        tableView.register(MetaNodeEditorTableViewCell.self, forCellReuseIdentifier: MetaNodeEditorTableViewCell.reuseId)
        tableView.register(MetaNodeEditorTableTypographyViewCell.self, forCellReuseIdentifier: MetaNodeEditorTableTypographyViewCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        addSubview(tableView)
        tableView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        let swipeLeftGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(tableViewDidSwipeLeft))
        swipeLeftGesture.direction = .left
        tableView.addGestureRecognizer(swipeLeftGesture)

        let swipeRightGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(tableViewDidSwipeRight))
        swipeRightGesture.direction = .right
        tableView.addGestureRecognizer(swipeRightGesture)

        // 初始化菜单控制器

        sectionControl = UISegmentedControl(items: sections.map { $0.value })
        sectionControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: VC.sectionControlTitleTextFontSize, weight: .regular)], for: .normal)
        sectionControl.selectedSegmentIndex = 0
        sectionControl.addTarget(self, action: #selector(sectionControlDidChange), for: .valueChanged)
        addSubview(sectionControl)
        sectionControl.snp.makeConstraints { make -> Void in
            make.width.equalToSuperview().dividedBy(2)
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(GVC.bottomSheetViewPullBarHeight + 8)
        }

        // 初始化删除按钮

        deleteButton = UIButton()
        deleteButton.backgroundColor = .clear
        deleteButton.tintColor = .mgLabel
        deleteButton.contentHorizontalAlignment = .right
        deleteButton.contentVerticalAlignment = .center
        deleteButton.setTitle(NSLocalizedString("DeleteNode", comment: ""), for: .normal)
        deleteButton.setTitleColor(.mgLabel, for: .normal)
        deleteButton.titleLabel?.font = .systemFont(ofSize: VC.deleteButtonTitleLabelFontSize, weight: .regular)
        deleteButton.addTarget(self, action: #selector(deleteButtonDidTap), for: .touchUpInside)
        addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make -> Void in
            make.height.equalToSuperview()
            make.centerY.equalTo(sectionControl)
            make.right.equalToSuperview().offset(-20)
        }
    }

    override func layoutSubviews() {

        loadDictionary(index: sectionControl.selectedSegmentIndex)
    }

    private func loadDictionary(index: Int) {

        switch sections[index].key {
        case .style:
            populateStyles()
            break
        case .interaction:
            populateInteractions()
            break
        }

        tableView.reloadData()
        if dictionary.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }

    func populateStyles() {

        fatalError("Method \"styles\" must be overriden")
    }

    func populateInteractions() {

        fatalError("Method \"interactions\" must be overriden")
    }
}

extension MetaNodeEditorView: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    /// 设置单元格数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return dictionary.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView: UIView = UIView()

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return VC.tableViewHeaderHeight
    }

    /// 设置单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let rowKey: MetaNodeEditorView.RowKey = dictionary[indexPath.row].key
        let rowValue: Any = dictionary[indexPath.row].value

        guard let cell = tableView.dequeueReusableCell(withIdentifier: MetaNodeEditorTableViewCell.reuseId) as? MetaNodeEditorTableViewCell else {
            fatalError("Unexpected cell type")
        }

        cell.titleLabel.text = NSLocalizedString(rowKey.rawValue, comment: "")
        cell.infoLabel.text = rowValue as? String

        return cell
    }
}

extension MetaNodeEditorView: UITableViewDelegate {

    /// 设置单元格高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return MetaNodeEditorTableViewCell.VC.height
    }

    /// 选中单元格
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let rowKey: MetaNodeEditorView.RowKey = dictionary[indexPath.row].key
        let rowValue: Any = dictionary[indexPath.row].value

        print("\(rowKey): \(rowValue)")
    }
}

extension MetaNodeEditorView {

    @objc private func tableViewDidSwipeLeft() {

        var index = sectionControl.selectedSegmentIndex - 1
        if index < 0 { index = sections.count - 1 }
        sectionControl.selectedSegmentIndex = index
        sectionControl.sendActions(for: .valueChanged)
    }

    @objc private func tableViewDidSwipeRight() {

        var index = sectionControl.selectedSegmentIndex + 1
        if index > sections.count - 1 { index = 0 }
        sectionControl.selectedSegmentIndex = index
        sectionControl.sendActions(for: .valueChanged)
    }

    @objc private func sectionControlDidChange() {

        print("[MetaNodeEditor] selected section control index: \(sectionControl.selectedSegmentIndex)")

        loadDictionary(index: sectionControl.selectedSegmentIndex)
    }

    @objc private func deleteButtonDidTap() {

        print("[MetaNodeEditor] did tap deleteButton")

        viewController?.deleteMetaNodeFromEditNodeItemViewController()
    }
}
