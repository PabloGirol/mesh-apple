//
//  DeviceHardwareImageEntity.swift
//  Meshtastic
//
//  Core Data entity for DeviceHardwareImageEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(DeviceHardwareImageEntity)
public class DeviceHardwareImageEntity: NSManagedObject {

}

extension DeviceHardwareImageEntity {
    @NSManaged public var imageData: Data
    @NSManaged public var isDefault: Bool
    @NSManaged public var device: DeviceHardwareEntity?
}

extension DeviceHardwareImageEntity: CoreDataEntity {
    public static var entityName: String { "DeviceHardwareImageEntity" }
}
