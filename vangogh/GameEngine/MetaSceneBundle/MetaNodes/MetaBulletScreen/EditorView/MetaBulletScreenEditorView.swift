///
/// MetaBulletScreenEditorView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaBulletScreenEditorView: MetaNodeEditorView {

    private(set) var bulletScreen: MetaBulletScreen!
    private(set) var rules: [MetaRule]!

    init(bulletScreen: MetaBulletScreen, rules: [MetaRule]) {

        super.init()

        self.bulletScreen = bulletScreen
        self.rules = rules
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    override func populateStyles() {

        var styles: OrderedDictionary<RowKey, Any> = [:]
        if let typeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: bulletScreen.nodeType) {
            let title: String = typeTitle + " " + bulletScreen.index.description
            styles[.title] = title
        }
        styles[.locationAndSize] = ""
        styles[.typography] = ""
        styles[.background] = bulletScreen.backgroundColorCode
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
