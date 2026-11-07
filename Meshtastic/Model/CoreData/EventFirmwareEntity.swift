//
//  EventFirmwareEntity.swift
//  Meshtastic
//
//  Core Data entity for EventFirmwareEntity
//  Generated from SwiftData model + CoreDataMigrationService
//

import CoreData
import Foundation

@objc(EventFirmwareEntity)
public class EventFirmwareEntity: NSManagedObject {

}

extension EventFirmwareEntity {
    @NSManaged public var eventId: String
    @NSManaged public var firmwareVersion: String
    @NSManaged public var hardwareModel: String
    @NSManaged public var timestamp: Date
}

extension EventFirmwareEntity: CoreDataEntity {
    public static var entityName: String { "EventFirmwareEntity" }
}
