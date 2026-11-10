//
//  PaxCounterConfigEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(PaxCounterConfigEntity)
public class PaxCounterConfigEntity: NSManagedObject {

}

extension PaxCounterConfigEntity {
    public var bleThreshold: Int32 {
        get { value(forKey: "bleThreshold") as! Int32 }
        set { setValue(newValue, forKey: "bleThreshold") }
    }
    public var enabled: Bool {
        get { value(forKey: "enabled") as! Bool }
        set { setValue(newValue, forKey: "enabled") }
    }
    public var updateInterval: Int32 {
        get { value(forKey: "updateInterval") as! Int32 }
        set { setValue(newValue, forKey: "updateInterval") }
    }
    public var wifiThreshold: Int32 {
        get { value(forKey: "wifiThreshold") as! Int32 }
        set { setValue(newValue, forKey: "wifiThreshold") }
    }
    public var paxCounterConfigNode: NodeInfoEntity? {
        get { value(forKey: "paxCounterConfigNode") as? NodeInfoEntity }
        set { setValue(newValue, forKey: "paxCounterConfigNode") }
    }
}

extension PaxCounterConfigEntity: CoreDataEntity {
    public static var entityName: String { "PaxCounterConfigEntity" }
}
