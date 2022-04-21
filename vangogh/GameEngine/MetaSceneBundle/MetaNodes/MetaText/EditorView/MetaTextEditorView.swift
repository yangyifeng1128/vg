///
/// MetaTextEditorView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaTextEditorView: MetaNodeEditorView {

    private(set) var text: MetaText!
    private(set) var rules: [MetaRule]!

    init(text: MetaText, rules: [MetaRule]) {

        super.init()

        self.text = text
        self.rules = rules
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    override func populateStyles() {

        var styles: OrderedDictionary<RowKey, Any> = [:]
        if let typeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: text.nodeType) {
            let title: String = typeTitle + " " + text.index.description
            styles[.title] = title
        }
        styles[.locationAndSize] = ""
        styles[.typography] = ""
        styles[.background] = text.backgroundColorCode
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
