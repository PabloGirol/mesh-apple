//
//  DiscoveryPresetResultEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(DiscoveryPresetResultEntity)
public class DiscoveryPresetResultEntity: NSManagedObject {

}

extension DiscoveryPresetResultEntity {
    public var presetIndex: Int32 {
        get { value(forKey: "presetIndex") as! Int32 }
        set { setValue(newValue, forKey: "presetIndex") }
    }
    public var presetName: String {
        get { value(forKey: "presetName") as! String }
        set { setValue(newValue, forKey: "presetName") }
    }
    public var nodesHeard: Int32 {
        get { value(forKey: "nodesHeard") as! Int32 }
        set { setValue(newValue, forKey: "nodesHeard") }
    }
    public var snrSum: Float {
        get { value(forKey: "snrSum") as! Float }
        set { setValue(newValue, forKey: "snrSum") }
    }
    public var snrCount: Int32 {
        get { value(forKey: "snrCount") as! Int32 }
        set { setValue(newValue, forKey: "snrCount") }
    }
    public var session: DiscoverySessionEntity? {
        get { value(forKey: "session") as? DiscoverySessionEntity }
        set { setValue(newValue, forKey: "session") }
    }
}

extension DiscoveryPresetResultEntity: CoreDataEntity {
    public static var entityName: String { "DiscoveryPresetResultEntity" }
}
