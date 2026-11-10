//
//  DeviceMetadataEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(DeviceMetadataEntity)
public class DeviceMetadataEntity: NSManagedObject {

}

extension DeviceMetadataEntity {
    public var deviceId: String {
        get { value(forKey: "deviceId") as! String }
        set { setValue(newValue, forKey: "deviceId") }
    }
    public var key: String {
        get { value(forKey: "key") as! String }
        set { setValue(newValue, forKey: "key") }
    }
    public var value: String {
        get { value(forKey: "value") as! String }
        set { setValue(newValue, forKey: "value") }
    }
}

extension DeviceMetadataEntity: CoreDataEntity {
    public static var entityName: String { "DeviceMetadataEntity" }
}
