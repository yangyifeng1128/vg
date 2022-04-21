///
/// CGFloat+Rounded
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension CGFloat {

    func rounded(toPlaces places: Int) -> CGFloat {

        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}
