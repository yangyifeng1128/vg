///
/// MetaGameBundle
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaGameBundle: Codable {

    private(set) var uuid: String

    /// 当前选中的场景索引
    var selectedSceneIndex: Int = 0
    /// 最大场景索引
    var maxSceneIndex: Int = 0
    /// 内容偏移量
    var contentOffset: CGPoint = GVC.defaultGameboardViewContentOffset {
        didSet {
            let snappedContentOffset: CGPoint = CGPoint(x: contentOffset.x.rounded(), y: contentOffset.y.rounded())
            contentOffset = snappedContentOffset
        }
    }

    /// 图路径
    fileprivate var paths: [SceneTransitions] = []
    /// 场景列表
    var scenes: [MetaScene] {
        var scenes = [MetaScene]()
        for sceneTransitions in paths {
            scenes.append(sceneTransitions.scene)
        }
        return scenes
    }
    /// 穿梭器列表
    var transitions: [MetaTransition] {
        var allTransitions = [MetaTransition]()
        for sceneTransitions in paths {
            guard let transitions = sceneTransitions.transitions else { continue }
            for transition in transitions {
                allTransitions.append(transition)
            }
        }
        return allTransitions
    }

    enum CodingKeys: String, CodingKey {
        case uuid
        case paths
        case selectedSceneIndex = "selected_scene_index"
        case maxSceneIndex = "max_scene_index"
        case contentOffset = "content_offset"
    }

    /// 初始化
    init(uuid: String) {

        self.uuid = uuid
    }

    required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try container.decode(String.self, forKey: .uuid)
        paths = try container.decode([SceneTransitions].self, forKey: .paths)
        selectedSceneIndex = try container.decode(Int.self, forKey: .selectedSceneIndex)
        maxSceneIndex = try container.decode(Int.self, forKey: .maxSceneIndex)
        contentOffset = try container.decode(CGPoint.self, forKey: .contentOffset)
    }

    func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(paths, forKey: .paths)
        try container.encode(selectedSceneIndex, forKey: .selectedSceneIndex)
        try container.encode(maxSceneIndex, forKey: .maxSceneIndex)
        try container.encode(contentOffset, forKey: .contentOffset)
    }

    func addScene(uuid: String = UUID().uuidString.lowercased(), title: String? = "", center: CGPoint) -> MetaScene {

        maxSceneIndex = maxSceneIndex + 1
        let scene: MetaScene = MetaScene(index: maxSceneIndex, uuid: uuid, title: title, center: center)
        paths.append(SceneTransitions(scene: scene))
        return scene
    }

    func addTransition(from: Int, to: Int, conditions: [MetaCondition]) -> MetaTransition? {

        let transition: MetaTransition = MetaTransition(from: from, to: to, conditions: conditions)
        guard let sceneTransitions = paths.first(where: { $0.scene.index == from }) else { return nil }
        if sceneTransitions.transitions != nil {
            sceneTransitions.addTransition(transition)
        } else {
            sceneTransitions.transitions = [transition]
        }
        return transition
    }

    func updateScene(_ scene: MetaScene) {

        for sceneTransitions in paths {
            if sceneTransitions.scene.index == scene.index {
                sceneTransitions.scene = scene
                break
            }
        }
    }

    func findScene(index: Int) -> MetaScene? {

        for sceneTransitions in paths {
            if sceneTransitions.scene.index == index {
                return sceneTransitions.scene
            }
        }
        return nil
    }

    func selectedScene() -> MetaScene? {

        return findScene(index: selectedSceneIndex)
    }

    func findTransitions(from: Int) -> [MetaTransition] {

        for sceneTransitions in paths {
            if sceneTransitions.scene.index == from {
                return sceneTransitions.transitions ?? []
            }
        }
        return []
    }

    func selectedTransitions() -> [MetaTransition] {

        return findTransitions(from: selectedSceneIndex)
    }

    func findConditions(from: Int, to: Int) -> [MetaCondition] {

        let transitions = findTransitions(from: from)

        for transition in transitions {
            if transition.to == to {
                return transition.conditions
            }
        }
        return []
    }

    func deleteSelectedScene() {

        for (location, sceneTransitions) in paths.enumerated() {
            if sceneTransitions.scene.index == selectedSceneIndex {
                paths.remove(at: location)
            } else {
                sceneTransitions.transitions?.removeAll(where: { $0.to == selectedSceneIndex })
            }
        }
    }

    func deleteTransition(_ transition: MetaTransition) {

        for sceneTransitions in paths {
            if sceneTransitions.scene.index == transition.from {
                sceneTransitions.transitions?.removeAll(where: { $0 == transition })
            }
        }
    }

    func deleteCondition(transition: MetaTransition, condition: MetaCondition) {

        for (i, transitionCondition) in transition.conditions.enumerated() {
            if transitionCondition == condition {
                transition.conditions.remove(at: i)
            }
        }
    }
}

extension MetaGameBundle: CustomStringConvertible {

    var description: String {

        var info: String = "uuid: \(uuid), selectedSceneIndex: \(selectedSceneIndex), maxSceneIndex: \(maxSceneIndex), contentOffset: \(contentOffset), sceneTransitions:\n"

        var rows = [String]()
        for sceneTransitions in paths {
            guard let transitions = sceneTransitions.transitions else {
                rows.append("\(sceneTransitions.scene) -> []")
                continue
            }
            var row = [String]()
            for transition in transitions {
                let value = "\(transition.to)"
                row.append(value)
            }
            rows.append("\(sceneTransitions.scene) -> [\(row.joined(separator: ", "))]")
        }
        info.append(rows.joined(separator: "\n"))

        return info
    }
}

private class SceneTransitions: Codable {

    var scene: MetaScene
    var transitions: [MetaTransition]?

    enum CodingKeys: String, CodingKey {
        case scene
        case transitions
    }

    init(scene: MetaScene) {

        self.scene = scene
    }

    func addTransition(_ transition: MetaTransition) {

        transitions?.insert(transition, at: 0)
    }
}
