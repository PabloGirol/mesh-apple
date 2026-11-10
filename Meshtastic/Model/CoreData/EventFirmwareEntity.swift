//
//  EventFirmwareEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(EventFirmwareEntity)
public class EventFirmwareEntity: NSManagedObject {

}

extension EventFirmwareEntity {
    public var eventId: String {
        get { value(forKey: "eventId") as! String }
        set { setValue(newValue, forKey: "eventId") }
    }
    public var firmwareVersion: String {
        get { value(forKey: "firmwareVersion") as! String }
        set { setValue(newValue, forKey: "firmwareVersion") }
    }
    public var hardwareModel: String {
        get { value(forKey: "hardwareModel") as! String }
        set { setValue(newValue, forKey: "hardwareModel") }
    }
    public var timestamp: Date {
        get { value(forKey: "timestamp") as! Date }
        set { setValue(newValue, forKey: "timestamp") }
    }
}

extension EventFirmwareEntity: CoreDataEntity {
    public static var entityName: String { "EventFirmwareEntity" }
}
