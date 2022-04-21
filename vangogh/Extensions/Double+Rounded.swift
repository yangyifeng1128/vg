///
/// Double+Rounded
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension Double {

    func rounded(toPlaces places: Int) -> Double {

        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
