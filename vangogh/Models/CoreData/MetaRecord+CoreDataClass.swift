///
/// MetaRecord+CoreDataClass
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import CoreData
import OSLog

@objc(MetaRecord)
public class MetaRecord: NSManagedObject, Codable {

    enum CodingKeys: String, CodingKey {
        case bundleFileName = "bundle_file_name"
        case checksum
        case ctime
        case mtime
        case status
        case thumbFileName = "thumb_file_name"
        case title
        case uuid
    }

    public required convenience init(from decoder: Decoder) throws {
        guard let contextUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "MetaRecord", in: managedObjectContext) else {
            let errorDescription: String = "failed to initialize core data entity from decoder"
            Logger.coreData.critical("\(errorDescription)")
            fatalError(errorDescription)
        }

        self.init(entity: entity, insertInto: managedObjectContext)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            bundleFileName = try values.decode(String.self, forKey: .bundleFileName)
            checksum = try values.decode(String.self, forKey: .checksum)
            ctime = try values.decode(Int64.self, forKey: .ctime)
            mtime = try values.decode(Int64.self, forKey: .mtime)
            status = try values.decode(Int16.self, forKey: .status)
            thumbFileName = try values.decode(String.self, forKey: .thumbFileName)
            title = try values.decode(String.self, forKey: .title)
            uuid = try values.decode(String.self, forKey: .uuid)
        } catch {
            Logger.coreData.critical("decoding error: \(error.localizedDescription)")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        do {
            try container.encode(bundleFileName, forKey: .bundleFileName)
            try container.encode(checksum, forKey: .checksum)
            try container.encode(ctime, forKey: .ctime)
            try container.encode(mtime, forKey: .mtime)
            try container.encode(status, forKey: .status)
            try container.encode(thumbFileName, forKey: .thumbFileName)
            try container.encode(title, forKey: .title)
            try container.encode(uuid, forKey: .uuid)
        } catch {
            Logger.coreData.critical("encoding error: \(error.localizedDescription)")
        }
    }
}
