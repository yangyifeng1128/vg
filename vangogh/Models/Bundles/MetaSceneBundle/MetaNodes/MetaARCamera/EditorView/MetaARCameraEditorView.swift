///
/// MetaARCameraEditorView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

class MetaARCameraEditorView: MetaNodeEditorView {

    private(set) var arCamera: MetaARCamera!
    private(set) var rules: [MetaRule]!

    init(arCamera: MetaARCamera, rules: [MetaRule]) {

        super.init()

        self.arCamera = arCamera
        self.rules = rules
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    override func populateStyles() {

        var styles: OrderedDictionary<RowKey, Any> = [:]
        if let typeTitle = MetaNodeTypeManager.shared.getNodeTypeLocalizedTitle(nodeType: arCamera.nodeType) {
            let title: String = typeTitle + " " + arCamera.index.description
            styles[.title] = title
        }
        styles[.locationAndSize] = ""
        styles[.typography] = ""
        styles[.background] = arCamera.backgroundColorCode
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
