///
/// SceneEditorPlayerView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import CoreMedia
import SnapKit
import UIKit

class SceneEditorPlayerView: UIView {

    /// 数据源
    weak var dataSource: SceneEditorPlayerViewDataSource? {
        didSet { reloadData() }
    }
    /// 代理
    weak var delegate: SceneEditorPlayerViewDelegate?

    /// 渲染视图
    var rendererView: SceneEditorRendererView!
    var nodeViewContainer: RoundedView!
    var nodeViewList: [MetaNodeView] = []

    /// 渲染尺寸
    var renderSize: CGSize = .zero
    /// 渲染缩放比例
    var scale: CGFloat = 1

    /// 初始化
    init(renderSize: CGSize) {

        super.init(frame: .zero)

        self.renderSize = renderSize

        initViews()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    /// 初始化视图
    private func initViews() {

        backgroundColor = .clear
    }
}

extension SceneEditorPlayerView {

    func updateNodeViews(nodes: [MetaNode]) {

        // 移除先前的全部组件视图

        nodeViewList.forEach { $0.removeFromSuperview() }
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
            nodeView.dataSource = self
            nodeView.isHidden = true
            nodeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nodeViewWillBeginEditing)))
//            nodeView.layout(parent: nodeViewContainer)
            nodeView.reloadData()
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
