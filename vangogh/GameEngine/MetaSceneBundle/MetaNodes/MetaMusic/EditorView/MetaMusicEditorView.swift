///
/// MetaMusicEditorView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaMusicEditorView: MetaNodeEditorView {

    private(set) var music: MetaMusic!
    private(set) var rules: [MetaRule]!

    init(music: MetaMusic, rules: [MetaRule]) {

        super.init()

        self.music = music
        self.rules = rules
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    override func populateStyles() {

        var styles: OrderedDictionary<RowKey, Any> = [:]
        if let typeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: music.nodeType) {
            let title: String = typeTitle + " " + music.index.description
            styles[.title] = title
        }
        styles[.locationAndSize] = ""
        styles[.typography] = ""
        styles[.background] = music.backgroundColorCode
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
