///
/// MetaVoteEditorView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaVoteEditorView: MetaNodeEditorView {

    private(set) var vote: MetaVote!
    private(set) var rules: [MetaRule]!

    init(vote: MetaVote, rules: [MetaRule]) {

        super.init()

        self.vote = vote
        self.rules = rules
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    override func populateStyles() {

        var styles: OrderedDictionary<RowKey, Any> = [:]
        if let typeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: vote.nodeType) {
            let title: String = typeTitle + " " + vote.index.description
            styles[.title] = title
        }
        styles[.locationAndSize] = ""
        styles[.typography] = ""
        styles[.background] = vote.backgroundColorCode
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
