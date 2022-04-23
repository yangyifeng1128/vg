///
/// MetaOperatorManager
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

enum MetaOperatorKey: String, CaseIterable, Codable {

    // Comparison Operators

    case equalTo
    case notEqualTo
    case greaterThan
    case lessThan

    // Logical Operators

    // case like
}

class MetaOperatorManager {

    static var shared = MetaOperatorManager()

    private lazy var operators: [MetaOperator] = {

        var operators = [MetaOperator]()
        for key in MetaOperatorKey.allCases {
            operators.append(MetaOperator(key: .equalTo, callback: { (lhs, rhs) in
                return lhs == rhs
            }))
            operators.append(MetaOperator(key: .notEqualTo, callback: { (lhs, rhs) in
                return lhs != rhs
            }))
            operators.append(MetaOperator(key: .greaterThan, callback: { (lhs, rhs) in
                return lhs > rhs
            }))
            operators.append(MetaOperator(key: .lessThan, callback: { (lhs, rhs) in
                return lhs < rhs
            }))
        }
        return operators
    }()

    func get() -> [MetaOperator] {

        return operators
    }
}
