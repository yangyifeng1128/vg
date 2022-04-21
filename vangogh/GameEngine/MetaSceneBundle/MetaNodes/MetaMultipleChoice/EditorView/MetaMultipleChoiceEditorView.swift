///
/// MetaMultipleChoiceEditorView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaMultipleChoiceEditorView: MetaNodeEditorView {

    private(set) var multipleChoice: MetaMultipleChoice!
    private(set) var rules: [MetaRule]!

    init(multipleChoice: MetaMultipleChoice, rules: [MetaRule]) {

        super.init()

        self.multipleChoice = multipleChoice
        self.rules = rules
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    override func populateStyles() {

        var styles: OrderedDictionary<RowKey, Any> = [:]
        if let typeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: multipleChoice.nodeType) {
            let title: String = typeTitle + " " + multipleChoice.index.description
            styles[.title] = title
        }
        styles[.locationAndSize] = ""
        styles[.typography] = ""
        styles[.background] = multipleChoice.backgroundColorCode
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
