//
//  StoreForwardConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(StoreForwardConfigEntity)
public class StoreForwardConfigEntity: NSManagedObject {

}

extension StoreForwardConfigEntity {
    public var enabled: Bool {
        get { value(forKey: "enabled") as! Bool }
        set { setValue(newValue, forKey: "enabled") }
    }
    public var heartbeat: Bool {
        get { value(forKey: "heartbeat") as! Bool }
        set { setValue(newValue, forKey: "heartbeat") }
    }
    public var historyReturnMax: Int32 {
        get { value(forKey: "historyReturnMax") as! Int32 }
        set { setValue(newValue, forKey: "historyReturnMax") }
    }
    public var historyReturnWindow: Int32 {
        get { value(forKey: "historyReturnWindow") as! Int32 }
        set { setValue(newValue, forKey: "historyReturnWindow") }
    }
    public var isRouter: Bool {
        get { value(forKey: "isRouter") as! Bool }
        set { setValue(newValue, forKey: "isRouter") }
    }
    public var lastHeartbeat: Date?? {
        get { value(forKey: "lastHeartbeat") as? Date? }
        set { setValue(newValue, forKey: "lastHeartbeat") }
    }
    public var lastRequest: Int32 {
        get { value(forKey: "lastRequest") as! Int32 }
        set { setValue(newValue, forKey: "lastRequest") }
    }
    public var records: Int32 {
        get { value(forKey: "records") as! Int32 }
        set { setValue(newValue, forKey: "records") }
    }
    public var storeForwardConfigNode: NodeInfoEntity? {
        get { value(forKey: "storeForwardConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "storeForwardConfigNode") }
    }
}

extension StoreForwardConfigEntity: CoreDataEntity {
    public static var entityName: String { "StoreForwardConfigEntity" }
}
