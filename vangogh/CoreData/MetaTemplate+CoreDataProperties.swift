///
/// MetaTemplate+CoreDataProperties
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import CoreData
import Foundation

extension MetaTemplate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MetaTemplate> {
        return NSFetchRequest<MetaTemplate>(entityName: "MetaTemplate")
    }

    @NSManaged public var bundleFileName: String
    @NSManaged public var checksum: String
    @NSManaged public var ctime: Int64
    @NSManaged public var mtime: Int64
    @NSManaged public var status: Int16
    @NSManaged public var thumbFileName: String
    @NSManaged public var title: String
    @NSManaged public var uuid: String
}
