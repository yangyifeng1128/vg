///
/// AgreementsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import OSLog
import UIKit

extension AgreementsViewController {

    @objc func agreeButtonDidTap() {

        agree()
    }

    @objc func disagreeButtonDidTap() {

        disagree()
    }
}

extension AgreementsViewController {

    func agree() {

        UserDefaults.standard.setValue(true, forKey: GKC.agreementsSigned)
        presentingViewController?.dismiss(animated: true, completion: nil)
        Logger.userAssets.info("agreed with terms of service and privacy policy")
    }

    func disagree() {

        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        Logger.userAssets.info("disagreed with terms of service and privacy policy")
    }
}
