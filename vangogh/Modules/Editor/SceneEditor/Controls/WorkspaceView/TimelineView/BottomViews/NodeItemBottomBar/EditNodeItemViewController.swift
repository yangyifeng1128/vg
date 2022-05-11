///
/// EditNodeItemViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import SnapKit
import UIKit

class EditNodeItemViewController: UIViewController {

    /// 视图布局常量枚举值
    enum VC {
    }

    weak var delegate: EditNodeItemViewControllerDelegate?

    private var editorView: MetaNodeEditorView!

    private(set) var node: MetaNode!
    private(set) var rules: [MetaRule]!

    /// 初始化
    init(node: MetaNode, rules: [MetaRule]) {

        super.init(nibName: nil, bundle: nil)

        self.node = node
        self.rules = rules
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 视图加载完成
    override func viewDidLoad() {

        super.viewDidLoad()

        // 单独强制设置用户界面风格

        overrideUserInterfaceStyle = SceneEditorViewController.preferredUserInterfaceStyle

        initViews()
    }

    /// 视图即将显示
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // 隐藏导航栏

        navigationController?.navigationBar.isHidden = true
    }

    /// 初始化视图
    private func initViews() {

        view.backgroundColor = .bcGrey

        // 初始化「编辑器视图」

        initEditorView()
    }

    /// 初始化「编辑器视图」
    private func initEditorView() {

        switch node.nodeType {
        case .music:
            if let music = node as? MetaMusic {
                editorView = MetaMusicEditorView(music: music, rules: rules)
            }
            break
        case .voiceOver:
            if let voiceOver = node as? MetaVoiceOver {
                editorView = MetaVoiceOverEditorView(voiceOver: voiceOver, rules: rules)
            }
            break
        case .text:
            if let text = node as? MetaText {
                editorView = MetaTextEditorView(text: text, rules: rules)
            }
            break
        case .animatedImage:
            if let animatedImage = node as? MetaAnimatedImage {
                editorView = MetaAnimatedImageEditorView(animatedImage: animatedImage, rules: rules)
            }
            break
        case .button:
            if let button = node as? MetaButton {
                editorView = MetaButtonEditorView(button: button, rules: rules)
            }
            break
        case .vote:
            if let vote = node as? MetaVote {
                editorView = MetaVoteEditorView(vote: vote, rules: rules)
            }
            break
        case .multipleChoice:
            if let multipleChoice = node as? MetaMultipleChoice {
                editorView = MetaMultipleChoiceEditorView(multipleChoice: multipleChoice, rules: rules)
            }
            break
        case .hotspot:
            if let hotspot = node as? MetaHotspot {
                editorView = MetaHotspotEditorView(hotspot: hotspot, rules: rules)
            }
            break
        case .checkpoint:
            if let checkpoint = node as? MetaCheckpoint {
                editorView = MetaCheckpointEditorView(checkpoint: checkpoint, rules: rules)
            }
            break
        case .bulletScreen:
            if let bulletScreen = node as? MetaBulletScreen {
                editorView = MetaBulletScreenEditorView(bulletScreen: bulletScreen, rules: rules)
            }
            break
        case .sketch:
            if let sketch = node as? MetaSketch {
                editorView = MetaSketchEditorView(sketch: sketch, rules: rules)
            }
            break
        case .coloring:
            if let coloring = node as? MetaColoring {
                editorView = MetaColoringEditorView(coloring: coloring, rules: rules)
            }
            break
        case .camera:
            if let camera = node as? MetaCamera {
                editorView = MetaCameraEditorView(camera: camera, rules: rules)
            }
            break
        case .arCamera:
            if let arCamera = node as? MetaARCamera {
                editorView = MetaARCameraEditorView(arCamera: arCamera, rules: rules)
            }
            break
        case .duet:
            if let duet = node as? MetaDuet {
                editorView = MetaDuetEditorView(duet: duet, rules: rules)
            }
            break
        }

        editorView.viewController = self
        view.addSubview(editorView)
        editorView.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }

        if let vc = sheetViewController, let scrollView = editorView.tableView {
            vc.handleScrollView(scrollView)
        }
    }
}

extension EditNodeItemViewController {

    func saveBundleWhenNodeItemViewChanged() {

        delegate?.saveBundleWhenNodeItemViewChanged(node: node, rules: rules)
    }

    func deleteMetaNodeFromEditNodeItemViewController() {

        delegate?.deleteMetaNodeFromEditNodeItemViewController(node: node)
    }
}
