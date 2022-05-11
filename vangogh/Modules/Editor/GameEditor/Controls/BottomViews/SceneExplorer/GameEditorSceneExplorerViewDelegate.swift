///
/// GameEditorSceneExplorerViewDelegate
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

protocol GameEditorSceneExplorerViewDelegate: AnyObject {

    func closeSceneButtonDidTap()
    func deleteSceneButtonDidTap()
    func sceneTitleLabelDidTap()

    func manageTransitionsButtonDidTap()

    func previewSceneButtonDidTap()
    func editSceneButtonDidTap()

    func transitionTableViewCellDidSelect(_ tableView: UITableView, indexPath: IndexPath)
}
