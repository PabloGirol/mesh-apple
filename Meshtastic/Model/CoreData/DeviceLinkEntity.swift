//
//  DeviceLinkEntity.swift
//  Meshtastic
//
//  Core Data entity for DeviceLinkEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(DeviceLinkEntity)
public class DeviceLinkEntity: NSManagedObject {

}

extension DeviceLinkEntity {
    @NSManaged public var deviceId: String
    @NSManaged public var deviceName: String
    @NSManaged public var lastConnected: Date
}

extension DeviceLinkEntity: CoreDataEntity {
    public static var entityName: String { "DeviceLinkEntity" }
}
