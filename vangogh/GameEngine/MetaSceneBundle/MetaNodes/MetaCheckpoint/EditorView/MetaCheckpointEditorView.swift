///
/// MetaCheckpointEditorView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaCheckpointEditorView: MetaNodeEditorView {

    private(set) var checkpoint: MetaCheckpoint!
    private(set) var rules: [MetaRule]!

    init(checkpoint: MetaCheckpoint, rules: [MetaRule]) {

        super.init()

        self.checkpoint = checkpoint
        self.rules = rules
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    override func populateStyles() {

        var styles: OrderedDictionary<RowKey, Any> = [:]
        if let typeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: checkpoint.nodeType) {
            let title: String = typeTitle + " " + checkpoint.index.description
            styles[.title] = title
        }
        styles[.locationAndSize] = ""
        styles[.typography] = ""
        styles[.background] = checkpoint.backgroundColorCode
        styles[.corner] = ""
        styles[.padding] = ""

        dictionary = styles
    }

    override func populateInteractions() {

        var interactions: OrderedDictionary<RowKey, Any> = [:]

        interactions[.rules] = rules

        dictionary = interactions
    }
}
