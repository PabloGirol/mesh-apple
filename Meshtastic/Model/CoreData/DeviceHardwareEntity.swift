//
//  DeviceHardwareEntity.swift
//  Meshtastic
//
//  Core Data entity for DeviceHardwareEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(DeviceHardwareEntity)
public class DeviceHardwareEntity: NSManagedObject {

}

extension DeviceHardwareEntity {
    @NSManaged public var hwModel: String
    @NSManaged public var variant: String??
    @NSManaged public var tags: NSSet
    @NSManaged public var images: NSSet

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: DeviceHardwareTagEntity)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: DeviceHardwareTagEntity)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)


    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: DeviceHardwareImageEntity)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: DeviceHardwareImageEntity)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}

extension DeviceHardwareEntity: CoreDataEntity {
    public static var entityName: String { "DeviceHardwareEntity" }
}
