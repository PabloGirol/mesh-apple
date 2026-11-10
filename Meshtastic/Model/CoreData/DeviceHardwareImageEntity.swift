//
//  DeviceHardwareImageEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(DeviceHardwareImageEntity)
public class DeviceHardwareImageEntity: NSManagedObject {

}

extension DeviceHardwareImageEntity {
    public var imageData: Data {
        get { value(forKey: "imageData") as! Data }
        set { setValue(newValue, forKey: "imageData") }
    }
    public var isDefault: Bool {
        get { value(forKey: "isDefault") as! Bool }
        set { setValue(newValue, forKey: "isDefault") }
    }
    public var device: DeviceHardwareEntity? {
        get { value(forKey: "device") as? DeviceHardwareEntity }
        set { setValue(newValue, forKey: "device") }
    }
}

extension DeviceHardwareImageEntity: CoreDataEntity {
    public static var entityName: String { "DeviceHardwareImageEntity" }
}
