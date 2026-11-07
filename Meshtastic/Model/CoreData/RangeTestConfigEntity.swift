//
//  RangeTestConfigEntity.swift
//  Meshtastic
//
//  Core Data entity for RangeTestConfigEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(RangeTestConfigEntity)
public class RangeTestConfigEntity: NSManagedObject {

}

extension RangeTestConfigEntity {
    @NSManaged public var enabled: Bool
    @NSManaged public var save: Bool
    @NSManaged public var sender: Int32
    @NSManaged public var rangeTestConfigNode: NodeInfoEntity?
}

extension RangeTestConfigEntity: CoreDataEntity {
    public static var entityName: String { "RangeTestConfigEntity" }
}
