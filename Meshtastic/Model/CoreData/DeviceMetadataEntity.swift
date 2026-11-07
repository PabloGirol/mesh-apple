//
//  DeviceMetadataEntity.swift
//  Meshtastic
//
//  Core Data entity for DeviceMetadataEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(DeviceMetadataEntity)
public class DeviceMetadataEntity: NSManagedObject {

}

extension DeviceMetadataEntity {
    @NSManaged public var deviceId: String
    @NSManaged public var key: String
    @NSManaged public var value: String
}

extension DeviceMetadataEntity: CoreDataEntity {
    public static var entityName: String { "DeviceMetadataEntity" }
}
