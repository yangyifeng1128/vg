///
/// AgreementsViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension AgreementsViewController {

    @objc func agreeButtonDidTap() {

        UserDefaults.standard.setValue(true, forKey: GKC.agreementsSigned)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @objc func disagreeButtonDidTap() {

        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    }
}
