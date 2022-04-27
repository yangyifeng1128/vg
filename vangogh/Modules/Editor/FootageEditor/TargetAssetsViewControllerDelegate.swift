///
/// TargetAssetsViewControllerDelegate
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Photos
import UIKit

protocol TargetAssetsViewControllerDelegate: AnyObject {

    func assetDidPick(_ asset: PHAsset, thumbImage: UIImage?)
}
