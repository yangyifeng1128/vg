///
/// MetaVoiceOverEditorView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaVoiceOverEditorView: MetaNodeEditorView {

    private(set) var voiceOver: MetaVoiceOver!
    private(set) var rules: [MetaRule]!

    init(voiceOver: MetaVoiceOver, rules: [MetaRule]) {

        super.init()

        self.voiceOver = voiceOver
        self.rules = rules
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    override func populateStyles() {

        var styles: OrderedDictionary<RowKey, Any> = [:]
        if let typeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: voiceOver.nodeType) {
            let title: String = typeTitle + " " + voiceOver.index.description
            styles[.title] = title
        }
        styles[.locationAndSize] = ""
        styles[.typography] = ""
        styles[.background] = voiceOver.backgroundColorCode
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
