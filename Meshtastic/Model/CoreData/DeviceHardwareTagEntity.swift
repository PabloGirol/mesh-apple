//
//  DeviceHardwareTagEntity.swift
//  Meshtastic
//
//  Core Data entity for DeviceHardwareTagEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(DeviceHardwareTagEntity)
public class DeviceHardwareTagEntity: NSManagedObject {

}

extension DeviceHardwareTagEntity {
    @NSManaged public var tag: String
    @NSManaged public var device: DeviceHardwareEntity?
}

extension DeviceHardwareTagEntity: CoreDataEntity {
    public static var entityName: String { "DeviceHardwareTagEntity" }
}
