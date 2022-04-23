///
/// LocalDocumentManager
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Foundation

enum LocalDocumentType: String {
    case feedback = "feedback"
    case privacyPolicy = "privacy_policy"
    case termsOfService = "terms_of_service"
    case about = "about"
}

class LocalDocumentManager {

    static var shared = LocalDocumentManager()

    func load(type: LocalDocumentType) -> String {

        if let path = Bundle.main.path(forResource: type.rawValue, ofType: "txt") {
            if let string = try? String(contentsOfFile: path) {
                return string
            }
        }
        return ""
    }
}
