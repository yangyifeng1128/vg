///
/// ScenePlayerView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import CoreMedia
import SnapKit
import UIKit

protocol ScenePlayerViewDelegate: AnyObject {
    func nodeViewWillBeginEditing(_ nodeView: MetaNodeView)
    func saveBundleWhenNodeViewChanged(node: MetaNode)
}

class ScenePlayerView: UIView {

    /// 渲染对齐方式枚举值
    enum RenderAlignment {
        case center
        case topCenter
    }

    weak var delegate: ScenePlayerViewDelegate?

    var rendererView: SceneRendererView!

    private var renderSize: CGSize!
    private var renderAlignment: RenderAlignment!
    var isEditable: Bool!
    var renderScale: CGFloat!

    private var nodeViewContainer: RoundedView!
    private(set) var nodeViewList: [MetaNodeView] = []

    /// 初始化
    init(renderSize: CGSize, renderAlignment: RenderAlignment = .center, isEditable: Bool = false) {

        super.init(frame: .zero)

        self.renderSize = renderSize
        self.renderAlignment = renderAlignment
        self.isEditable = isEditable

        // 计算渲染缩放比例

        var multiplier: CGFloat = 1
        if UIDevice.current.userInterfaceIdiom == .pad {
            multiplier = 768 / GVC.standardDeviceSize.width // 计算 multiplier，以兼容不同设备（phone、pad）之间的标准设备尺寸
        }
        renderScale = (renderSize.height / (GVC.standardDeviceSize.height * multiplier)).rounded(toPlaces: 4) // 以高度为基准，计算渲染缩放比例

        // 初始化视图

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = isEditable ? .clear : .black

        // 初始化「渲染器视图」

        initRendererView()

        // 初始化「组件视图」

        initNodeViews()
    }

    private func initRendererView() {

        // 初始化渲染器视图

        rendererView = SceneRendererView(renderScale: renderScale)
        addSubview(rendererView)
        rendererView.snp.makeConstraints { make -> Void in
            make.width.equalTo(renderSize.width)
            make.height.equalTo(renderSize.height)
            if renderAlignment == .topCenter {
                make.centerX.equalToSuperview()
                make.top.equalTo(safeAreaLayoutGuide.snp.top)
            } else {
                make.center.equalToSuperview()
            }
        }
    }

    private func initNodeViews() {

        // 初始化组件视图

        nodeViewContainer = RoundedView(cornerRadius: GVC.standardDeviceCornerRadius * renderScale)
        addSubview(nodeViewContainer)
        nodeViewContainer.snp.makeConstraints { make -> Void in
            make.edges.equalTo(rendererView)
        }
    }
}

extension ScenePlayerView {

    func updateNodeViews(nodes: [MetaNode]) {

        // 移除先前的全部组件视图

        for nodeView in nodeViewList {
            nodeView.removeFromSuperview()
        }
        nodeViewList.removeAll()

        // 添加新的组件视图

        nodes.forEach { addNodeView(node: $0) }

        // 调整父视图及其他相关视图的布局

        updateNodeViewContainer()
    }

    func addNodeView(node: MetaNode) {

        var nodeView: MetaNodeView?
        switch node.nodeType {
        case .music:
            if let music = node as? MetaMusic {
                nodeView = MetaMusicView(music: music)
            }
            break
        case .voiceOver:
            if let voiceOver = node as? MetaVoiceOver {
                nodeView = MetaVoiceOverView(voiceOver: voiceOver)
            }
            break
        case .text:
            if let text = node as? MetaText {
                nodeView = MetaTextView(text: text)
            }
            break
        case .animatedImage:
            if let animatedImage = node as? MetaAnimatedImage {
                nodeView = MetaAnimatedImageView(animatedImage: animatedImage)
            }
            break
        case .button:
            if let button = node as? MetaButton {
                nodeView = MetaButtonView(button: button)
            }
            break
        case .vote:
            if let vote = node as? MetaVote {
                nodeView = MetaVoteView(vote: vote)
            }
            break
        case .multipleChoice:
            if let multipleChoice = node as? MetaMultipleChoice {
                nodeView = MetaMultipleChoiceView(multipleChoice: multipleChoice)
            }
            break
        case .hotspot:
            if let hotspot = node as? MetaHotspot {
                nodeView = MetaHotspotView(hotspot: hotspot)
            }
            break
        case .checkpoint:
            if let checkpoint = node as? MetaCheckpoint {
                nodeView = MetaCheckpointView(checkpoint: checkpoint)
            }
            break
        case .bulletScreen:
            if let bulletScreen = node as? MetaBulletScreen {
                let comments: [MetaComment] = [
                    MetaComment(info: "虎年大吉", startTimeMilliseconds: 0),
                    MetaComment(info: "恭喜发财", startTimeMilliseconds: 0),
                    MetaComment(info: "心想事成", startTimeMilliseconds: 500),
                    MetaComment(info: "阖家欢乐", startTimeMilliseconds: 500),
                    MetaComment(info: "万事如意", startTimeMilliseconds: 500)]
                bulletScreen.comments = comments
                nodeView = MetaBulletScreenView(bulletScreen: bulletScreen)
            }
            break
        case .sketch:
            if let sketch = node as? MetaSketch {
                nodeView = MetaSketchView(sketch: sketch)
            }
            break
        case .coloring:
            if let coloring = node as? MetaColoring {
                nodeView = MetaColoringView(coloring: coloring)
            }
            break
        case .camera:
            if let camera = node as? MetaCamera {
                nodeView = MetaCameraView(camera: camera)
            }
            break
        case .arCamera:
            if let arCamera = node as? MetaARCamera {
                nodeView = MetaARCameraView(arCamera: arCamera)
            }
            break
        case .duet:
            if let duet = node as? MetaDuet {
                nodeView = MetaDuetView(duet: duet)
            }
            break
        }

        if let nodeView = nodeView {
            nodeView.playerView = self
            nodeView.isHidden = true
            if isEditable {
                nodeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nodeViewWillBeginEditing)))
            }
            nodeView.layout(parent: nodeViewContainer)
            nodeViewList.append(nodeView)
        }
    }

    func removeNodeView(node: MetaNode) {

        for (i, nodeView) in nodeViewList.enumerated().reversed() {
            if nodeView.node.uuid == node.uuid {
                nodeView.removeFromSuperview()
                nodeViewList.remove(at: i)
            }
        }
    }

    func updateNodeViewContainer() {
    }

    func showOrHideNodeViews(at time: CMTime) {

        for nodeView in nodeViewList {
            let currentTimeMilliseconds: Int64 = time.milliseconds()
            let endTimeMilliseconds: Int64 = nodeView.node.startTimeMilliseconds + nodeView.node.durationMilliseconds
            if nodeView.isHidden && currentTimeMilliseconds >= nodeView.node.startTimeMilliseconds && currentTimeMilliseconds <= endTimeMilliseconds {
                nodeView.isHidden = false
            } else if !nodeView.isHidden && (currentTimeMilliseconds < nodeView.node.startTimeMilliseconds || currentTimeMilliseconds > endTimeMilliseconds) {
                nodeView.isHidden = true
            }
        }
    }
}

extension ScenePlayerView {

    @objc func nodeViewWillBeginEditing(_ sender: UITapGestureRecognizer) {

        guard let nodeView: MetaNodeView = sender.view as? MetaNodeView else { return }

        delegate?.nodeViewWillBeginEditing(nodeView)
    }

    func saveBundleWhenNodeViewChanged(node: MetaNode) {

        delegate?.saveBundleWhenNodeViewChanged(node: node)
    }
}
