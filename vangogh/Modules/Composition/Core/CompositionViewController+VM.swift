///
/// CompositionViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import CoreData
import OSLog

extension CompositionViewController {

    /// 加载草稿列表
    func loadDrafts(completion handler: (() -> Void)? = nil) {

        let request: NSFetchRequest<MetaGame> = MetaGame.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "mtime", ascending: false)]

        do {
            drafts = try CoreDataManager.shared.persistentContainer.viewContext.fetch(request)
            let count: Int = drafts.count
            Logger.composition.info("loading drafts: ok (\(count))")
        } catch {
            Logger.composition.info("loading drafts error: \(error.localizedDescription)")
        }

        if let handler = handler {
            DispatchQueue.main.async {
                handler()
            }
        }
    }

    /// 打开草稿
    func openDraft(_ draft: MetaGame, completion handler: (() -> Void)? = nil) {

        draft.mtime = Int64(Date().timeIntervalSince1970)
        CoreDataManager.shared.saveContext()

        if let handler = handler {
            DispatchQueue.main.async {
                handler()
            }
        }
    }

    /// 保存草稿标题
    func saveDraftTitle(_ draft: MetaGame, newTitle: String, completion handler: (() -> Void)? = nil) {

        draft.title = newTitle
        CoreDataManager.shared.saveContext()

        if let handler = handler {
            DispatchQueue.main.async {
                handler()
            }
        }
    }

    /// 删除草稿
    func deleteDraft(_ draft: MetaGame, completion handler: (() -> Void)? = nil) {

        MetaGameBundleManager.shared.delete(uuid: draft.uuid)
        drafts.removeAll(where: { $0.uuid == draft.uuid })
        CoreDataManager.shared.persistentContainer.viewContext.delete(draft)
        CoreDataManager.shared.saveContext()

        if let handler = handler {
            DispatchQueue.main.async {
                handler()
            }
        }
    }
}
