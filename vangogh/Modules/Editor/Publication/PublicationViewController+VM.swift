///
/// PublicationViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import CoreData
import OSLog

extension PublicationViewController {

    /// 同步档案列表
    func syncArchives(completion handler: (() -> Void)? = nil) {

        let archivesURL = URL(string: "\(GUC.templatesURLString)?page=1&sort_by=ctime&sort_order=ascending")!

        URLSession.shared.dataTask(with: archivesURL) { data, _, error in

            guard let data = data else { return }

            do {
                let decoder = JSONDecoder()
                decoder.userInfo[CodingUserInfoKey.context!] = CoreDataManager.shared.persistentContainer.viewContext
                let archivesData = try decoder.decode([MetaTemplate].self, from: data)
                Logger.gameEditor.info("synchronizing \(archivesData.count) archives: ok")
                CoreDataManager.shared.saveContext()
                if let handler = handler {
                    DispatchQueue.main.async {
                        handler()
                    }
                }
            } catch {
                Logger.gameEditor.info("synchronizing archives error: \(error.localizedDescription)")
            }

        }.resume()
    }

    /// 加载档案列表
    func loadArchives(completion handler: (() -> Void)? = nil) {

        let request: NSFetchRequest<MetaTemplate> = MetaTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "status == 1")
        request.sortDescriptors = [NSSortDescriptor(key: "ctime", ascending: false)]

        do {
            archives = try CoreDataManager.shared.persistentContainer.viewContext.fetch(request)
            let count: Int = archives.count
            if count > 0 {
                Logger.gameEditor.info("loading \(count) archives: ok")
            }
        } catch {
            Logger.gameEditor.info("loading archives error: \(error.localizedDescription)")
        }

        if let handler = handler {
            DispatchQueue.main.async {
                handler()
            }
        }
    }
}
