//
//  SerialConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(SerialConfigEntity)
public class SerialConfigEntity: NSManagedObject {

}

extension SerialConfigEntity {
    public var baudRate: Int32 {
        get { value(forKey: "baudRate") as! Int32 }
        set { setValue(newValue, forKey: "baudRate") }
    }
    public var echo: Bool {
        get { value(forKey: "echo") as! Bool }
        set { setValue(newValue, forKey: "echo") }
    }
    public var enabled: Bool {
        get { value(forKey: "enabled") as! Bool }
        set { setValue(newValue, forKey: "enabled") }
    }
    public var mode: Int32 {
        get { value(forKey: "mode") as! Int32 }
        set { setValue(newValue, forKey: "mode") }
    }
    public var overrideConsoleSerialPort: Bool {
        get { value(forKey: "overrideConsoleSerialPort") as! Bool }
        set { setValue(newValue, forKey: "overrideConsoleSerialPort") }
    }
    public var rxd: Int32 {
        get { value(forKey: "rxd") as! Int32 }
        set { setValue(newValue, forKey: "rxd") }
    }
    public var timeout: Int32 {
        get { value(forKey: "timeout") as! Int32 }
        set { setValue(newValue, forKey: "timeout") }
    }
    public var txd: Int32 {
        get { value(forKey: "txd") as! Int32 }
        set { setValue(newValue, forKey: "txd") }
    }
    public var serialConfigNode: NodeInfoEntity? {
        get { value(forKey: "serialConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "serialConfigNode") }
    }
}

extension SerialConfigEntity: CoreDataEntity {
    public static var entityName: String { "SerialConfigEntity" }
}
