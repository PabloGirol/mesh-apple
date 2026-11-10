//
//  DiscoveredNodeEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(DiscoveredNodeEntity)
public class DiscoveredNodeEntity: NSManagedObject {

}

extension DiscoveredNodeEntity {
    public var nodeNum: Int64 {
        get { value(forKey: "nodeNum") as! Int64 }
        set { setValue(newValue, forKey: "nodeNum") }
    }
    public var snr: Float {
        get { value(forKey: "snr") as! Float }
        set { setValue(newValue, forKey: "snr") }
    }
    public var lastHeard: Date {
        get { value(forKey: "lastHeard") as! Date }
        set { setValue(newValue, forKey: "lastHeard") }
    }
    public var hopsAway: Int32 {
        get { value(forKey: "hopsAway") as! Int32 }
        set { setValue(newValue, forKey: "hopsAway") }
    }
    public var session: DiscoverySessionEntity? {
        get { value(forKey: "session") as? DiscoverySessionEntity }
        set { setValue(newValue, forKey: "session") }
    }
}

extension DiscoveredNodeEntity: CoreDataEntity {
    public static var entityName: String { "DiscoveredNodeEntity" }
}
