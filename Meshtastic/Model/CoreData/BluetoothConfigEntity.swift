//
//  BluetoothConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(BluetoothConfigEntity)
public class BluetoothConfigEntity: NSManagedObject {

}

extension BluetoothConfigEntity {
    public var deviceLoggingEnabled: Bool {
        get { value(forKey: "deviceLoggingEnabled") as! Bool }
        set { setValue(newValue, forKey: "deviceLoggingEnabled") }
    }
    public var enabled: Bool {
        get { value(forKey: "enabled") as! Bool }
        set { setValue(newValue, forKey: "enabled") }
    }
    public var fixedPin: Int32 {
        get { value(forKey: "fixedPin") as! Int32 }
        set { setValue(newValue, forKey: "fixedPin") }
    }
    public var mode: Int32 {
        get { value(forKey: "mode") as! Int32 }
        set { setValue(newValue, forKey: "mode") }
    }
    public var bluetoothConfigNode: NodeInfoEntity? {
        get { value(forKey: "bluetoothConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "bluetoothConfigNode") }
    }
}

extension BluetoothConfigEntity: CoreDataEntity {
    public static var entityName: String { "BluetoothConfigEntity" }
}
