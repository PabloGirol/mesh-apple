//
//  DeviceConfigEntity.swift
//  Meshtastic
//
//  Core Data entity for DeviceConfigEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(DeviceConfigEntity)
public class DeviceConfigEntity: NSManagedObject {

}

extension DeviceConfigEntity {
    @NSManaged public var debugLogEnabled: Bool
    @NSManaged public var role: Int32
    @NSManaged public var serialEnabled: Bool
    @NSManaged public var deviceConfigNode: NodeInfoEntity?
}

extension DeviceConfigEntity: CoreDataEntity {
    public static var entityName: String { "DeviceConfigEntity" }
}
