///
/// NewGameViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import CoreData
import OSLog

extension NewGameViewController {

    /// 同步模版列表
    func syncTemplates(completion handler: (() -> Void)? = nil) {

        let templatesURL = URL(string: "\(GUC.templatesURLString)?page=1&sort_by=ctime&sort_order=ascending")!

        URLSession.shared.dataTask(with: templatesURL) { data, _, error in

            guard let data = data else { return }

            do {
                let decoder = JSONDecoder()
                decoder.userInfo[CodingUserInfoKey.context!] = CoreDataManager.shared.persistentContainer.viewContext
                let templatesData = try decoder.decode([MetaTemplate].self, from: data)
                Logger.composition.info("synchronizing \(templatesData.count) templates: ok")
                CoreDataManager.shared.saveContext()
                if let handler = handler {
                    DispatchQueue.main.async {
                        handler()
                    }
                }
            } catch {
                Logger.composition.error("synchronizing templates error: \(error.localizedDescription)")
            }

        }.resume()
    }

    /// 加载模版列表
    func loadTemplates(completion handler: (() -> Void)? = nil) {

        let request: NSFetchRequest<MetaTemplate> = MetaTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "status == 1")
        request.sortDescriptors = [NSSortDescriptor(key: "ctime", ascending: false)]

        do {
            templates = try CoreDataManager.shared.persistentContainer.viewContext.fetch(request)
            let count: Int = templates.count
            if count > 0 {
                Logger.composition.info("loading \(count) templates: ok")
            }
        } catch {
            Logger.composition.error("loading templates error: \(error.localizedDescription)")
        }

        if let handler = handler {
            DispatchQueue.main.async {
                handler()
            }
        }
    }

    /// 添加作品
    func addGame(completion handler: ((MetaGame) -> Void)? = nil) {

        let game: MetaGame = MetaGame(context: CoreDataManager.shared.persistentContainer.viewContext)
        game.uuid = UUID().uuidString.lowercased()
        game.ctime = Int64(Date().timeIntervalSince1970)
        game.mtime = game.ctime
        var counter: Int = UserDefaults.standard.integer(forKey: GKC.localGamesCounter)
        counter = counter + 1
        UserDefaults.standard.setValue(counter, forKey: GKC.localGamesCounter)
        game.title = NSLocalizedString("Draft", comment: "") + " " + counter.description
        game.status = 1
        games.append(game)
        CoreDataManager.shared.saveContext()

        MetaGameBundleManager.shared.save(MetaGameBundle(uuid: game.uuid))

        if let handler = handler {
            DispatchQueue.main.async {
                handler(game)
            }
        }
    }
}
