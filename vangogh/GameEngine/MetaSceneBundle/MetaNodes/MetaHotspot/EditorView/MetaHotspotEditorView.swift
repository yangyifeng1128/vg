///
/// MetaHotspotEditorView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaHotspotEditorView: MetaNodeEditorView {

    private(set) var hotspot: MetaHotspot!
    private(set) var rules: [MetaRule]!

    init(hotspot: MetaHotspot, rules: [MetaRule]) {

        super.init()

        self.hotspot = hotspot
        self.rules = rules
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    override func populateStyles() {

        var styles: OrderedDictionary<RowKey, Any> = [:]
        if let typeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: hotspot.nodeType) {
            let title: String = typeTitle + " " + hotspot.index.description
            styles[.title] = title
        }
        styles[.locationAndSize] = ""
        styles[.typography] = ""
        styles[.background] = hotspot.backgroundColorCode
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
