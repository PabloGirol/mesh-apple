//
//  DiscoveredBeaconEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(DiscoveredBeaconEntity)
public class DiscoveredBeaconEntity: NSManagedObject {

}

extension DiscoveredBeaconEntity {
    public var channelIndex: Int32 {
        get { value(forKey: "channelIndex") as! Int32 }
        set { setValue(newValue, forKey: "channelIndex") }
    }
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
    public var hopLimit: Int32 {
        get { value(forKey: "hopLimit") as! Int32 }
        set { setValue(newValue, forKey: "hopLimit") }
    }
    public var payload: Data?? {
        get { value(forKey: "payload") as? Data? }
        set { setValue(newValue, forKey: "payload") }
    }
    public var session: DiscoverySessionEntity? {
        get { value(forKey: "session") as? DiscoverySessionEntity }
        set { setValue(newValue, forKey: "session") }
    }
}

extension DiscoveredBeaconEntity: CoreDataEntity {
    public static var entityName: String { "DiscoveredBeaconEntity" }
}
