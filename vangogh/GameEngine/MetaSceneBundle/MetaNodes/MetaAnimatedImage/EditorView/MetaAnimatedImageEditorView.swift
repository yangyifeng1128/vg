///
/// MetaAnimatedImageEditorView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaAnimatedImageEditorView: MetaNodeEditorView {

    private(set) var animatedImage: MetaAnimatedImage!
    private(set) var rules: [MetaRule]!

    init(animatedImage: MetaAnimatedImage, rules: [MetaRule]) {

        super.init()

        self.animatedImage = animatedImage
        self.rules = rules
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    override func populateStyles() {

        var styles: OrderedDictionary<RowKey, Any> = [:]
        if let typeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: animatedImage.nodeType) {
            let title: String = typeTitle + " " + animatedImage.index.description
            styles[.title] = title
        }
        styles[.locationAndSize] = ""
        styles[.typography] = ""
        styles[.background] = animatedImage.backgroundColorCode
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
