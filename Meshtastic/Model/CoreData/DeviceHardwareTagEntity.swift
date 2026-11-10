//
//  DeviceHardwareTagEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(DeviceHardwareTagEntity)
public class DeviceHardwareTagEntity: NSManagedObject {

}

extension DeviceHardwareTagEntity {
    public var tag: String {
        get { value(forKey: "tag") as! String }
        set { setValue(newValue, forKey: "tag") }
    }
    public var device: DeviceHardwareEntity? {
        get { value(forKey: "device") as? DeviceHardwareEntity }
        set { setValue(newValue, forKey: "device") }
    }
}

extension DeviceHardwareTagEntity: CoreDataEntity {
    public static var entityName: String { "DeviceHardwareTagEntity" }
}
