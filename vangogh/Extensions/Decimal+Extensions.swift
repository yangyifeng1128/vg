///
/// Decimal+Extensions
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension Decimal {

    func doubleValue() -> Double {

        return NSDecimalNumber(decimal: self).doubleValue
    }
}
