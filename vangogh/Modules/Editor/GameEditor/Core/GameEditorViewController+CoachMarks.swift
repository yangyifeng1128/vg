///
/// GameEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import Instructions
import UIKit

extension GameEditorViewController {

    /// 初始化「引导标记控制器」
    func initCoachMarksController() {

        coachMarksController = CoachMarksController()
        coachMarksController.overlay.isUserInteractionEnabled = true
        coachMarksController.overlay.backgroundColor = UIColor.systemFill.withAlphaComponent(0.8)
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
    }

    /// 显示引导标记
    func showCoachMarks() {

        if !UserDefaults.standard.bool(forKey: GKC.firstTourOfGameEditorEnded) {
            if coachMarksController.flow.isStarted {
                coachMarksController.flow.resume()
            } else {
                coachMarksController.start(in: .window(over: self))
            }
        } else {
            if coachMarksController.flow.isStarted {
                coachMarksController.stop()
            }
            UserDefaults.standard.set(0, forKey: GKC.skippedCoachMarksCountOfGameEditor)
        }
    }

    /// 隐藏引导标记
    func hideCoachMarks() {

        if coachMarksController.flow.isStarted {
            coachMarksController.stop(immediately: true)
        }
    }
}

extension GameEditorViewController: CoachMarksControllerDataSource {

    /// 设置引导标记数量
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {

        return 4
    }

    /// 设置引导标
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {

        // 贴合视图边框大小的剪影路径制作器

        let flatCutoutPathMaker = { (frame: CGRect) -> UIBezierPath in
            return UIBezierPath(rect: frame)
        }

        // 贴合视图边框大小的圆形剪影路径制作器

        let circularCutoutPathMaker = { (frame: CGRect) -> UIBezierPath in
            return UIBezierPath(ovalIn: frame)
        }

        // 初始化引导标记

        var coachMark: CoachMark
        switch index {
        case 0:
            coachMark = coachMarksController.helper.makeCoachMark(for: backButton, pointOfInterest: backButton.center, cutoutPathMaker: circularCutoutPathMaker)
            // coachMark.isUserInteractionEnabledInsideCutoutPath = true
            break
        case 1:
            coachMark = coachMarksController.helper.makeCoachMark(for: gameSettingsButton, pointOfInterest: gameSettingsButton.center, cutoutPathMaker: circularCutoutPathMaker)
            // coachMark.isUserInteractionEnabledInsideCutoutPath = true
            break
        case 2:
            coachMark = coachMarksController.helper.makeCoachMark(for: publishButton, pointOfInterest: publishButton.center, cutoutPathMaker: circularCutoutPathMaker)
            // coachMark.isUserInteractionEnabledInsideCutoutPath = true
            break
        case 3:
            coachMark = coachMarksController.helper.makeCoachMark(for: bottomViewContainer, pointOfInterest: bottomViewContainer.center, cutoutPathMaker: flatCutoutPathMaker)
            break
        default:
            coachMark = coachMarksController.helper.makeCoachMark()
            break
        }
        coachMark.gapBetweenCoachMarkAndCutoutPath = 6

        return coachMark
    }

    /// 设置引导标记的「主体视图」与「箭头视图」
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {

        // 初始化「主体视图」

        let bodyView: TransparentCoachMarkBodyView = TransparentCoachMarkBodyView()
        var hint: String
        switch index {
        case 0:
            hint = NSLocalizedString("Hint_GameEditor_Back", comment: "")
            break
        case 1:
            hint = NSLocalizedString("Hint_GameEditor_GameSettings", comment: "")
            break
        case 2:
            hint = NSLocalizedString("Hint_GameEditor_Publish", comment: "")
            break
        case 3:
            hint = NSLocalizedString("Hint_GameEditor_AddScene", comment: "")
            break
        default:
            hint = ""
            break
        }
        bodyView.hintTextView.text = hint

        // 初始化「箭头视图」

        var arrowView: TransparentCoachMarkArrowView?
        if let arrowOrientation = coachMark.arrowOrientation {
            arrowView = TransparentCoachMarkArrowView(orientation: arrowOrientation)
        }

        return (bodyView: bodyView, arrowView: arrowView)
    }
}

extension GameEditorViewController: CoachMarksControllerDelegate {

    func coachMarksController(_ coachMarksController: CoachMarksController, configureOrnamentsOfOverlay overlay: UIView) {

    }

    func coachMarksController(_ coachMarksController: CoachMarksController, willLoadCoachMarkAt index: Int) -> Bool {

        // 跳过先前的全部引导标记

        let skippedCoachMarksCountOfGameEditor: Int = UserDefaults.standard.integer(forKey: GKC.skippedCoachMarksCountOfGameEditor)
        return index >= skippedCoachMarksCountOfGameEditor ? true : false
    }

    func coachMarksController(_ coachMarksController: CoachMarksController, willShow coachMark: inout CoachMark, afterSizeTransition: Bool, at index: Int) {

    }

    func coachMarksController(_ coachMarksController: CoachMarksController, didShow coachMark: CoachMark, afterSizeTransition: Bool, at index: Int) {

    }

    func coachMarksController(_ coachMarksController: CoachMarksController, willShow coachMark: inout CoachMark, beforeChanging change: ConfigurationChange, at index: Int) {

    }

    func coachMarksController(_ coachMarksController: CoachMarksController, didShow coachMark: CoachMark, afterChanging change: ConfigurationChange, at index: Int) {

    }

    func coachMarksController(_ coachMarksController: CoachMarksController, willHide coachMark: CoachMark, at index: Int) {

    }

    func coachMarksController(_ coachMarksController: CoachMarksController, didHide coachMark: CoachMark, at index: Int) {

        // 记录已跳过的引导标记数

        let skippedCoachMarksCountOfGameEditor = index + 1
        UserDefaults.standard.set(skippedCoachMarksCountOfGameEditor, forKey: GKC.skippedCoachMarksCountOfGameEditor)

        // 暂停引导，等待用户下一步操作

        if index == 3 {
            // coachMarksController.flow.pause(and: .hideInstructions)
        }

        // 结束引导标记

        if index == 3 {
            UserDefaults.standard.set(true, forKey: GKC.firstTourOfGameEditorEnded)
        }
    }

    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool) {

    }

    func shouldHandleOverlayTap(in coachMarksController: CoachMarksController, at index: Int) -> Bool {

        return true
    }
}
