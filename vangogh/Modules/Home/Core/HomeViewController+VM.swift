///
/// HomeViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import CoreData
import OSLog
import SnapKit
import UIKit

extension HomeViewController {

    /// 加载记录列表
    func loadRecords(completion handler: (() -> Void)? = nil) {

        let request: NSFetchRequest<MetaRecord> = MetaRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "mtime", ascending: false)]

        do {
            records = try CoreDataManager.shared.persistentContainer.viewContext.fetch(request)
            Logger.home.info("loading records: ok")
        } catch {
            Logger.home.info("loading records error: \(error.localizedDescription)")
        }

        if let handler = handler {
            DispatchQueue.main.async {
                handler()
            }
        }
    }
}
