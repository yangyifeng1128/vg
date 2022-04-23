///
/// CoreImageExtension
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import CoreImage
import Foundation

extension CIImage {

    func apply(alpha: CGFloat) -> CIImage {

        let filter = CIFilter(name: "CIColorMatrix")
        filter?.setDefaults()
        filter?.setValue(self, forKey: kCIInputImageKey)
        let alphaVector = CIVector.init(x: 0, y: 0, z: 0, w: alpha)
        filter?.setValue(alphaVector, forKey: "inputAVector")
        
        if let outputImage = filter?.outputImage {
            return outputImage
        }
        return self
    }
}
