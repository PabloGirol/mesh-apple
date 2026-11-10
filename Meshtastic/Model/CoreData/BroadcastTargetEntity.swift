//
//  BroadcastTargetEntity.swift
//  Meshtastic
//
//  Core Data entity generated from SwiftData model.
//  Uses KVC instead of @NSManaged to avoid .stringsdata generation conflicts.

import CoreData
import Foundation

@objc(BroadcastTargetEntity)
public class BroadcastTargetEntity: NSManagedObject {

}

extension BroadcastTargetEntity {
    public var preset: Int32 {
        get { value(forKey: "preset") as! Int32 }
        set { setValue(newValue, forKey: "preset") }
    }
    public var region: Int32 {
        get { value(forKey: "region") as! Int32 }
        set { setValue(newValue, forKey: "region") }
    }
    public var channelIndex: Int32 {
        get { value(forKey: "channelIndex") as! Int32 }
        set { setValue(newValue, forKey: "channelIndex") }
    }
    public var frequencySlot: Int32 {
        get { value(forKey: "frequencySlot") as! Int32 }
        set { setValue(newValue, forKey: "frequencySlot") }
    }
    public var meshBeaconConfig: MeshBeaconConfigEntity? {
        get { value(forKey: "meshBeaconConfig") as? MeshBeaconConfigEntity }
        set { setValue(newValue, forKey: "meshBeaconConfig") }
    }
}

extension BroadcastTargetEntity: CoreDataEntity {
    public static var entityName: String { "BroadcastTargetEntity" }
}
