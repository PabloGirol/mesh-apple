//
//  DeviceLinkEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(DeviceLinkEntity)
public class DeviceLinkEntity: NSManagedObject {

}

extension DeviceLinkEntity {
    public var deviceId: String {
        get { value(forKey: "deviceId") as! String }
        set { setValue(newValue, forKey: "deviceId") }
    }
    public var deviceName: String {
        get { value(forKey: "deviceName") as! String }
        set { setValue(newValue, forKey: "deviceName") }
    }
    public var lastConnected: Date {
        get { value(forKey: "lastConnected") as! Date }
        set { setValue(newValue, forKey: "lastConnected") }
    }
}

extension DeviceLinkEntity: CoreDataEntity {
    public static var entityName: String { "DeviceLinkEntity" }
}
