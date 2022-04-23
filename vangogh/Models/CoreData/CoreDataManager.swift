///
/// CoreDataManager
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import CoreData
import OSLog

class CoreDataManager {

    static let shared = CoreDataManager()

    private init() {
    }

    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "vangogh")

        container.loadPersistentStores(completionHandler: { _, error in
            guard let error = error as NSError? else { return }
            let errorDescription: String = "failed to load persistent stores: \(error)"
            Logger.coreData.critical("\(errorDescription)")
            fatalError(errorDescription)
        })

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }()

    func saveContext() {

        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                Logger.coreData.critical("failed to save core data: \(error.localizedDescription)")
            }
        }
    }
}
