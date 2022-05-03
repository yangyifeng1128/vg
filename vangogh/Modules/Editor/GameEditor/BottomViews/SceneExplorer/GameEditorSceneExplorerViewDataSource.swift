///
/// GameEditorSceneExplorerView
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

protocol GameEditorSceneExplorerViewDataSource: AnyObject {

    func selectedScene() -> MetaScene?

    func numberOfTransitionTableViewCells() -> Int
    func transitionTableViewCell(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
}
